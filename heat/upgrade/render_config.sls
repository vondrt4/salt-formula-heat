{%- from "heat/map.jinja" import server, upgrade with context %}

heat_render_config:
  test.show_notification:
    - name: "dump_message_render_config_heat"
    - text: "Running heat.upgrade.render_config"

{%- if server.get('enabled', False) %}

/etc/heat/heat.conf:
  file.managed:
  - source: salt://heat/files/{{ server.version }}/heat.conf.{{ grains.os_family }}
  - template: jinja

{%- endif %}
