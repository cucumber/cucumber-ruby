# 1. Slim down the MessageBuilder

Date: 2026-07-24

## Status

accepted

## Context

The MessageBuilder has its tentacles in everything. For example, the `Formatter::HTML` inherits from it, and needs a reasonable amount of the methods, but it's hard to see which ones. It's a big class that does way too much.

When we introduce new formatters, we want them to work in a clean/easy way: just an `on_envelop` method, instead needing to listen to 10 different events.

## Decision

Remove all the other event listener methods from `MessageBuilder` so that we could eventually remove it altogether.

In the end, we want to have only one event on the bus: `envelope`. Then we'll be able to change our event bus to just handle envelopes/messages.

## Consequences

* each time we remove an event listener from MessageBuilder we need to simultaneously:
  * add the translated/generated event of type `envelope` next to the source of the actual event. Note: this may not be a direct 1:1 relationship between message/event.
  * remove the handler from `MessageBuilder` and ensure that any new formatter (these don't have to directly inherit) is checked and refactored.

When converting between messages and envelopes, there are three ways it could go:

1. event <-> message
2. events that don't have a corresponding message (e.g. `gherkin_source_read`, `test_case_ready`)
3. messages that don't have a corresponding (obvious) event (e.g. `meta`)

Each needs to be taken case-by-case.
