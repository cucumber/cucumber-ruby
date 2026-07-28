# 1. Generate Messages at the source of the message data

Date: 2026-07-24

## Status

Accepted (Pending Review)

## Context

Several Messages are (still), generated centrally from `Event`s by the `MessageBuilder` class. The goal is that each Message is generated at the source (time), of the specific message data being produced (which often is where the corresponding `Event` is generated - and published).

## Decision

Generate each `Message` at source (of the message data). When all `Message`s are generated at their source(s), of the message data; the `MessageBuilder` class can be removed altogether.

In the end, we want to have only one event on the bus: `envelope`. Then we'll be able to change our event bus to just handle envelopes/messages.

Then; the next step will be to convert all the `Event` users to use `Message`s instead. Many of the `Event` users are formatters, but there are also other `Event` users, for instance the Retry filter.

## Consequences

* Each time we start to generate a Message at the message data source we need simultaneously...
  * Stop the MessageBuilder from generating it. Usually that also means that a handler can be removed from the MessageBuilder. Note: this may not be a direct 1:1 relationship between message/event.
  * Ensure that any Message user/consumer is checked. Especially if the new source location of the envelope event is outside of the main `cucumber-ruby` gem

When converting between `Event`s and `Message`s, there are three ways the relationship could go:

1. 1:1 relationship between `Event` <-> `Message`
2. `Event`s that don't have a corresponding `Message` (e.g. `gherkin_source_read`, `test_case_ready`)
3. `Message`s that don't have a corresponding (obvious) event (e.g. `meta`)

Each needs to be taken case-by-case.
