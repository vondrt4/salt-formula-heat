{%- from "heat/map.jinja" import server with context %}

heat_task_service_running:
  test.show_notification:
    - name: "dump_message_service_running_heat"
    - text: "Running heat.upgrade.service_running"

{%- if server.get('enabled', false) %}

  {%- for hservice in server.services %}
heat_server_service_{{ hservice }}:
  service.running:
  - name: {{ hservice }}
  - enable: true
  {%- endfor %}
{%- endif %}
