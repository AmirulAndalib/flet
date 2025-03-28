import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../flet_control_backend.dart';
import '../models/control.dart';
import '../utils/borders.dart';
import '../utils/colors.dart';
import '../utils/mouse.dart';
import '../utils/others.dart';
import 'create_control.dart';
import 'list_tile.dart';

class CupertinoCheckboxControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;
  final FletControlBackend backend;

  const CupertinoCheckboxControl(
      {super.key,
      this.parent,
      required this.control,
      required this.parentDisabled,
      required this.backend});

  @override
  State<CupertinoCheckboxControl> createState() => _CheckboxControlState();
}

class _CheckboxControlState extends State<CupertinoCheckboxControl> {
  bool? _value;
  bool _tristate = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    widget.backend.triggerControlEvent(
        widget.control.id, _focusNode.hasFocus ? "focus" : "blur");
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleValue() {
    bool? newValue;
    if (!_tristate) {
      newValue = !_value!;
    } else if (_tristate && _value == null) {
      newValue = false;
    } else if (_tristate && _value == false) {
      newValue = true;
    }
    _onChange(newValue);
  }

  void _onChange(bool? value) {
    var svalue = value != null ? value.toString() : "";
    _value = value;
    widget.backend.updateControlState(widget.control.id, {"value": svalue});
    widget.backend.triggerControlEvent(widget.control.id, "change", svalue);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("CupertinoCheckBox build: ${widget.control.id}");
    bool disabled = widget.control.isDisabled || widget.parentDisabled;

    String label = widget.control.attrString("label", "")!;
    LabelPosition labelPosition = parseLabelPosition(
        widget.control.attrString("labelPosition"), LabelPosition.right)!;
    _tristate = widget.control.attrBool("tristate", false)!;
    bool autofocus = widget.control.attrBool("autofocus", false)!;

    bool? value = widget.control.attrBool("value", _tristate ? null : false);
    if (_value != value) {
      _value = value;
    }

    var cupertinoCheckbox = CupertinoCheckbox(
        autofocus: autofocus,
        focusNode: _focusNode,
        value: _value,
        activeColor: parseColor(Theme.of(context),
            widget.control.attrString("activeColor", "primary")!),
        checkColor: widget.control.attrColor("checkColor", context),
        focusColor: widget.control.attrColor("focusColor", context),
        shape: parseOutlinedBorder(widget.control, "shape"),
        mouseCursor: parseMouseCursor(widget.control.attrString("mouseCursor")),
        semanticLabel: widget.control.attrString("semanticsLabel"),
        side: parseWidgetStateBorderSide(
            Theme.of(context), widget.control, "borderSide"),
        fillColor: parseWidgetStateColor(
            Theme.of(context), widget.control, "fillColor"),
        tristate: _tristate,
        onChanged: !disabled
            ? (bool? value) {
                _onChange(value);
              }
            : null);

    ListTileClicks.of(context)?.notifier.addListener(() {
      _toggleValue();
    });

    Widget result = cupertinoCheckbox;
    if (label != "") {
      var labelWidget = disabled
          ? Text(label,
              style: TextStyle(color: Theme.of(context).disabledColor))
          : MouseRegion(cursor: SystemMouseCursors.click, child: Text(label));
      result = MergeSemantics(
          child: GestureDetector(
              onTap: !disabled ? _toggleValue : null,
              child: labelPosition == LabelPosition.right
                  ? Row(children: [cupertinoCheckbox, labelWidget])
                  : Row(children: [labelWidget, cupertinoCheckbox])));
    }

    return constrainedControl(context, result, widget.parent, widget.control);
  }
}
