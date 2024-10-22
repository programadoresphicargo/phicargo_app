import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class vista_foto extends StatefulWidget {
  String imagen;

  vista_foto({
    required this.imagen,
  });

  @override
  State<vista_foto> createState() => _vista_fotoState();
}

class _vista_fotoState extends State<vista_foto> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: PhotoView(
                backgroundDecoration: BoxDecoration(color: Colors.white),
                initialScale: PhotoViewComputedScale.contained,
                basePosition: Alignment.center,
                gaplessPlayback: false,
                customSize: MediaQuery.of(context).size,
                minScale: PhotoViewComputedScale.contained * 1.0,
                maxScale: PhotoViewComputedScale.covered * 4.0,
                imageProvider: NetworkImage(
                  (widget.imagen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
