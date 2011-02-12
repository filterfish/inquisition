Inquisition
===========

Simple machine monitoring and alerting system based on AMQP and EventMachine.

- Comes with filesystem, process alive and memory helpers for use in checks.
- Very simple to add new tests, just write a ruby lambda.
- Client runs tests and puts results on to an AMQP queue.
- Server reads tests, checks limits and generates an alert if needed.
- Uses XMPP for alerting. But it wouldn't be hard to write an email back end.
- Uses YAML for configuration.
- Uses signals to reload configuration.

Checks
======

The following checks are built in:

- filesystem/size
- filesystem/percent_used
- memory/free
- process/rss
- process/exists
- amqp/depth
- http/get

Getting Started
===============

- Create user inquisition (adduser --system --home /var/lib/inquisition --group --shell=/bin/bash inquisition on a Debian based system)
- Create /var/run/inquisition and change ownership to inquisition:inquisition.
- Create /etc/inquisition and copy config/{config.yaml,logging.yaml} into it. Modify config.yaml & logging.yaml to you requirements.
- Create /var/log/inquisition or a directory that you logging.yaml points too.

Limits
======

There are two types of limits: boolean and value. So for example for the filesystem check is a vales limit and you might have "filesystem/percent_used 90%" this will generate an alert when the filesystem is over 90% used. If you don't have a limit the value is logged but no alerts are generated. You can also specify and lower limit.

For the boolean limit you specify true or false as the alert criteria. For example you might have 'process/exists false' which would generate an alert if the process does not exist.

TODO
====

- Clean up the configuration. It can be a little confusing.
- Replace AMQP with ZeroMQ. AMQP is overkill and if the AMQP sever dies so does the monitoring.

