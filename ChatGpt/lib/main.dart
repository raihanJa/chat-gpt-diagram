import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow Diagram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlowDiagram(),
    );
  }
}

class FlowDiagram extends StatefulWidget {
  @override
  _FlowDiagramState createState() => _FlowDiagramState();
}

class _FlowDiagramState extends State<FlowDiagram> {
  List<FlowComponent> _placedComponents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flow Diagram'),
      ),
      body: Row(
        children: [
          Container(
            width: 100,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    _addNewComponent(ComponentType.square);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    _addNewComponent(ComponentType.triangle);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails details) {
                final selectedComponent = _getSelectedComponent(details.localPosition);
                if (selectedComponent != null) {
                  _showTextPopup(selectedComponent);
                }
              },
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  final selectedComponent = _getSelectedComponent(details.localPosition);
                  if (selectedComponent != null) {
                    selectedComponent.position += details.delta;
                  }
                });
              },
              child: CustomPaint(
                painter: FlowPainter(_placedComponents),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewComponent(ComponentType type) {
    setState(() {
      final newComponent = FlowComponent(Colors.white, Colors.black, type);
      newComponent.position = Offset(100, 100); // Set initial position on the board
      _placedComponents.add(newComponent);
      _showTextPopup(newComponent);
    });
  }

  FlowComponent? _getSelectedComponent(Offset position) {
    return _placedComponents.firstWhere(
          (component) => component.isPointInside(position),
      orElse: () => null as FlowComponent,
    );
  }

  void _showTextPopup(FlowComponent component) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newText = component.text;
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              newText = value;
            },
            onEditingComplete: () {
              setState(() {
                component.text = newText;
              });
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  component.text = newText;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class FlowPainter extends CustomPainter {
  final List<FlowComponent> components;

  FlowPainter(this.components);

  @override
  void paint(Canvas canvas, Size size) {
    for (final component in components) {
      _drawComponent(canvas, component);
    }
  }

  void _drawComponent(Canvas canvas, FlowComponent component) {
    final paint = Paint()
      ..color = component.color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(component.position.dx, component.position.dy, 80, 80);
    canvas.drawRect(rect, paint);

    final borderPaint = Paint()
      ..color = component.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, borderPaint);

    final textSpan = TextSpan(
      text: component.text,
      style: TextStyle(color: Colors.black),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 80,
    );

    final offsetX = (80 - textPainter.width) / 2;
    final offsetY = (80 - textPainter.height) / 2;
    final textOffset = Offset(component.position.dx + offsetX, component.position.dy + offsetY);

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum ComponentType {
  square,
  triangle,
}

class FlowComponent {
  final Color color;
  final Color borderColor;
  final ComponentType type;
  Offset position;
  String text;

  FlowComponent(this.color, this.borderColor, this.type)
      : position = Offset.zero,
        text = '';

  bool isPointInside(Offset point) {
    return position.dx <= point.dx &&
        point.dx <= position.dx + 80 &&
        position.dy <= point.dy &&
        point.dy <= position.dy + 80;
  }
}
