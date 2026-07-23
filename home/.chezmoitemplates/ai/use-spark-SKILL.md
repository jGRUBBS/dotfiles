---
name: use-spark
description: >-
  Use the spark CLI to access the user's Spark email data: list and search
  email, read threads, inspect calendar events and availability, look up
  contacts, and view team information.
metadata:
  version: 1.1.0
  requires:
    bins:
      - spark
---

# Use Spark

`spark` is an IPC client for the user's running Spark macOS app. Run it only
on the host Mac, not in a sandbox, container, CI runner, or remote execution
environment. If it cannot connect, ask the user to launch Spark.

Start with `spark accounts` to discover accessible accounts, calendars,
teams, shared inboxes, and access levels. Use `spark <command> --help` before
performing an unfamiliar or mutating operation.

Core read commands:

- `spark folders [account]`
- `spark emails [folder] [--filter QUERY]`
- `spark search TOPIC [--filter QUERY] [--in SCOPE]`
- `spark thread MESSAGE_ID`
- `spark events [--tomorrow|--week] [--in CALENDAR]`
- `spark availability [--tomorrow|--week] [--attendees EMAILS]`
- `spark contacts QUERY`
- `spark team`
- `spark meetings` and `spark meeting ID`

Mutating commands such as `draft`, `comment`, `action`, and
`contact-action` require triage access. Draft content for review unless the
user explicitly requested the corresponding external action.
