import 'dart:async';
import 'dart:io';
import 'dart:js_util';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class MyHomePage extends StatefulWidget {
  final File imageFile;
  const MyHomePage({super.key, required this.imageFile});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> pointList = [];
  bool cropImage = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  late ui.Image image;
  bool isImageLoaded = false;
  int rotation = 0;
  Future<void> init() async{
    image = await loadImage(File(widget.imageFile.path).readAsBytesSync());
  }


  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage(){
    if (isImageLoaded){
      return Center( )
    }
  }


  @override
  void initState() {
    init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
