import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/theme/types/theme_extension.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text,
    {bool fab = false, bool navBar = false, bool error = false}) {
  ThemeData theme = Theme.of(context);
  ColorScheme colorScheme = theme.colorScheme;
  Color? color = error ? colorScheme.error : null;
  ThemeSettingExtension themeSettings =
      theme.extension<ThemeSettingExtension>()!;

  Duration duration =
      error ? const Duration(hours: 999) : const Duration(seconds: 4);
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(getSnackbar(text,
      fab: fab,
      navBar: navBar,
      color: color,
      useMaterialStyle: themeSettings.useMaterialStyle,
      duration: duration));
}

SnackBar getThemedSnackBar(BuildContext context, String text,
    {bool fab = false,
    bool navBar = false,
    Color? color,
    Duration duration = const Duration(seconds: 4)}) {
  ThemeData theme = Theme.of(context);
  ThemeSettingExtension themeSettings =
      theme.extension<ThemeSettingExtension>()!;

  return getSnackbar(text,
      fab: fab,
      navBar: navBar,
      color: color,
      useMaterialStyle: themeSettings.useMaterialStyle,
      duration: duration);
}

SnackBar getSnackbar(String text,
    {bool fab = false,
    bool navBar = false,
    bool useMaterialStyle = false,
    Color? color,
    Duration duration = const Duration(seconds: 4)}) {
  double left = 20;
  double right = 20;
  double bottom = 12;

  if (fab) {
    final leftHandedMode = appSettings
        .getGroup("Accessibility")
        .getSetting("Left Handed Mode")
        .value;
    if (leftHandedMode) {
      left = 64 + 16;
    } else {
      right = 64 + 16;
    }
  }

  if (navBar) {
    bottom = 4;
  }

  if (useMaterialStyle) {
    bottom += 20;
  }

  return SnackBar(
    content: Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      color: color,
      // height: 28,
      child: Text(text),
    ),
    margin: EdgeInsets.only(
      left: left,
      right: right,
      bottom: bottom,
    ),
    padding: EdgeInsets.zero,
    elevation: 2,
    dismissDirection: DismissDirection.vertical,
    duration: duration,
  );
}
