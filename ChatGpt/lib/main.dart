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
  FlowComponent? _selectedComponent;
  FlowComponent? _startComponent;
  FlowComponent? _endComponent;

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
                  iconSize: 32,
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    _showTextPopup(ComponentType.square);
                  },
                ),
                IconButton(
                  iconSize: 32,
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    _showTextPopup(ComponentType.triangle);
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
                setState(() {
                  _selectedComponent = selectedComponent;
                  if (_startComponent == null) {
                    _startComponent = selectedComponent;
                  } else {
                    _endComponent = selectedComponent;
                    _createArrow();
                  }
                });
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
                painter: FlowPainter(_placedComponents, _startComponent, _endComponent),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextPopup(ComponentType type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newText = '';
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              newText = value;
            },
            onEditingComplete: () {
              _addNewComponent(type, newText);
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
                _addNewComponent(type, newText);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addNewComponent(ComponentType type, String text) {
    setState(() {
      final newComponent = FlowComponent(Colors.white, Colors.black, type, text);
      newComponent.position = Offset(100, 100); // Set initial position on the board
      _placedComponents.add(newComponent);
    });
  }

  FlowComponent? _getSelectedComponent(Offset position) {
    return _placedComponents.firstWhere(
          (component) => component.isPointInside(position),
      orElse: () => null as FlowComponent,
    );
  }

  void _createArrow() {
    if (_startComponent != null && _endComponent != null) {
      final arrow = Arrow(_startComponent!.position, _endComponent!.position);
      _placedComponents.add(arrow);
      _startComponent = null;
      _endComponent = null;
    }
  }
}

class FlowPainter extends CustomPainter {
  final List<FlowComponent> components;
  final FlowComponent? startComponent;
  final FlowComponent? endComponent;

  FlowPainter(this.components, this.startComponent, this.endComponent);

  @override
  void paint(Canvas canvas, Size size) {
    for (final component in components) {
      _drawComponent(canvas, component);
    }
    _drawArrow(canvas);
  }

  void _drawComponent(Canvas canvas, FlowComponent component) {
    final paint = Paint()
      ..color = component.color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(component.position.dx, component.position.dy, 120, 120);
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
      maxWidth: 120,
    );

    final offsetX = (120 - textPainter.width) / 2;
    final offsetY = (120 - textPainter.height) / 2;
    final textOffset = Offset(component.position.dx + offsetX, component.position.dy + offsetY);

    textPainter.paint(canvas, textOffset);
  }

  void _drawArrow(Canvas canvas) {
    if (startComponent != null && endComponent != null) {
      final arrowPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0;

      final startPoint = Offset(
        startComponent!.position.dx + 60,
        startComponent!.position.dy + 120,
      );

      final endPoint = Offset(
        endComponent!.position.dx + 60,
        endComponent!.position.dy,
      );

      canvas.drawLine(startPoint, endPoint, arrowPaint);
    }
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
  late final String text;

  FlowComponent(this.color, this.borderColor, this.type, this.text)
      : position = Offset.zero;

  bool isPointInside(Offset point) {
    return position.dx <= point.dx &&
        point.dx <= position.dx + 120 &&
        position.dy <= point.dy &&
        point.dy <= position.dy + 120;
  }
}

class Arrow extends FlowComponent {
  Arrow(Offset startPosition, Offset endPosition)
      : super(Colors.transparent, Colors.transparent, ComponentType.square, '') {
    position = startPosition;
    text = '';
  }
}
