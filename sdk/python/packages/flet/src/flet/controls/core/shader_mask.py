from flet.controls.base_control import control
from flet.controls.border_radius import OptionalBorderRadiusValue
from flet.controls.constrained_control import ConstrainedControl
from flet.controls.control import OptionalControl
from flet.controls.gradients import Gradient
from flet.controls.types import BlendMode

__all__ = ["ShaderMask"]


@control("ShaderMask")
class ShaderMask(ConstrainedControl):
    """
    A control that applies a mask generated by a shader to its child.

    For example, ShaderMask can be used to gradually fade out the edge of a child by
    using a `LinearGradient` mask.

    Online docs: https://flet.dev/docs/controls/shadermask
    """

    shader: Gradient
    """
    Use gradient as a shader.

    Value is of type [`Gradient`](https://flet.dev/docs/reference/types/gradient).
    """

    content: OptionalControl = None
    """
    A child `Control` to apply a shader to.
    """

    blend_mode: BlendMode = BlendMode.MODULATE
    """
    The blend mode to use when applying the shader to the `content`.

    Value is of type [`BlendMode`](https://flet.dev/docs/reference/types/blendmode) and
    defaults to `BlendMode.MODULATE`.
    """

    border_radius: OptionalBorderRadiusValue = None
    """
    The radius of the mask.

    Value is of type [`BorderRadius`](https://flet.dev/docs/reference/types/borderradius).
    """

