import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:phicargo/notificaciones/services.dart';
import 'package:photo_view/photo_view.dart';

class Vista_Previa extends StatefulWidget {
  File previa;

  Vista_Previa({
    required this.previa,
  });

  @override
  State<Vista_Previa> createState() => _Vista_PreviaState();
}

class _Vista_PreviaState extends State<Vista_Previa> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        actions: [],
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
                imageProvider: FileImage(
                  (widget.previa),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
