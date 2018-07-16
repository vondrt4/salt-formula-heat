{%- from "heat/map.jinja" import server with context %}
{%- if server.enabled %}

heat_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/heat/heat.conf:
  file.managed:
  - source: salt://heat/files/{{ server.version }}/heat.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: heat_server_packages

/etc/heat/api-paste.ini:
  file.managed:
  - source: salt://heat/files/{{ server.version }}/api-paste.ini
  - template: jinja
  - require:
    - pkg: heat_server_packages

{%- for service_name in server.services %}
{{ service_name }}_default:
  file.managed:
    - name: /etc/default/{{ service_name }}
    - source: salt://heat/files/default
    - template: jinja
    - defaults:
        service_name: {{ service_name }}
        values: {{ server }}
    - require:
      - pkg: heat_server_packages
    - watch_in:
      - service: heat_server_services
{%- endfor %}


{%- if server.logging.log_appender %}

{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
heat_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

heat_general_logging_conf:
  file.managed:
    - name: /etc/heat/logging.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - user: heat
    - group: heat
    - defaults:
        service_name: heat
        _data: {{ server.logging }}
    - require:
      - pkg: heat_server_packages
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: heat_fluentd_logger_package
{%- endif %}
    - watch_in:
      - service: heat_server_services

/var/log/heat/heat.log:
  file.managed:
    - user: heat
    - group: heat
    - watch_in:
      - service: heat_server_services

{% for service_name in server.get('services', []) %}
{{ service_name }}_logging_conf:
  file.managed:
    - name: /etc/heat/logging/logging-{{ service_name }}.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - makedirs: True
    - user: heat
    - group: heat
    - defaults:
        service_name: {{ service_name }}
        _data: {{ server.logging }}
    - require:
      - pkg: heat_server_packages
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: heat_fluentd_logger_package
{%- endif %}
    - watch_in:
      - service: heat_server_services
{% endfor %}

{% endif %}

{%- for name, rule in server.get('policy', {}).iteritems() %}

{%- if rule != None %}
heat_keystone_rule_{{ name }}_present:
  keystone_policy.rule_present:
  - path: /etc/heat/policy.json
  - name: {{ name }}
  - rule: {{ rule }}
  - require:
    - pkg: heat_server_packages

{%- else %}

heat_keystone_rule_{{ name }}_absent:
  keystone_policy.rule_absent:
  - path: /etc/heat/policy.json
  - name: {{ name }}
  - require:
    - pkg: heat_server_packages

{%- endif %}

{%- endfor %}

{%- if grains.get('virtual_subtype', None) == "Docker" %}

heat_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://heat/files/entrypoint.sh
  - mode: 755

keystonercv3:
  file.managed:
  - name: /root/keystonercv3
  - template: jinja
  - source: salt://heat/files/keystonercv3
  - mode: 755

{%- endif %}

{%- if not grains.get('virtual_subtype', None) == "Docker" %}
{%- if server.version != 'juno' %}

heat_keystone_setup:
  cmd.run:
  - name: 'source /root/keystonercv3; heat-keystone-setup-domain --stack-user-domain-name heat_user_domain --stack-domain-admin heat_domain_admin --stack-domain-admin-password {{ server.stack_domain_admin.password }}'
  - shell: /bin/bash
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages
  - require_in:
    - cmd: heat_syncdb

{%- endif %}

{%- endif %}

heat_syncdb:
  cmd.run:
  - name: heat-manage db_sync
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages

heat_log_access:
  cmd.run:
  - name: chown heat:heat /var/log/heat/ -R
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/heat/heat.conf
    - pkg: heat_server_packages
  - require_in:
    - service: heat_server_services

heat_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - cmd: heat_syncdb
  - watch:
    - file: /etc/heat/heat.conf
    - file: /etc/heat/api-paste.ini
    {%- if server.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca_heat_server
    {%- endif %}
    {%- if server.database.get('ssl',{}).get('enabled', False) %}
    - file: mysql_ca_heat_server
    {%- endif %}

{%- if server.message_queue.get('ssl',{}).get('enabled', False) %}
rabbitmq_ca_heat_server:
{%- if server.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.message_queue.ssl.cacert_file }}
    - contents_pillar: heat:server:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ server.message_queue.ssl.get('cacert_file', server.cacert_file) }}
{%- endif %}
{%- endif %}

{%- if server.database.get('ssl',{}).get('enabled', False) %}
mysql_ca_heat_server:
{%- if server.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.database.ssl.cacert_file }}
    - contents_pillar: heat:server:database:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ server.database.ssl.get('cacert_file', server.cacert_file) }}
{%- endif %}
   - require_in:
     - file: /etc/heat/heat.conf
{%- endif %}

{%- endif %}
