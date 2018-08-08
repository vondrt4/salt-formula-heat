
=====
Usage
=====

Heat is the main project in the OpenStack Orchestration program. It implements
an orchestration engine to launch multiple composite cloud applications based
on templates in the form of text files that can be treated like code. A native
Heat template format is evolving, but Heat also endeavours to provide
compatibility with the AWS CloudFormation template format, so that many
existing CloudFormation templates can be launched on OpenStack. Heat provides
both an OpenStack-native ReST API and a CloudFormation-compatible Query API.

Sample Pillars
==============

Single Heat services on the controller node:

.. code-block:: yaml

    heat:
      server:
        enabled: true
        version: icehouse
        region: RegionOne
        bind:
          metadata:
            address: 10.0.106.10
            port: 8000
            protocol: http
          waitcondition:
            address: 10.0.106.10
            port: 8000
            protocol: http
          watch:
            address: 10.0.106.10
            port: 8003
            protocol: http
        cloudwatch:
          host: 10.0.106.20
        api:
          host: 10.0.106.20
        api_cfn:
          host: 10.0.106.20
        database:
          engine: mysql
          host: 10.0.106.20
          port: 3306
          name: heat
          user: heat
          password: password
        identity:
          engine: keystone
          host: 10.0.106.20
          port: 35357
          tenant: service
          user: heat
          password: password
          endpoint_type_default: internalURL
          endpoint_type_heat: publicURL
        message_queue:
          engine: rabbitmq
          host: 10.0.106.20
          port: 5672
          user: openstack
          password: password
          virtual_host: '/openstack'
          ha_queues: True
        max_stacks_per_tenant: 150
        max_nested_stack_depth: 10

Define server clients Keystone parameter:

.. code-block:: yaml

    heat:
      server:
        clients:
          keystone:
            protocol: https
            host: 10.0.106.10
            port: 5000
            insecure: false

Enable CORS parameters:

.. code-block:: yaml

    heat:
      server:
        cors:
          allowed_origin: https:localhost.local,http:localhost.local
          expose_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_methods: GET,PUT,POST,DELETE,PATCH
          allow_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_credentials: True
          max_age: 86400

Heat client with specified git templates:

.. code-block:: yaml

    heat:
      client:
        enabled: true
        template:
          admin:
            domain: default
            source:
              engine: git
              address: git@repo.domain.com/admin-templates.git
              revision: master
          default:
            domain: default
            source:
              engine: git
              address: git@repo.domain.com/default-templates.git
              revision: master

Ceilometer notification:

.. code-block:: yaml

    heat:
      server:
        enabled: true
        version: icehouse
        notification: true

Configuration of ``policy.json`` file:

.. code-block:: yaml

    heat:
      server:
        ....
        policy:
          deny_stack_user: 'not role:heat_stack_user'
          'cloudformation:ValidateTemplate': 'rule:deny_stack_user'
          # Add key without value to remove line from policy.json
          'cloudformation:DescribeStackResource':

Client-side RabbitMQ HA setup:

.. code-block:: yaml

    heat:
      server:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....

Configuring TLS communications
-------------------------------

.. note:: By default, system-wide installed CA certs are used, so the
          ``cacert_file`` param is optional, as well as ``cacert``.

- **RabbitMQ TLS**

  .. code-block:: yaml

   heat:
    server:
        message_queue:
          port: 5671
          ssl:
            enabled: True
            (optional) cacert: cert body if the cacert_file does not exists
            (optional) cacert_file: /etc/openstack/rabbitmq-ca.pem
            (optional) version: TLSv1_2

- **MySQL TLS**

  .. code-block:: yaml

   heat:
     server:
        database:
          ssl:
            enabled: True
            (optional) cacert: cert body if the cacert_file does not exists
            (optional) cacert_file: /etc/openstack/mysql-ca.pem

- **Openstack HTTPS API**

  .. code-block:: yaml

   heat:
    server:
        identity:
           protocol: https
           (optional) cacert_file: /etc/openstack/proxy.pem
        clients:
           keystone:
             protocol: https
             (optional) cacert_file: /etc/openstack/proxy.pem

Enhanced logging with logging.conf
----------------------------------

By default logging.conf is disabled.

That is possible to enable per-binary logging.conf with new variables:

* ``openstack_log_appender``
   Set to true to enable ``log_config_append`` for all OpenStack services

* ``openstack_fluentd_handler_enabled``
   Set to true to enable ``FluentHandler`` for all Openstack services

* ``openstack_ossyslog_handler_enabled``
   Set to true to enable ``OSSysLogHandler`` for all Openstack services

Only `WatchedFileHandler``, ``OSSysLogHandler``, and ``FluentHandler`` are
available.

Also, it is possible to configure this with pillar:

.. code-block:: yaml

  heat:
    server:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-heat/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-heat
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome

