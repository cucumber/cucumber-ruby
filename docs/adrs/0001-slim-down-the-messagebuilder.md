# 1. Generate Messages at the source of the message data

Date: 2026-07-24

## Status

accepted

## Context

The several Messages are (still) generated centrally from Events by the MessageBuilder. The goal is that each Message are generated at the source of the message data (which often is where the correspondeing Event is generated).

## Decision

Generate each Messages at the source of the message data. When all the Messages are generated at the source of the message data the `MessageBuilder` could be remove it altogether.

The next step is to convert all the Event users to use Messages instead. Many of the Event users are formatters, but there are also other Event users, for instance the Retry filter.

In the end, we want to have only one event on the bus: `envelope`. Then we'll be able to change our event bus to just handle envelopes/messages.

## Consequences

* each time we start to generate a Message at the message data source we need simulato simultaneously
  * stop the MessageBuilder to generate it. Usually that also means that a handler can be removed from the MessageBuilder. Note: this may not be a direct 1:1 relationship between message/event.
  * ensure that any Message user is checked. 

When converting between event and messages, there are three ways it could go:

1. event <-> message
2. events that don't have a corresponding message (e.g. `gherkin_source_read`, `test_case_ready`)
3. messages that don't have a corresponding (obvious) event (e.g. `meta`)

Each needs to be taken case-by-case.
