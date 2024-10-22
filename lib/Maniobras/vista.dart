import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:phicargo/notificaciones/services.dart';
import 'package:photo_view/photo_view.dart';

import '../Conexion/Conexion.dart';

class Vista_foto extends StatefulWidget {
  String id_cp;
  String evidencia;

  Vista_foto({
    super.key,
    required this.id_cp,
    required this.evidencia,
  });

  @override
  State<Vista_foto> createState() => _VistaState();
}

class _VistaState extends State<Vista_foto> {
  @override
  void initState() {
    // TODO: implement initState
    print(widget.evidencia);
  }

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
            SizedBox(
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
                    '${conexion}phicargo/maniobras/archivos/' +
                        widget.id_cp +
                        '/' +
                        widget.evidencia),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
