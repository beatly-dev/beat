## 0.13.5

 - **FEAT**: Invoke's `onError` can receive thrown error.

## 0.13.4+2

 - **FIX**: bugs on refactored code.

## 0.13.4+1

 - **REFACTOR**: clean up code.

## 0.13.4

 - **FEAT**: support conditions on transition (`Beat`).

## 0.13.3

 - **FEAT**: support extendable actions.

## 0.13.2

 - **FEAT**: access to nested state using `currentState.of`.

## 0.13.1

 - **FIX**: bugs in state matcher.
 - **FIX**: a bug in `resetState` method.
 - **FIX**: restore accidentally removed event name refiner.
 - **FEAT**: support nested listeners.
 - **FEAT**: support context change listener.

## 0.13.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: support delayed transition triggers.

## 0.12.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: rename the state matcher.

## 0.11.2

 - **FEAT**: support `EventlessBeat` with delay.

## 0.11.1+1

 - **FIX**: don't need to clean before build.

## 0.11.1

 - **FEAT**: support predefined annotations.

## 0.11.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: invoking services in proper places.

## 0.10.0+3

 - Update a dependency to the latest release.

## 0.10.0+2

- Update dependency to match flutter sdk

## 0.10.0+1

- Update dependencies

## 0.10.0

> Note: This release has breaking changes.

- **REFACTOR**: method name.
- **REFACTOR**: invoke variable name.
- **REFACTOR**: BeatState has an explicit state type.
- **REFACTOR**: change context type arg.
- **REFACTOR**: rename transition fields.
- **REFACTOR**: route from root to leaf node.
- **REFACTOR**: prepare for parallel state.
- **REFACTOR**: improve first matching list.
- **REFACTOR**: force state to be enum.
- **REFACTOR**: use `BaseBeatState`.
- **FIX**: get currentState.
- **FIX**: station constructor error.
- **FIX**: prevent method name duplication.
- **FIX**: Accurately get annotations.
- **FIX**: find first enum constant.
- **FEAT**: Support Sender-styled transitions.
- **FEAT**: start/stop station.
- **FEAT**: nested state matcher.
- **FEAT**: invoking services.
- **FEAT**: beat transition supported with new code.
- **FEAT**: refine unappropriate characters from event.
- **FEAT**: generate invoke declaration.
- **FEAT**: generate beat const declarations.
- **FEAT**: notifications.
- **FEAT**: Station with constructor, listener, exec, map.
- **FEAT**: generating BeatState class with infinite nesting.
- **FEAT**: reset tree on rebuild, get enum related nodes.
- **BREAKING** **FEAT**: state matcher works as expected.

## 0.9.0

> Note: This release has breaking changes.

- **BREAKING** **REFACTOR**: refactor all to support infinite nesting.

## 0.8.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: WIP - Building beatly's own generator.

## 0.7.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: Compound State arrived!

## 0.6.6

- **FEAT**: adding sender styled event trigger.

## 0.6.5+1

- Update a dependency to the latest release.

## 0.6.5

- **FEAT**: transition onDone/onError.

## 0.6.4

- **REFACTOR**: action executor.
- **FEAT**: support onDone/onError on invoke async.

## 0.6.3

- **FEAT**: invoking async.

## 0.6.2+1

- **FIX**: fix a clear history bug.

## 0.6.2

- **FEAT**: add `map`/`exec`.

## 0.6.1+2

- **FIX**: fix dynamic transition argument error.

## 0.6.1+1

- **FIX**: fix to dynamic code generation.

## 0.6.1

- **FEAT**: support resetState, clearState.

## 0.6.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: action with argument, variable length args of action.

## 0.5.4

- **FEAT**: support function action.

## 0.5.3

- **FEAT**: support callback style AssignAction.

## 0.5.2

- **REFACTOR**: scoping.
- **FEAT**: common transitions actions.

## 0.5.1

- **FEAT**: support default action.

## 0.5.0

> Note: This release has breaking changes.

- **REFACTOR**: remove unnecessary fields.
- **REFACTOR**: add createClass helper function.
- **FEAT**: prevent state changes when its not appropriate.
- **BREAKING** **FEAT**: refactor beat annotation declaration.

## 0.4.1

- **FEAT**: support common (anytime) transition.

## 0.4.0

> Note: This release has breaking changes.

- **FIX**: add removeListener.
- **FEAT**: add toString() method on BeatState.
- **BREAKING** **REFACTOR**: remove code_builder, remove assigner.

## 0.3.1

- **FEAT**: support `nextEvents` and `done`.

## 0.3.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: `assign` can be both of sync and async.

## 0.2.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: async assigner.

## 0.1.4

- **REFACTOR**: change string name to enum.
- **FEAT**: common beats can be accessed directly.

## 0.1.3+1

- **FIX**: add condition on when/map helpers.

## 0.1.3

- **REFACTOR**: separate builders.
- **FIX**: remove void/Null context field.
- **FEAT**: Support common state transition (`any`time).

## 0.1.2+1

- **FIX**: **BREAKING CHANGES** remove generic from station and add contextType param.

## 0.1.2

- **FEAT**: Initial support for context.

## 0.1.1+1

- Update a dependency to the latest release.

## 0.1.1

- **FEAT**: first draft - attach/detach/when/map methods.

## 0.1.0

- Initial version.
