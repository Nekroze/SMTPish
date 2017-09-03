# SMTPish

Converts old school email into some more modern forms of communication such as slack or kafka.

## Design

### Supervision Tree

Red lines are children of the root application supervisor, any of these can fail/crash and will be automatically restarted without affecting the other children.

Blue lines represent message flow from process to process.

![Supervision Tree Graph](https://g.gravizo.com/svg?
  digraph SupervisionTree {
    aize ="4,4";
    SMTPish [shape=box];
    edge [color=red];
    SMTPish -> Queue [weight=1];
    SMTPish -> TargetWorkers [weight=1];
    SMTPish -> Ingest [weight=1];
    SMTPish -> Dispatcher [weight=1];
    edge [color=blue];
    Queue -> TargetWorkers [weight=2];
    Ingest -> Dispatcher [weight=2];
    Dispatcher -> Queue [weight=2];
  }
)

## Usage

A docker image can be built off of this repo with the following command:

```
 $ docker build -t smtpish .
```

And for usage:

```
 $ docker run --name smtpish -p 2500 smtpish
```

The following environment variables are available for control:

 - `PORT` - integer to listen for SMTP messages on
 - `TARGETS` - comma separated list of targets to dispatch a message to
 - `SLACK_TOKEN` - Slack API token for sending messages
 - `SESSION_LIMIT` - integer limit of open SMTP connections
 - `LOG_LEVEL` - level of logs to display on the console
 - `WORKERS` - integer number of pooled workers for sending to targets
 - `WHITELIST_TO` - comma separated ist of email addresses that will not be ignored, if empty no filtering will be done
 - `WHITELIST_FROM` - comma separated ist of email addresses that will not be ignored, if empty no filtering will be done
 - `DYNAMIC_SENDER` - bool if true use the use half of the email sender as the sender when the target supports it
 - `DEFAULT_SENDER` - if `DYNAMIC_SENDER` is `false` then this will be the sender used
 - `DYNAMIC_DESTINATION` - bool if true use the use half of the email destination as the destination (eg room, channel, etc) when the target supports it
 - `DEFAULT_DESTINATION` - if `DYNAMIC_DESTINATION` is `false` then this will be the destination used

### Targets

The following targets are available to dispatch messages to when recieved via SMTP:

 - echo
 - exception
 - slack

The first two are for testing purposes.

## Development

### Docker

To spin up a develop build complete with period test input:

```
 $ docker-compose up
```

To try a production like build execute:

```
 $ docker-compose -f docker-compose.prod.yml -f docker-compose.yml build
 $ docker-compose -f docker-compose.prod.yml -f docker-compose.yml up
```

Or if you have elixir installed locally:

```
 $ mix compose up
```
