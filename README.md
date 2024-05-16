## Features

* Title bar for desktop applications

## Usage

```dart
import 'package:window_manager/window_manager.dart';
import 'package:bar/bar.dart';

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});
  
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TitleBar(
          title: Text("My App"),
          leading: Icon(Icons.menu),
          surfaceColor: Colors.white,
          color: Colors.black,
          theme: PlatformTheme.mac,
          onMaximize: () => windowManager.maximize(),
          onClose: () => windowManager.close(),
          onStartDragging: () => windowManager.startDragging(),
          onUnMaximize: () => windowManager.unMaximize(),
          isMaximized: () => windowManager.isMaximized(),
      ),
      Expanded(
        child: MaterialApp(),
      ),
    ],
  );
}
```