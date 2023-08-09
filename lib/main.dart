import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const TouchTest());
}

class TouchTest extends StatelessWidget {
  const TouchTest({Key? key}) : super(key: key);
  final String imageURL = 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Stack(
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

  const TouchControl({Key? key, this.onChanged, this.xPos, this.yPos, required this.imageURL}) : super(key: key);

  @override
  TouchControlState createState() => TouchControlState();
}

List<Offset> points = [];

class TouchControlState extends State<TouchControl> {
  double? xPos;
  double? yPos;
  Uint8List? image;

  GlobalKey? cropperKey = GlobalKey();


  Future<Uint8List?> crop({
    required GlobalKey cropperKey,
    double pixelRatio = 3,
  }) async {
    // Get cropped image
    final renderObject = cropperKey.currentContext!.findRenderObject();
    final boundary = renderObject as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  @override
  Widget build(BuildContext context) {
    void onChanged(Offset offset) {
      if (widget.onChanged != null) {
        widget.onChanged!(offset);
      }
      setState(() {
        xPos = offset.dx;
        yPos = offset.dy;
      });
    }


    void _handlePanStart(DragStartDetails details) {
      print('User started drawing');
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      onChanged(point);
    }

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
            decoration:  BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageURL),
                )),
          ),
        ),
      ),
    ),
    image != null ? Image.memory(image!) : Container()
    ],
    );
  }
}


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
    path.addPolygon(points, true);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}




// import 'package:flutter/material.dart';
// import 'package:untitled/image_selector.dart';
//
// void main(){
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Flutter demo",
//       theme: ThemeData(
//           primarySwatch: Colors.blue
//       ),
//       home: ImageChecker(),
//     );
//   }
// }