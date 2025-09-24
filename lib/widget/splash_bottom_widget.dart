import 'widget_layout.dart';

class SplashBottomWidget extends LayoutWidget {
  final double height;
  final String backgroundColor;
  final List<LayoutWidget> children;

  SplashBottomWidget({
    required this.height,
    required this.backgroundColor,
    required this.children,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'parent',
      'height': height,
      'backgroundColor': backgroundColor,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }
}

class ImageComponent extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  final String imageUrl;

  ImageComponent({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.imageUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'image',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'imageUrl': imageUrl,
    };
  }
}

class TextComponent extends LayoutWidget {
  final double fontSize;
  final String color;
  final double x;
  final double y;
  final String text;

  TextComponent({
    required this.fontSize,
    required this.color,
    required this.x,
    required this.y,
    required this.text,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'text',
      'fontSize': fontSize,
      'color': color,
      'x': x,
      'y': y,
      'text': text,
    };
  }
}