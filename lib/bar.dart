library bar;

import 'package:flutter/material.dart';
import 'package:modern_titlebar_buttons/modern_titlebar_buttons.dart';
import 'package:universal_io/io.dart';

class TitleBar extends StatelessWidget {
  final PlatformTheme? theme;
  final Widget? leading;
  final Widget title;
  final Color? color;
  final Color? surfaceColor;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;
  final VoidCallback? onStartDragging;
  final VoidCallback? onUnMaximize;
  final Future<bool> Function()? isMaximized;

  const TitleBar(
      {super.key,
      this.leading,
      required this.title,
      this.theme,
      this.color,
      this.surfaceColor,
      this.onMinimize,
      this.onMaximize,
      this.onStartDragging,
      this.isMaximized,
      this.onUnMaximize,
      this.onClose});

  @override
  Widget build(BuildContext context) {
    PlatformTheme type = theme ?? _defaultPlatformTheme;
    Color bg = color ?? Colors.black.withOpacity(0.95);
    Color surface = surfaceColor ?? Colors.white70;

    return Directionality(
        textDirection: TextDirection.ltr,
        child: GestureDetector(
          onPanStart: (dsd) => onStartDragging?.call(),
          child: Container(
            decoration: BoxDecoration(color: color),
            child: Padding(
              padding: const EdgeInsets.only(left: 7, top: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: switch (type) {
                  PlatformTheme.windows => [
                      if (leading != null) leading!,
                      title,
                      const Spacer(),
                      TitleBarButtons(
                        onMinimize: onMinimize,
                        onMaximize: onMaximize,
                        onClose: onClose,
                        color: surface,
                        theme: type,
                      )
                    ],
                  PlatformTheme.mac => [
                      Expanded(
                          child: TitleBarButtons(
                        onMinimize: onMinimize,
                        onMaximize: onMaximize,
                        onClose: onClose,
                        color: surface,
                        theme: type,
                      )),
                      if (leading != null) leading!,
                      title,
                      const Spacer(),
                    ]
                },
              ),
            ),
          ),
        ));
  }
}

class TitleBarButtons extends StatelessWidget {
  final Color color;
  final PlatformTheme? theme;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;
  final VoidCallback? onUnMaximize;
  final Future<bool> Function()? isMaximized;

  const TitleBarButtons(
      {super.key,
      this.theme,
      required this.color,
      this.onMinimize,
      this.onMaximize,
      this.onClose,
      this.onUnMaximize,
      this.isMaximized});

  @override
  Widget build(BuildContext context) {
    PlatformTheme type = theme ?? _defaultPlatformTheme;

    List<Widget> w = [
      DecoratedMinimizeButton(
          type: type.toThemeType(), onPressed: () => onMinimize?.call()),
      DecoratedMaximizeButton(
          type: type.toThemeType(),
          onPressed: () => (isMaximized?.call() ?? Future.value(false)).then(
              (value) => value ? onUnMaximize?.call() : onMaximize?.call())),
      DecoratedCloseButton(
          type: type.toThemeType(), onPressed: () => onClose?.call()),
    ];

    Widget r = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: switch (type) {
        PlatformTheme.windows => [w[0], w[1], w[2]],
        PlatformTheme.mac => [w[2], w[0], w[1]],
      },
    );

    return type.isColorFiltered
        ? ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
            child: r,
          )
        : r;
  }
}

PlatformTheme get _defaultPlatformTheme => Platform.isWindows
    ? PlatformTheme.windows
    : Platform.isMacOS
        ? PlatformTheme.mac
        : PlatformTheme.windows;

enum PlatformTheme { windows, mac }

extension XPlatformTheme on PlatformTheme {
  ThemeType toThemeType() {
    switch (this) {
      case PlatformTheme.windows:
        return ThemeType.auto;
      case PlatformTheme.mac:
        return ThemeType.osxArc;
    }

    return ThemeType.adwaita;
  }

  bool get isColorFiltered => this == PlatformTheme.windows;

  bool get isReversed => this == PlatformTheme.mac;
}
