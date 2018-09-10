heat_post:
  test.show_notification:
    - name: "dump_post-upgrade_message_heat"
    - text: "Running heat.upgrade.post"

keystone_os_client_config_absent:
  file.absent:
    - name: /etc/openstack/clouds.yml
