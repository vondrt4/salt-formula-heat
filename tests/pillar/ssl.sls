# Test of enabling SSL for the following communication paths:
# - messaging (rabbitmq)

include:
  - .server_cluster

heat:
  server:
    message_queue:
      port: 5671
      ssl:
        enabled: True
