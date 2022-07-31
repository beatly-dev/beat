> It is not product-ready. You should carefully consider using this package
> in your production environment.

# Beat Station - State management with state machine

This project is my toy project to simplify the state management flows in `Flutter` and `dart`. Whole functionalities are heavily inspired by [xstate.js](https://xstate.js.org).
I highly recommend reading the docs of [xstate.js](https://xstate.js.org).

Go to the [Beatly Book](https://book.beatly.dev/) for more information.

# Roadmap - Features compatible with xstate.js

A roadmap is as follows, but the order does not matter.

- [x] Support simple state transition without context
- [x] Listen to state and context changes
- [x] Map states
- [x] Execute callback on state change
- [x] Support reset
- [x] Support context
  - [x] Initialize with context
  - [x] Get current context
  - [x] assign new context
- [x] Support transition with an argument
- [ ] Support nested(compound, hierarchical) state
  - [x] Define compound state
  - [x] Using `send()`
  - [x] Using verbose styled transition via `{compoundStateName}Compound` field
  - [ ] Multi-level compound state
    - Currently, only 2 level compound state is supported
  - [ ] Custom initialization on parent state creation
  - [ ] Get current state of compound state using `currentState`
    - Currently `{compundStateName}Compound.currentState` is supported
  - [ ] Reset on parent state enter/exit
  - [ ] Reset on parent state reset
- [x] Support state change history
- [x] Support any state transition
  - [x] BeatStation with common `Beat` option
- [x] Support `state.matches` as a `is{State}`
- [x] Support `send()` styled transition
  - `station.send` is supported
- [ ] Support actions (fire-and-forget)
  - [x] callback action
  - [x] assign action
  - [x] callback action with variable length of arguments
  - [ ] choose action
  - [ ] forwardTo action
  - [ ] log action
  - [ ] pure action
  - [ ] raise action
  - [ ] respond action
  - [ ] send action
- [ ] Support invoking services
  - [x] async function (or Future)
  - [x] onDone/onError actions
  - [x] onDone/onError transitions
  - [ ] callback
  - [ ] observables
  - [ ] other beat station
  - [ ] multiple services
- [ ] Support instance options
- [ ] Support eventless(always) transition
- [ ] Support delayed transition
  - [ ] Delay on eventless transition
  - [ ] Delay on `send()` or `$event()`
- [ ] Support
- [ ] Support `entry` and `exit` actions
- [ ] Support conditional (guarded) transition
  - [ ] Support custom functions
  - [ ] Support `in` state condition
- [ ] Support internal transition
- [ ] Support external transition
- [ ] Support Forbidden transition
- [ ] Support multiple targets
- [ ] Support multiple events
- [ ] Support actors
- [ ] Support `state.nextEvents`
- [ ] Support `state.changed`
- [ ] Support `state.done`
- [ ] Support `state.meta`, `state.tags`
- [ ] Support `state.can`
- [ ] Support history JSON to persist
  - `toString()` is currently supported
- [ ] Support parallel state
  - [ ] Define parallel state
  - [ ] Support multiple targets event
- [ ] Separate `interpreter` and `station`
  - [ ] Support pure `transition()`
- [ ] Event history with event sourcing
- [ ] Manually execute actions, `execute(state)` [reference](https://xstate.js.org/docs/guides/interpretation.html#executing-actions)
- [ ] `waitFor(state, timeout)` method [reference](https://xstate.js.org/docs/guides/interpretation.html#waitfor)
- [ ] Support scxml
- [ ] Support bootstrapping
- [ ] Support CLI/GUI tools
- [ ] xstate.js compatible beat station

# Features not supported by this package but in xstate.js

- The `final` state is naturally defined which does not have any `Beat` annotation
- `state.toString()`: naturally supported
- wildcard transitions and forbidden transitions are not needed because there will be no typo

# Additionals for flutter

- [ ] Support beat-station-friendly flutter widgets
- [ ] Inspect state, history, event history, next events, etc., from devtools widget inspector
- [ ] Support [`remix.run`](https://remix.run)'s concept
  - [ ] `loader`
  - [ ] `action` (side effect)
  - [ ] `ErrorBoundary`/`CatchBoundary`
- [ ] Support navigation

# Usage
