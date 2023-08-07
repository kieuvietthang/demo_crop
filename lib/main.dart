import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const TouchTest());
}

class TouchTest extends StatelessWidget {
  const TouchTest({Key? key}) : super(key: key);
  final String imageURL =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Stack(
// I've created a stack here because be able to show what
//there is behind the ClipPath widget

            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: 300,
                    height: 300,
                    color: Colors.grey,
                    child: Image.network(
                      imageURL,
                    ),
                  ),
                ),
              ),
              TouchControl(imageURL: imageURL),
            ],
          ),
        ),
      ),
    );
  }
}

class TouchControl extends StatefulWidget {
  final double? xPos;
  final double? yPos;
  final ValueChanged<Offset>? onChanged;
  final String imageURL;

  const TouchControl(
      {Key? key, this.onChanged, this.xPos, this.yPos, required this.imageURL})
      : super(key: key);

  @override
  TouchControlState createState() => TouchControlState();
}

// This contains all locations user touched.
List<Offset> points = [];

class TouchControlState extends State<TouchControl> {
  double? xPos;
  double? yPos;
  Uint8List? image;

// Global key is mandatory to crop image.
//It bounds the clipped paint to crop function
  GlobalKey? cropperKey = GlobalKey();

//this function crops image when gesture is ended.
//thanks to https://github.com/speedkodi/flutter_cropperx
  Future<Uint8List?> crop({
    required GlobalKey cropperKey,
    double pixelRatio = 3,
  }) async {
    // Get cropped image
    final renderObject = cropperKey.currentContext!.findRenderObject();
    final boundary = renderObject as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);

    // Convert image to bytes in PNG format and return
    final byteData = await image.toByteData(
      format: ImageByteFormat.png,
    );
    final pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  @override
  Widget build(BuildContext context) {
    void onChanged(Offset offset) {
      // for prevent to null value and setState function
      if (widget.onChanged != null) {
        widget.onChanged!(offset);
      }
      setState(() {
        xPos = offset.dx;
        yPos = offset.dy;
      });
    }

//This function related to GestureDetector.
//This runs when user touch screen
    void _handlePanStart(DragStartDetails details) {
      print('User started drawing');
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      onChanged(point);
    }

//this function runs crop future when user interaction ended.
    void _handlePanEnd(DragEndDetails details) async {
      image = await crop(cropperKey: cropperKey!);
      setState(() {});
    }

    void _handlePanUpdate(DragUpdateDetails details) {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      onChanged(point);
    }

    return Column(
      children: [
        RepaintBoundary(
          key: cropperKey,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _handlePanStart,
            onPanEnd: _handlePanEnd,
            onPanUpdate: _handlePanUpdate,
            child: ClipPath(
              clipper: TouchControlPainter(xPos, yPos),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: NetworkImage(widget.imageURL),
                )),
              ),
            ),
          ),
        ),
//below code is here to show it works while recording video.
        image != null ? Image.memory(image!) : Container()
      ],
    );
  }
}

//CustomCipper class to crop image.
class TouchControlPainter extends CustomClipper<Path> {
  final double? xPos;
  final double? yPos;

  TouchControlPainter(this.xPos, this.yPos);

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (xPos != null && yPos != null) {
      points.add(Offset(xPos!, yPos!));
    }
    path.addPolygon(points, true); // here contains point list that
//I declared one of the previous lines and
//addPolygon method creates a polygon using list of points.
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// here should be true to see what user draws
// simultaneously.
}
