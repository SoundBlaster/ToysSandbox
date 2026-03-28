# Inertia Dragging Manual (Godot 4, 2D)

Implementing drag-and-release with inertia in Godot 2D (specifically Godot 4) involves capturing the object, updating its position to follow the mouse, calculating the velocity based on the movement speed upon release, and then allowing the physics engine to handle the deceleration.

Here are the most common approaches.

## Method 1: Using `RigidBody2D` (Best for Physics & Inertia)

`RigidBody2D` is the best choice for automatic inertia, friction, and bouncing. To drag it, you must temporarily change its mode so it doesn't fight the mouse movement.

- **Scene Setup:** `RigidBody2D -> CollisionShape2D & Sprite2D`
- **Configuration:** Set `input_pickable` to `true` in the `RigidBody2D` inspector.

### Script

```gdscript
extends RigidBody2D

var dragging = false

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            freeze = true # Disable physics while dragging
        else:
            dragging = false
            freeze = false
            # Apply impulse based on mouse speed upon release
            apply_central_impulse(get_last_mouse_speed())

func _physics_process(delta):
    if dragging:
        # Smoothly move to mouse position
        global_position = get_global_mouse_position()

# Optional: Helper to get velocity
func get_last_mouse_speed():
    return Input.get_last_mouse_velocity()
```

## Method 2: Using `Area2D` / `Node2D` (Custom Inertia)

If you want total control over how the object slows down, use an `Area2D` and interpolate the velocity manually.

- **Setup:** `Area2D -> Sprite2D & CollisionShape2D`

### Script

```gdscript
extends Area2D

var dragging = false
var velocity = Vector2.ZERO
var friction = 10.0 # Adjust for faster/slower stop

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if not event.pressed:
            dragging = false

func _process(delta):
    if dragging:
        var mouse_pos = get_global_mouse_position()
        velocity = (mouse_pos - global_position) / delta
        global_position = mouse_pos
    else:
        # Apply inertia/friction
        position += velocity * delta
        velocity = velocity.move_toward(Vector2.ZERO, friction)

func _on_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        dragging = true
```

## Key Techniques for Better Feel

- **Velocity Calculation:** When releasing, use `Input.get_last_mouse_velocity()` to determine throw speed.
- **Friction & Damping:** In `RigidBody2D`, increase `Linear Damp` to make the object stop faster.
- **Switching Modes:** Always freeze a `RigidBody2D` (set to `FREEZE_MODE_KINEMATIC`) while dragging, otherwise it may behave erratically during collisions.
- **Drag Position:** To avoid snapping object center to the mouse, calculate offset on click and add it during position updates.
