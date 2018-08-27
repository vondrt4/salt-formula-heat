include:
 - heat.upgrade.verify.api

heat_pre:
  test.show_notification:
    - name: "dump_message_pre-upgrade_heat"
    - text: "Running heat.upgrade.pre"
