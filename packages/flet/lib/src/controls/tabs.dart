import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../flet_control_backend.dart';
import '../models/app_state.dart';
import '../models/control.dart';
import '../models/controls_view_model.dart';
import '../utils/alignment.dart';
import '../utils/borders.dart';
import '../utils/colors.dart';
import '../utils/edge_insets.dart';
import '../utils/icons.dart';
import '../utils/material_state.dart';
import '../utils/mouse.dart';
import '../utils/others.dart';
import '../utils/text.dart';
import 'create_control.dart';

class TabsControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final FletControlBackend backend;

  const TabsControl(
      {super.key,
      this.parent,
      required this.control,
      required this.children,
      required this.parentDisabled,
      required this.parentAdaptive,
      required this.backend});

  @override
  State<TabsControl> createState() => _TabsControlState();
}

class _TabsControlState extends State<TabsControl>
    with TickerProviderStateMixin {
  String? _tabsSnapshot;
  TabController? _tabController;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _tabController?.removeListener(_tabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _tabChanged() {
    if (_tabController!.indexIsChanging == true) {
      return;
    }
    var index = _tabController!.index;
    if (_selectedIndex != index) {
      debugPrint("Selected index: $index");
      widget.backend.updateControlState(
          widget.control.id, {"selectedindex": index.toString()});
      widget.backend
          .triggerControlEvent(widget.control.id, "change", index.toString());
      _selectedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("TabsControl build: ${widget.control.id}");
    bool disabled = widget.control.isDisabled || widget.parentDisabled;
    bool? adaptive =
        widget.control.attrBool("adaptive") ?? widget.parentAdaptive;

    // keep only visible tabs
    widget.children.retainWhere((c) => c.isVisible);

    var tabs = StoreConnector<AppState, ControlsViewModel>(
        distinct: true,
        converter: (store) => ControlsViewModel.fromStore(
            store, widget.children.map((c) => c.id)),
        builder: (content, viewModel) {
          var tabsSnapshot =
              viewModel.controlViews.map((c) => c.control.id).join();
          if (tabsSnapshot != _tabsSnapshot) {
            _tabsSnapshot = tabsSnapshot;

            if (_tabController != null) {
              _tabController!.removeListener(_tabChanged);
              _tabController!.dispose();
            }
            _tabController = TabController(
                length: viewModel.controlViews.length,
                animationDuration: Duration(
                    milliseconds:
                        widget.control.attrInt("animationDuration", 50)!),
                vsync: this);
            _tabController!.addListener(_tabChanged);
          }

          var selectedIndex = widget.control.attrInt("selectedIndex", 0)!;

          if (selectedIndex > -1 &&
              selectedIndex < _tabController!.length &&
              _selectedIndex != selectedIndex) {
            _selectedIndex = selectedIndex;
            _tabController!.index = selectedIndex;
          }

          // check if all tabs have no content
          bool emptyTabs = !viewModel.controlViews.any(
              (t) => t.children.any((c) => c.name == "content" && c.isVisible));

          var overlayColorStr = widget.control.attrString("overlayColor");
          dynamic overlayColor;
          if (overlayColorStr != null) {
            overlayColor = getWidgetStateProperty<Color?>(
                    json.decode(overlayColorStr),
                    (jv) => parseColor(Theme.of(context), jv as String)) ??
                TabBarTheme.of(context).overlayColor;
          }

          var indicatorBorderRadius =
              parseBorderRadius(widget.control, "indicatorBorderRadius");
          var indicatorBorderSide = parseBorderSide(
              Theme.of(context), widget.control, "indicatorBorderSide");
          var indicatorPadding =
              parseEdgeInsets(widget.control, "indicatorPadding");

          var indicatorColor =
              widget.control.attrColor("indicatorColor", context) ??
                  TabBarTheme.of(context).indicatorColor ??
                  Theme.of(context).colorScheme.primary;
          var labelColor = widget.control.attrColor("labelColor", context) ??
              TabBarTheme.of(context).labelColor ??
              Theme.of(context).colorScheme.primary;
          var unselectedLabelColor =
              widget.control.attrColor("unselectedLabelColor", context) ??
                  TabBarTheme.of(context).unselectedLabelColor ??
                  Theme.of(context).colorScheme.onSurface;
          var dividerColor =
              widget.control.attrColor("dividerColor", context) ??
                  TabBarTheme.of(context).dividerColor;

          var themeIndicator =
              TabBarTheme.of(context).indicator as UnderlineTabIndicator?;
          var indicatorTabSize = widget.control.attrBool("indicatorTabSize");
          var isScrollable = widget.control.attrBool("scrollable", true)!;
          var secondary = widget.control.attrBool("isSecondary", false)!;
          var dividerHeight = widget.control.attrDouble("dividerHeight");
          var enableFeedback = widget.control.attrBool("enableFeedback");
          var indicatorWeight =
              widget.control.attrDouble("indicatorThickness", 2.0)!;
          var tabAlignment = parseTabAlignment(
              widget.control.attrString("tabAlignment"),
              isScrollable ? TabAlignment.start : TabAlignment.fill)!;
          var mouseCursor =
              parseMouseCursor(widget.control.attrString("mouseCursor"));
          var clipBehavior = parseClip(
              widget.control.attrString("clipBehavior"), Clip.hardEdge)!;
          var padding = parseEdgeInsets(widget.control, "padding");
          var labelPadding = parseEdgeInsets(widget.control, "labelPadding");
          var labelStyle = parseTextStyle(
              Theme.of(context), widget.control, "labelTextStyle");
          var unselectedLabelStyle = parseTextStyle(
              Theme.of(context), widget.control, "unselectedLabelTextStyle");
          var splashBorderRadius =
              parseBorderRadius(widget.control, "splashBorderRadius");

          void onTap(int index) {
            widget.backend.triggerControlEvent(
                widget.control.id, "click", index.toString());
          }

          var indicator = indicatorBorderRadius != null ||
                  indicatorBorderSide != null ||
                  indicatorPadding != null
              ? UnderlineTabIndicator(
                  borderRadius: indicatorBorderRadius ??
                      themeIndicator?.borderRadius ??
                      const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2)),
                  borderSide: indicatorBorderSide ??
                      themeIndicator?.borderSide ??
                      BorderSide(
                          width: themeIndicator?.borderSide.width ?? 2,
                          color: themeIndicator?.borderSide.color ??
                              indicatorColor),
                  insets: indicatorPadding ??
                      themeIndicator?.insets ??
                      EdgeInsets.zero)
              : TabBarTheme.of(context).indicator;
          var indicatorSize = indicatorTabSize != null
              ? (indicatorTabSize
                  ? TabBarIndicatorSize.tab
                  : TabBarIndicatorSize.label)
              : TabBarTheme.of(context).indicatorSize;

          var tabs = viewModel.controlViews.map((tabView) {
            var iconString = parseIcon(tabView.control.attrString("icon"));
            var iconCtrls = tabView.children
                .where((c) => c.name == "icon" && c.isVisible);

            var icon = iconCtrls.isNotEmpty
                ? createControl(
                    widget.control, iconCtrls.first.id, disabled,
                    parentAdaptive: adaptive)
                : iconString != null
                    ? Icon(iconString)
                    : null;
            var tabContentCtrls = tabView.children
                .where((c) => c.name == "tab_content" && c.isVisible);

            if (tabContentCtrls.isNotEmpty) {
              return Tab(
                  child: createControl(
                      widget.control, tabContentCtrls.first.id, disabled,
                      parentAdaptive: adaptive));
            } else {
              return Tab(
                text: tabView.control
                    .attrString("text", icon == null ? "" : null),
                icon: icon,
                height: tabView.control.attrDouble("height"),
                iconMargin: parseEdgeInsets(tabView.control, "iconMargin"),
              );
            }
          }).toList();

          TabBar? tabBar;

          if (secondary) {
            tabBar = TabBar.secondary(
                tabAlignment: tabAlignment,
                controller: _tabController,
                isScrollable: isScrollable,
                dividerHeight: dividerHeight,
                enableFeedback: enableFeedback,
                mouseCursor: mouseCursor,
                indicatorWeight: indicatorWeight,
                dividerColor: dividerColor,
                indicatorSize: indicatorSize,
                indicator: indicator,
                indicatorColor: indicatorColor,
                labelColor: labelColor,
                unselectedLabelColor: unselectedLabelColor,
                overlayColor: overlayColor,
                tabs: tabs,
                padding: padding,
                labelPadding: labelPadding,
                labelStyle: labelStyle,
                unselectedLabelStyle: unselectedLabelStyle,
                splashBorderRadius: splashBorderRadius,
                indicatorPadding: indicatorPadding ?? EdgeInsets.zero,
                onTap: onTap);
          } else {
            tabBar = TabBar(
                tabAlignment: tabAlignment,
                controller: _tabController,
                isScrollable: isScrollable,
                dividerHeight: dividerHeight,
                enableFeedback: enableFeedback,
                mouseCursor: mouseCursor,
                indicatorWeight: indicatorWeight,
                dividerColor: dividerColor,
                indicatorSize: indicatorSize,
                indicator: indicator,
                indicatorColor: indicatorColor,
                labelColor: labelColor,
                unselectedLabelColor: unselectedLabelColor,
                overlayColor: overlayColor,
                tabs: tabs,
                padding: padding,
                labelPadding: labelPadding,
                labelStyle: labelStyle,
                unselectedLabelStyle: unselectedLabelStyle,
                splashBorderRadius: splashBorderRadius,
                indicatorPadding: indicatorPadding ?? EdgeInsets.zero,
                onTap: onTap);
          }

          debugPrint("tabs.length: ${tabBar.tabs.length}");

          if (emptyTabs) {
            return tabBar;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tabBar,
              Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      clipBehavior: clipBehavior,
                      children: viewModel.controlViews.map((tabView) {
                        var contentCtrls = tabView.children
                            .where((c) => c.name == "content" && c.isVisible);
                        if (contentCtrls.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return createControl(
                            widget.control, contentCtrls.first.id, disabled,
                            parentAdaptive: adaptive);
                      }).toList()))
            ],
          );
        });

    return constrainedControl(context, tabs, widget.parent, widget.control);
  }
}
