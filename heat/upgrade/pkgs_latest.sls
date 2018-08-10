{%- from "heat/map.jinja" import server, client, upgrade with context %}

heat_task_pkgs_latest:
  test.show_notification:
    - name: "dump_message_pkgs_latest"
    - text: "Running heat.upgrade.pkgs_latest"

policy-rc.d_present:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - mode: 755
    - contents: |
        #!/bin/sh
        exit 101

{%- set pkgs = [] %}
{%- if server.get('enabled', false) %}
  {%- do pkgs.extend(server.pkgs) %}
{%- endif %}
{%- if client.get('enabled', false) %}
  {%- do pkgs.extend(client.pkgs) %}
{%- endif %}

{%- if server.version in ["juno", "kilo", "liberty", "mitaka", "newton", "ocata", "pike"] %}
  {%- do pkgs.append('heat-api-cloudwatch') %}
{%- endif %}

heat_packages:
  pkg.latest:
  - names: {{ pkgs|unique }}
  - require:
    - file: policy-rc.d_present
  - require_in:
    - file: policy-rc.d_absent

policy-rc.d_absent:
  file.absent:
    - name: /usr/sbin/policy-rc.d
