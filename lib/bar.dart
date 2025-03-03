library bar;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:modern_titlebar_buttons/modern_titlebar_buttons.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
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
  final double barHeight;

  const TitleBar({
    super.key,
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
    this.onClose,
    this.barHeight = 32.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    PlatformTheme type = theme ?? _defaultPlatformTheme;
    Color bg = color ?? Color(0xFF000000).withOpacity(0.95);
    Color surface = surfaceColor ?? Color(0xFFFFFFFF);

    return GestureDetector(
      onPanStart: (details) => onStartDragging?.call(),
      child: Container(
        color: bg,
        height: barHeight,
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
                  onUnMaximize: onUnMaximize,
                  isMaximized: isMaximized,
                  onClose: onClose,
                  color: surface,
                  theme: type,
                ),
              ],
              PlatformTheme.mac => [
                Expanded(
                  child: TitleBarButtons(
                    onMinimize: onMinimize,
                    onMaximize: onMaximize,
                    onUnMaximize: onUnMaximize,
                    isMaximized: isMaximized,
                    onClose: onClose,
                    color: surface,
                    theme: type,
                  ),
                ),
                if (leading != null) leading!,
                title,
                const Spacer(),
              ],
            },
          ),
        ),
      ),
    );
  }
}

class TitleBarButtons extends StatefulWidget {
  final Color color;
  final PlatformTheme? theme;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;
  final VoidCallback? onUnMaximize;
  final Future<bool> Function()? isMaximized;

  const TitleBarButtons({
    super.key,
    this.theme,
    required this.color,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
    this.onUnMaximize,
    this.isMaximized,
  });

  @override
  State<TitleBarButtons> createState() => _TitleBarButtonsState();
}

class _TitleBarButtonsState extends State<TitleBarButtons> {
  bool _isCurrentlyMaximized = false;

  @override
  Widget build(BuildContext context) {
    PlatformTheme type = widget.theme ?? _defaultPlatformTheme;

    Future<void> _handleMaximizeToggle() async {
      if (widget.isMaximized != null) {
        final isMax = await widget.isMaximized!();
        setState(() {
          _isCurrentlyMaximized = isMax;
        });

        if (isMax) {
          widget.onUnMaximize?.call();
        } else {
          widget.onMaximize?.call();
        }
      } else {
        // If isMaximized callback isn't provided, toggle based on internal state
        setState(() {
          _isCurrentlyMaximized = !_isCurrentlyMaximized;
        });

        if (_isCurrentlyMaximized) {
          widget.onMaximize?.call();
        } else {
          widget.onUnMaximize?.call();
        }
      }
    }

    List<Widget> buttons = [
      DecoratedMinimizeButton(
        type: type.toThemeType(),
        onPressed: widget.onMinimize,
      ),
      DecoratedMaximizeButton(
        type: type.toThemeType(),
        onPressed: _handleMaximizeToggle,
      ),
      DecoratedCloseButton(
        type: type.toThemeType(),
        onPressed: () {
          if (widget.onClose != null) {
            widget.onClose!();
          }
        },
      ),
    ];

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: switch (type) {
        PlatformTheme.windows => buttons,
        PlatformTheme.mac => [buttons[2], buttons[0], buttons[1]],
      },
    );

    return type.isColorFiltered
        ? ColorFiltered(
          colorFilter: ColorFilter.mode(widget.color, BlendMode.srcATop),
          child: row,
        )
        : row;
  }
}

PlatformTheme get _defaultPlatformTheme =>
    kIsWeb
        ? PlatformTheme.windows
        : Platform.isWindows
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
  }

  bool get isColorFiltered => this == PlatformTheme.windows;

  bool get isReversed => this == PlatformTheme.mac;
}
