# GodotBT: Behavior Tree Framework API Documentation

## Core Classes

### BehaviorTree

The main class that manages the execution of the behavior tree.

**Properties:**

- `_is_enabled: bool`: Whether the behavior tree is enabled

**Methods:**

- `request_abort(requestor: BTNode, abort_scope: int, ctx: BTContext)`: Request an abort operation
- `get_current_context() -> BTContext`: Get the current context
- `register_context(ctx: BTContext)`: Register a context with all nodes
- `tick(ctx: BTContext, delta: float)`: Tick the behavior tree
- `create_context(agent: Object, blackboard: Blackboard) -> BTContext`: Create a new context

**Enums:**

- `BTAbortScope`:
  - `SELF`: Only abort the requesting node
  - `SUB_BRANCH`: Abort the requestor and its children
  - `LOWER_BRANCH`: Abort nodes with lower priority
  - `LOWER_PRIORITY`: Abort all nodes with lower priority
  - `SIBLING_BRANCH`: Abort sibling branches
  - `ALL`: Abort all running nodes

### BTNode

Base class for all behavior tree nodes.

**Properties:**

- `_is_enabled: bool`: Whether the node is enabled
- `_conditions: Array[BTCondition]`: Conditions that determine if the node should execute
- `_condition_type: ConditionType`: How to evaluate multiple conditions
- `_tick_conditions_when_running: bool`: Whether to check conditions while running
- `_services: Array[BTService]`: Services attached to the node
- `_tick_services_when_running: bool`: Whether to tick services while running
- `_decorators: Array[BTDecorator]`: Decorators attached to the node

**Methods:**

- `setup(owning_tree: BehaviorTree) -> void`: Set up the node with its behavior tree
- `register_context(ctx: BTContext)`: Register with a context
- `get_current_context() -> BTContext`: Get the current context
- `tick(ctx: BTContext) -> BTResult`: Tick the node
- `_tick(ctx: BTContext) -> BTResult`: Virtual method to override with node logic
- `_post_tick(ctx: BTContext, result: BTResult) -> void`: Called after node is ticked

**Enums:**

- `BTResult`:
  - `SUCCESS`: Node completed successfully
  - `RUNNING`: Node is still running
  - `FAILURE`: Node failed
  - `ABORTED`: Node was aborted
- `ConditionType`:
  - `ALL`: All conditions must be true
  - `ANY`: At least one condition must be true

### BTContext

Maintains the state of execution for a specific entity.

**Properties:**

- `agent: Object`: The owning agent
- `blackboard: Blackboard`: The blackboard used for data sharing
- `custom_data: Dictionary`: Additional data that can be used by the implementation
- `current: BTNode`: Currently ticking node
- `elapsed_time: float`: Time elapsed since tree started
- `delta: float`: Delta time for current tick
- `running_history: Array[BTNode]`: History of running nodes
- `abort_issued: bool`: Whether an abort was issued

**Methods:**

- `get_running_or_current() -> BTNode`: Get the node that is currently running or the current node
- `get_running_data(obj: Object) -> Dictionary`: Get data specific to a running node
- `get_persistent_data(obj: Object) -> Dictionary`: Get data that persists between ticks
- `clear_running_data()`: Clear running data and history
- `clear_persistent_data()`: Clear all persistent data
- `is_running() -> bool`: Return whether there are any running nodes

### Blackboard

Stores shared data accessible by all nodes in the tree.

**Properties:**

- `_values: Dictionary`: Dictionary of values stored in the blackboard

**Methods:**

- `copy_from(other: Blackboard)`: Copy values from another blackboard
- `get_values() -> Dictionary`: Returns a copy of the values in the blackboard
- `set_values(new_values: Dictionary)`: Set multiple values at once
- `toggle_bool(key: StringName)`: Toggle a boolean value
- `negate(key: StringName)`: Negate a value
- `increment_number(key: StringName, amount: float = 1.0)`: Increment a numeric value
- `increment_vector(key: StringName, to := Vector2.ONE, amount := 1.0)`: Increment a vector value
- `increment_vector3(key: StringName, to := Vector3.ONE, amount := 1.0)`: Increment a Vector3 value
- `get_bool(key: StringName) -> bool`: Get a boolean value
- `get_int(key: StringName) -> int`: Get an integer value
- `get_vector(key: StringName) -> Vector2`: Get a vector value
- `get_vector3(key: StringName) -> Vector3`: Get a Vector3 value
- `get_string(key: StringName) -> String`: Get a string value
- `get_string_name(key: StringName) -> StringName`: Get a string name value
- `get_float(key: StringName) -> float`: Get a float value
- `get_node(key: StringName) -> Node`: Get a node value
- `get_array(key: StringName) -> Array`: Get an array value
- `get_dictionary(key: StringName) -> Dictionary`: Get a dictionary value
- `get_type(key: StringName) -> Variant.Type`: Get the type of a value
- `is_zero_or_empty(key: StringName) -> bool`: Check if a value is zero or empty
- `compare_entries(key1: StringName, key2: StringName) -> bool`: Compare two blackboard entries
- `clear()`: Clear all values
- `remove_key(key: StringName)`: Remove a key
- `get_keys() -> Array`: Get all keys
- `get_entries_as_string() -> String`: Get a string representation of all entries
- `set_value(key: StringName, value: Variant = null)`: Set a value
- `get_value(key: StringName, default: Variant = null) -> Variant`: Get a value
- `has_key(key: StringName) -> bool`: Check if a key exists

**Signals:**

- `value_changed(key: StringName, value: Variant)`: Emitted when a value changes

## Composite Nodes

### BTComposite

Base class for nodes that can have children.

**Properties:**

- `_children: Array[BTNode]`: Children nodes of this composite
- `_offset: int`: Offset to start ticking from

### BTSelector

Runs child nodes in order until one succeeds or all fail.

**Description:**
Returns SUCCESS if any child succeeds, FAILURE if all children fail, or RUNNING if a child is still running.

### BTSequence

Runs child nodes in order until one fails or all succeed.

**Description:**
Returns SUCCESS if all children succeed, FAILURE if any child fails, or RUNNING if a child is still running.

### BTParallel

Runs all child nodes simultaneously.

**Properties:**

- `_complete_target: BTNode`: Optional node that determines when to complete

**Description:**
By default, returns RUNNING until \_complete_target finishes. If \_complete_target is not set, it will run forever.

### BTRandomComposite

Base class for random composites.

**Methods:**

- `_get_execution_range(ctx: BTContext) -> Array`: Get the range of children to execute

### BTRandomSelector

Runs child nodes in random order until one succeeds or all fail.

**Description:**
Similar to BTSelector but executes children in a random order.

### BTRandomSequence

Runs child nodes in random order until one fails or all succeed.

**Description:**
Similar to BTSequence but executes children in a random order.

## Task Nodes

### BTTask

Base class for all leaf nodes (tasks).

**Description:**
Tasks perform the actual work in a behavior tree. Extend this class to create custom tasks.

### BTWait

Wait for a specified amount of time.

**Properties:**

- `_wait_time: float`: How long to wait in seconds

**Description:**
Returns RUNNING while waiting, SUCCESS when done.

## Decorators

### BTDecorator

Base class for decorators.

**Methods:**

- `register_context(ctx: BTContext)`: Register with a context
- `tick(ctx: BTContext, result: BTNode.BTResult) -> BTNode.BTResult`: Process a result from a child node

**Description:**
Decorators modify the result of a child node.

### BTInverter

Inverts the result of a child node.

**Description:**
SUCCESS becomes FAILURE and vice versa. RUNNING remains RUNNING.

### BTRepeater

Repeats a child execution a specified number of times.

**Properties:**

- `_repeat_num: int`: Number of times to repeat the child node

**Description:**
Returns RUNNING until all repetitions complete, then returns the child's result.

### BTRepeatUntil

Repeats child execution until it returns the expected result.

**Properties:**

- `_expected_result: int`: The result that should cause the repeating to stop

**Description:**
Returns RUNNING until the expected result is achieved.

### BTAlwaysReturn

Always returns a specific result regardless of the child's result.

**Properties:**

- `_return_value: int`: The result to always return

**Description:**
Will still return RUNNING if the child is running.

## Conditionals

### BTCondition

Base class for conditions.

**Properties:**

- `_is_enabled: bool`: Whether the condition is enabled
- `_flip: bool`: Whether to invert the result
- `_attached_node: BTNode`: The node this conditional is attached to

**Methods:**

- `setup(attached_node: BTNode)`: Set up the conditional with its attached node
- `register_context(ctx: BTContext)`: Register with a context
- `tick(ctx: BTContext) -> bool`: Evaluate the condition
- `_tick(ctx: BTContext) -> bool`: Virtual method to override with condition logic

### BTReactiveCondition

Condition that can trigger aborts.

**Properties:**

- `_abort_trigger: AbortTrigger`: When to trigger an abort
- `_abort_scope: BehaviorTree.BTAbortScope`: What scope to abort

**Methods:**

- `_reevaluate(ctx: BTContext)`: Reevaluate the condition and potentially trigger an abort

**Enums:**

- `AbortTrigger`:
  - `NONE`: Never abort
  - `ON_REEVALUATED`: Abort whenever reevaluated
  - `ON_RESULT_CHANGED`: Abort when result changes
  - `ON_RESULT_TRUE`: Abort when result becomes true
  - `ON_RESULT_FALSE`: Abort when result becomes false

**Signals:**

- `abort_requested(node: BTNode, abort_scope: BehaviorTree.BTAbortScope, ctx: BTContext)`: Emitted when an abort is requested

### BTBlackboardBasedCondition

Condition based on blackboard values.

**Properties:**

- `_key_query: KeyQuery`: The type of query to perform
- `_key: StringName`: The key to check

**Enums:**

- `KeyQuery`:
  - `IS_SET`: Check if key exists
  - `IS_NOT_SET`: Check if key doesn't exist

### BTCheckNonZeroBBEntry

Checks if a blackboard value is non-zero or non-empty.

**Description:**
Returns true if the value exists and is not zero/empty, false otherwise.

### BTCompareBBEntries

Compares two blackboard entries.

**Properties:**

- `_comparison: Comparison`: The type of comparison to perform
- `_other_key: StringName`: The key to compare against

**Enums:**

- `Comparison`:
  - `IS_EQUAL`: Check if values are equal
  - `IS_NOT_EQUAL`: Check if values are not equal

**Description:**
Returns true if the comparison is met, false otherwise.

## Services

### BTService

Base class for services.

**Properties:**

- `_is_enabled: bool`: Whether the service is active
- `_frequency: float`: How often to tick this service (in seconds)
- `_variation: float`: Random variation to add to frequency (0-1 multiplier)
- `_skip_first: bool`: Whether to skip the first tick

**Methods:**

- `register_context(ctx: BTContext)`: Register with a context
- `tick(ctx: BTContext)`: Tick the service if it's time
- `_tick(ctx: BTContext)`: Virtual method to override with service logic

**Signals:**

- `ticked()`: Emitted when the service ticks

## Utility Classes

### BTTargetKey

Utility class to get target information from the blackboard.

**Properties:**

- `targeting_mode: TargetingMode`: How to interpret the target key
- `target_key: StringName`: The key in the blackboard that holds the target

**Methods:**

- `get_target_direction(ctx: BTContext) -> Vector2`: Get the direction to the target
- `get_target_distance(ctx: BTContext) -> float`: Get the distance to the target
- `get_target_position(ctx: BTContext) -> Vector2`: Get the target position

**Enums:**

- `TargetingMode`:
  - `DIRECTION`: The key contains a direction vector
  - `POSITION`: The key contains a position vector
  - `NODE`: The key contains a Node2D reference
