# Test of enabling SSL for the following communication paths:
# - messaging (rabbitmq)
# - database

include:
  - .server_cluster

heat:
  server:
    database:
      ssl:
        enabled: True
    message_queue:
      port: 5671
      ssl:
        enabled: True
