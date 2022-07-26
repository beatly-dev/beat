# Beat Station - State management with state machine

Heavily inspired by [xstate.js](https://xstate.js.org). 

Go to the [Beatly Book](https://book.beatly.dev/) for more information.

# Roadmap - Features compatible with xstate.js

- [x] Support simple state transition without context
- [x] Listen on transition
- [x] Map states
- [x] Execute callback on state change
- [ ] Support reset
- [ ] Support context
	- [x] Initialize with context
	- [x] Get current context
	- [ ] assign new context
- [ ] Support transition with an argument
- [ ] Support delay
- [ ] Support actions (fire-and-forget)
	- [x] callback action
	- [ ] assign action
	- [ ] choose action
	- [ ] forwardTo action
	- [ ] log action
	- [ ] pure action
	- [ ] raise action
	- [ ] respond action
	- [ ] send action
- [ ] Support invoking services
	- [ ] promises
	- [ ] callback
	- [ ] observables
	- [ ] other beat station
	- [ ] multiple services
- [ ] Support `entry` and `exit` event
- [ ] Support conditional (guarded) transition
	- [ ] Support custom functions
	- [ ] Support `in` state condition
- [ ] Support eventless transition
- [ ] Support internal transition
- [ ] Support external transition
- [ ] Support multiple targets
- [x] Support any state transition
	- [x] BeatStation with common `Beat` option
- [ ] Support actors
- [x] Support `state.matches` as a `is{State}`
- [ ] Support `state.nextEvents`
- [ ] Support `state.changed`
- [ ] Support `state.done`
- [ ] Support `state.meta`, `state.tags`
- [x] Support state change history
- [ ] Support history json to persist 
- [ ] Support nested state
- [ ] Support parallel state
	- [ ] Define parallel state
	- [ ] Support multiple targets event
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