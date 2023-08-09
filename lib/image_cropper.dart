import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:untitled/custom_clipper.dart';
import 'package:untitled/custom_painter.dart';

class MyHomePage extends StatefulWidget {
  final File imageFile;

  const MyHomePage({super.key, required this.imageFile});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> pointsList = [];
  bool cropImage = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  late ui.Image image;
  bool isImageLoaded = false;
  int rotation = 0;

  GlobalKey<FormState> _abcKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    image = await loadImage(File(widget.imageFile.path).readAsBytesSync());
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }



  Widget _buildImage() {
    if (isImageLoaded) {
      return Center(
        child: RotatedBox(
          quarterTurns: rotation,
          child: FittedBox(
            child: SizedBox(
              height: image.height.toDouble(),
              width: image.width.toDouble(),
              child: cropImage
                  ? Screenshot(
                      controller: _screenshotController,
                      child: ClipPath(
                        clipper: MyClipper(
                          pointsList: pointsList,
                        ),
                        child: Image.file(widget.imageFile),
                      ))
                  : CustomPaint(
                      painter: MyImagePainter(
                        pointsList,
                        crop: cropImage,
                        context: context,
                        image: image,
                        height: MediaQuery.of(context).size.width.toInt(),
                      ),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          Offset click = Offset(details.localPosition.dx,
                              details.localPosition.dy);
                          setState(() {
                            if (click.dx > 0 &&
                                click.dx < image.width &&
                                click.dy > 0 &&
                                click.dy < image.height) {
                              pointsList.add(click);
                            }
                          });
                        },
                      ),
                    ),
            ),
          ),
        ),
      );
    }
    return const Center(
      child: Text('loading'),
    );
  }
  // void _handlePanEnd(DragEndDetails details) async {
  //   image = await crop(cropperKey: cropperKey!);
  //   setState(() {});
  // }

  List<Widget> _iconDecider() {
    if (isImageLoaded && !cropImage) {
      return [
        IconButton(
          onPressed: () async {
            setState(() {
              cropImage = true;
            });
            _screenshotController.capture().then((Uint8List? imageList) async {
              if (imageList != null) {
                String? path = await FileSaver.instance.saveAs(
                    name: 'result image',
                    ext: 'png',
                    mimeType: MimeType.png,
                    bytes: imageList);
                log(path!);
              }
            });
          },
          icon: Icon(Icons.edit),
        ),
      ];
    }
    return [];
  }

  Widget rotate() {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              setState(() {
                rotation--;
              });
            },
            icon: const Icon(Icons.rotate_left),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                rotation++;
              });
            },
            icon: const Icon(Icons.rotate_right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doc Scanner"),
        actions: _iconDecider(),
      ),
      body: _buildImage(),
      bottomNavigationBar: rotate(),
    );
  }
}
