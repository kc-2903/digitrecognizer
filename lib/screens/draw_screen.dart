import 'package:flutter/material.dart';
import 'package:digit/models/prediction.dart';
import 'package:digit/screens/drawing_painter.dart';
import 'package:digit/screens/prediction_widget.dart';
import 'package:digit/services/recognizer.dart';
import 'package:digit/utils/constants.dart';

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  //final _points = List<Offset>();
  final List<Offset> _points = [];
  final _recognizer = Recognizer();
  List<Prediction> _prediction;
  bool initialize = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Handwritten Digit Recognizer'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          _drawCanvasWidget(),
          SizedBox(
            height: 40,
          ),
          FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.clear,
              color: Colors.lightBlueAccent,
            ),
            onPressed: () {
              setState(() {
                _points.clear();
                _prediction.clear();
              });
            },
          ),
          SizedBox(height: 30),
          PredictionWidget(
            predictions: _prediction,
          ),
        ],
      ),
    );
  }

  Widget _drawCanvasWidget() {
    return Container(
      width: Constants.canvasSize + Constants.borderSize * 2,
      height: Constants.canvasSize + Constants.borderSize * 2,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: Constants.borderSize,
        ),
      ),
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          Offset _localPosition = details.localPosition;
          if (_localPosition.dx >= 0 &&
              _localPosition.dx <= Constants.canvasSize &&
              _localPosition.dy >= 0 &&
              _localPosition.dy <= Constants.canvasSize) {
            setState(() {
              _points.add(_localPosition);
            });
          }
        },
        onPanEnd: (DragEndDetails details) {
          _points.add(null);
          _recognize();
        },
        child: CustomPaint(
          painter: DrawingPainter(_points),
        ),
      ),
    );
  }

  void _initModel() async {
    var res = await _recognizer.loadModel();
  }

  void _recognize() async {
    List<dynamic> pred = await _recognizer.recognize(_points);
    setState(() {
      _prediction = pred.map((json) => Prediction.fromJson(json)).toList();
    });
  }
}
