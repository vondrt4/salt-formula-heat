{%- from "heat/map.jinja" import server, upgrade with context %}

heat_task_service_stopped:
  test.show_notification:
    - name: "dump_message_service_stopped_heat"
    - text: "Running heat.upgrade.service_stopped"

{%- if server.get('enabled', false) %}

{%- if upgrade.get('old_release', {}) in ["juno", "kilo", "liberty", "mitaka", "newton", "ocata", "pike"] %}
  {%- do server.services.append('heat-api-cloudwatch') %}
{%- endif %}

heat_server_services_stopped:
  service.dead:
  - names: {{ server.services }}
  - enable: false

{%- endif %}
