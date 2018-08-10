{%- from "keystone/map.jinja" import client as kclient with context %}

heat_upgrade_verify_api:
  test.show_notification:
    - name: "dump_message_verify_api"
    - text: "Running heat.upgrade.verify.api"

{%- if kclient.enabled and kclient.get('os_client_config', {}).get('enabled', False)  %}

heatv1_stack_list:
  module.run:
    - name: heatv1.stack_list
    - kwargs:
        cloud_name: admin_identity
{%- endif %}
