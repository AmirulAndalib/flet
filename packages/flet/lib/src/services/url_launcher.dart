import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../flet_service.dart';
import '../utils/launch_url.dart';
import '../utils/numbers.dart';

class UrlLauncherService extends FletService {
  UrlLauncherService({required super.control});

  @override
  void init() {
    super.init();
    debugPrint("UrlLauncherService(${control.id}).init: ${control.properties}");
    control.addInvokeMethodListener(_invokeMethod);
  }

  @override
  void update() {
    debugPrint(
        "UrlLauncherService(${control.id}).update: ${control.properties}");
  }

  Future<dynamic> _invokeMethod(String name, dynamic args) async {
    debugPrint("UrlLauncherService.$name($args)");
    switch (name) {
      case "launch_url":
        return openWebBrowser(args["url"]!,
            webWindowName: args["web_window_name"],
            webPopupWindow: parseBool(args["web_popup_window"]),
            windowWidth: parseInt(args["window_width"]),
            windowHeight: parseInt(args["window_height"]));
      case "can_launch_url":
        return canLaunchUrl(Uri.parse(args["url"]!));
      case "close_in_app_web_view":
        return closeInAppWebView();
      default:
        throw Exception("Unknown UrlLauncher method: $name");
    }
  }

  @override
  void dispose() {
    debugPrint("UrlLauncherService(${control.id}).dispose()");
    control.removeInvokeMethodListener(_invokeMethod);
    super.dispose();
  }
}
