# Beat Station - State management with state machine

Heavily inspired by [xstate.js](https://xstate.js.org). 

Go to the [Beatly Book](https://book.beatly.dev/) for more information.

# Features compatible with xstate.js

- [x] Support simple state transition without context
- [x] Listen on transition
- [x] Map states
- [x] Execute callback on state change
- [x] Support reset
- [ ] Support context
	- [x] Initialize with context
	- [x] Get current context
	- [x] Support sync `assign`
	- [x] Support async `assign`
	- [x] Get current context
	- [ ] Get immutable current context
	- [ ] Support actor model
- [ ] Support transition with an argument for `assign`
- [ ] Support delay
- [ ] Support actions (fire-and-forget)
- [ ] Support `entry` and `exit` event
- [ ] Support conditional (guraded) transition
	- [ ] Support custom functions
	- [ ] Support `in` state condition
- [ ] Support Transient State Nodes
- [ ] Support external transition
- [x] Support any state transition
	- [x] BeatStation with common `Beat` option
- [ ] Support invoking services
- [ ] Support actors
- [ ] Support `state.matches` as a `is{State}`
- [x] Support `state.nextEvents`
- [ ] Support `state.changed`
- [x] Support `state.done`
- [ ] Support `state.meta`, `state.tags`
- [ ] Support state change history
- [ ] Support history json to persist 
- [ ] Support nested state
- [ ] Support parallel state
	- [ ] Define parallel state
	- [ ] Support multiple targets event
- [ ] State transition with side effect
- [ ] Support scxml
- [ ] Support stately.ai
- [ ] Support bootstraping
- [ ] Support CLI/GUI tools
- [ ] xstate.js compatible beat station

# Features not supported by this package but in xstate.js

- Final state is naturally defined which does not have any `Beat` annotation
- `state.toString()`: naturally supported
- `state.can(event)` is not needed because we have typed system
- wildcard transitions and forbidden transitions are not needed because there will be no typo


# Additionals for flutter

- [ ] Support beat-statation-friendly flutter widgets
- [ ] Support [`remix.run`](https://remix.run)'s concept
	- [ ] `loader`
	- [ ] `action` (side effect)
	- [ ] `ErrorBoundary`/`CatchBoundary`

# Usage