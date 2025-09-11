import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final Widget externalContainer;

  const ContainerWidget({super.key, required this.externalContainer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [externalContainer],
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('容器叠加示例')),
      body: Center(
        child: ContainerWidget(
            externalContainer: AndroidView(
                viewType: "id", onPlatformViewCreated: _onPlatformViewCreated)),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {}
}

// 应用入口
void main() {
  runApp(const MaterialApp(
    home: ExamplePage(),
  ));
}
