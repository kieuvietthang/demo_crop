import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/image_cropper.dart';

class ImageChecker extends StatefulWidget {
  const ImageChecker({super.key});

  @override
  State<ImageChecker> createState() => _ImageCheckerState();
}

class _ImageCheckerState extends State<ImageChecker> {
  PickedFile? imageFile;
  bool isImageResized = false;
  bool isFirst = true;
  Uint8List? croppedImage;

  Future<PickedFile> loadImage(bool gallery) async {
    Navigator.of(context).pop();
    final Completer<PickedFile> completer = new Completer();
    if (gallery) {
      ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
        setState(() {
          isImageResized = true;
          croppedImage = null;
        });
        return completer.complete(PickedFile(value!.path));
      });
    } else {
      ImagePicker().pickImage(source: ImageSource.camera).then((value) {
        setState(() {
          isImageResized = true;
          croppedImage = null;
        });
        return completer.complete(PickedFile(value!.path));
      });
    }
    return completer.future;
  }

  _resizeImage(bool gallery) async {
    imageFile = await loadImage(gallery);
  }

  Future<void> _alertChoiceDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFirst = false;
                        imageFile = null;
                        isImageResized = false;
                        _resizeImage(true);
                      });
                    },
                    child: const Text("Gallery"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFirst = false;
                        imageFile = null;
                        isImageResized = false;
                        _resizeImage(false);
                      });
                    },
                    child: const Text("Camera"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _imageDecider() {
    if (isFirst || imageFile == null) return Container();
    return image();
  }

  image() {
    if (!isImageResized || imageFile == null) {
      return const Center(
        child: Text("Loading"),
      );
    }
    if (croppedImage == null) return Image.file(File(imageFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Screen"),
        actions: [
          IconButton(
            onPressed: () {
              _alertChoiceDialog(context);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 200,
                child: _imageDecider(),
              ),
              ElevatedButton(
                onPressed: () async{
                  if(imageFile != null){
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(
                      imageFile: File(imageFile!.path)
                    )));
                    setState(() {
                      croppedImage = result;
                    });
                  }
                },
                child: const Text('Click to edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
