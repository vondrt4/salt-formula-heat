
============
Heat Formula
============

Heat is the main project in the OpenStack Orchestration program. It implements
an orchestration engine to launch multiple composite cloud applications based
on templates in the form of text files that can be treated like code. A native
Heat template format is evolving, but Heat also endeavours to provide
compatibility with the AWS CloudFormation template format, so that many
existing CloudFormation templates can be launched on OpenStack. Heat provides
both an OpenStack-native ReST API and a CloudFormation-compatible Query API.

Sample Pillars
==============

Single Heat services on the controller node

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

Define server clients keystone parameter

.. code-block:: yaml

    heat:
      server:
        clients:
          keystone:
            protocol: https
            host: 10.0.106.10
            port: 5000
            insecure: false

Enable CORS parameters

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


Heat client with specified git templates

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


Ceilometer notification

.. code-block:: yaml

    heat:
      server:
        enabled: true
        version: icehouse
        notification: true

Configuration of policy.json file

.. code-block:: yaml

    heat:
      server:
        ....
        policy:
          deny_stack_user: 'not role:heat_stack_user'
          'cloudformation:ValidateTemplate': 'rule:deny_stack_user'
          # Add key without value to remove line from policy.json
          'cloudformation:DescribeStackResource':


Client-side RabbitMQ HA setup

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

Client-side RabbitMQ TLS configuration:

|

To enable TLS for oslo.messaging you need to provide the CA certificate.

By default system-wide CA certs are used. Nothing should be specified except `ssl.enabled`.

.. code-block:: yaml

      ....
      message_queue:
        ssl:
          enabled: True

Use `cacert_file` param to specify the CA-cert file location explicitly:

.. code-block:: yaml

      ....
      message_queue:
        ssl:
          enabled: True
          cacert_file: /etc/ssl/rabbitmq-ca.pem

To manage content of the `cacert_file` use the `cacert` param:

.. code-block:: yaml

      ....
      message_queue:
        ssl:
          enabled: True
          cacert: { file content here }
          cacert_file: /etc/openstack/rabbitmq-ca.pem

Notice:
 * The `message_queue.port` is set to **5671** (AMQPS) by default if `ssl.enabled=True`.
 * Use `message_queue.ssl.version` if you need to specify protocol version. By default is TLSv1 for python < 2.7.9 and TLSv1_2 for version above.


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-heat/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-heat

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
