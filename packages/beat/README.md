> It is not product-ready. You should carefully consider using this package
> in your production environment.

# Beat Station - State management with state machine

This project is my toy project to simplify the state management flows in `Flutter` and `dart`. Whole functionalities are heavily inspired by [xstate.js](https://xstate.js.org).
I highly recommend reading the docs of [xstate.js](https://xstate.js.org).

Go to the [Beatly Book](https://book.beatly.dev/), [한국어 문서](https://book.beatly.dev/v/beat-kr/) for more information.

# Roadmap

`beat` will be gradually improved and polished in the future. I have a kind of roadmap.

## State management for Dart-only applications

You can use `beat` as a Dart's state management system.

## State management for Flutter applications

`beat` provides a set of widgets that will increase your productivity
when building your flutter application. `beat` also provides
inspectors for debugging your state machine.

## GUI for state machines

Low-coding GUI application for your flutter's state machine.

## beat market place

You can share and sell your wonderful state machine.

## Real-time collaboration of state machines

Your team can collaborate online in real-time.

## Others

I aim to make `beat` to be a framework for flutter applications.
There will be another enhancement in the future including
easier network requests, form validation, render/computation separation,
and others. I might implement some kind of _full-stack_ dart framework in the future.

# Features compatible with xstate.js

A roadmap is as follows, but the order does not matter.

- [x] Support simple state transition without context
- [x] Listen to state and context changes
  - [x] `addListeners`/`removeListeners` and variations are for state
  - [x] `addContextListeners`/`removeContextListeners` is for context
  - [x] `stateStream` for `BeatState`, `enumStream` for your enum state, and `contextStream` for your data.
- [x] Map states
- [x] Execute callback on state change
- [x] Support reset
- [x] Support context
  - [x] Initialize with context
  - [x] Get current context
  - [x] assign new context
- [x] Support transition with an argument
- [x] Support nested(compound, hierarchical) state
  - [x] Define compound state
  - [x] Using `send`
  - [x] Using verbose styled transition via `{compoundStateName}Compound` field
  - [x] Multi-level (deeply nested) compound state
  - [x] Custom initialization on parent state creation
  - [x] Get a current state of nested state using `currentState`
    - `currentState.of(EnumType)` returns the current state of the nested state
  - [x] Reset on parent state enter/exit
  - [x] Reset on parent state reset
- [x] Support state change history
- [x] Support any state transition
  - [x] BeatStation with common `Beat` option
- [x] Support `state.matches` as a `is{State}`
- [x] Support `send()` styled transition
  - `station.send` is supported
- [x] Support initial context defined in the station annotation
- [ ] Support actions (fire-and-forget)
  - [x] callback action
  - [x] assign action
  - [x] callback action with variable length of arguments
  - [x] choose action
  - [ ] forwardTo action
  - [ ] log action
  - [ ] pure action
  - [ ] raise action
  - [ ] respond action
  - [ ] send action
- [ ] Support invoking services
  - [x] async function (or Future)
  - [x] onDone/onError actions
  - [ ] onDone/onError transitions
    - [x] to current station
    - [ ] to nested station
  - [ ] callback
  - [ ] observables
  - [ ] other beat station
  - [ ] multiple services
- [ ] Support instance options
  - [x] initial state, context
  - [ ] dynamically defined actions, services, delays, guards
- [x] Support eventless(always) transition
- [x] Support delayed transition
  - [x] Delay on eventless transition
  - [x] Delay on `send` or `$event()`
- [x] Support `entry` and `exit` actions
- [ ] Support conditional (guarded) transition
  - [x] Support custom functions
  - [ ] Support `in` state condition
- [ ] Support internal transition
- [ ] Support external transition
- [ ] Support Forbidden transition
- [ ] Support multiple targets
- [ ] Support multiple events
- [ ] Support actors
- [x] Support `state.nextEvents`
- [x] Support `state.changed`
- [x] Support `state.done`
- [ ] Support `state.meta`, `state.tags`
- [ ] Support `state.can`
- [ ] Support history JSON to persist
  - `toString()` is currently supported
- [ ] Support parallel state
  - [x] Define parallel state
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

# Additionals for flutter

- [ ] Support beat-station-friendly flutter widgets
- [ ] Inspect state, history, event history, next events, etc., from devtools widget inspector
- [ ] Support [`remix.run`](https://remix.run)'s concept
  - [ ] `loader`
  - [ ] `action` (side effect)
  - [ ] `ErrorBoundary`/`CatchBoundary`
- [ ] Support navigation

# Usage
