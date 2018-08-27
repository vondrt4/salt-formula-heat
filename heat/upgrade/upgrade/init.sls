{%- from "heat/map.jinja" import server with context %}

heat_upgrade:
  test.show_notification:
    - name: "dump_message_upgrade_heat"
    - text: "Running heat.upgrade.upgrade"

include:
 - heat.upgrade.service_stopped
 - heat.upgrade.pkgs_latest
 - heat.upgrade.render_config
 - heat.db.offline_sync
 - heat.upgrade.service_running
