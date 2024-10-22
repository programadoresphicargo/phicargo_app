import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/notificaciones/services.dart';

import 'Enviados/estatus_enviados.dart';

class Envio extends StatefulWidget {
  File? image;
  late String id;
  late String name;
  late String referencia;

  Envio(
      {required this.image,
      required this.name,
      required this.referencia,
      required this.id});

  @override
  State<Envio> createState() => _EnvioState();
}

class _EnvioState extends State<Envio> {
  var data;
  startUpload() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          ));
        });

    File imagefile = File(widget.image!.path);
    Uint8List imagebytes = await imagefile.readAsBytesSync();
    String base64string = base64Encode(imagebytes);
    Uint8List decodedbytes = base64.decode(base64string);

    setState(() {});

    try {
      var response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/estatus/enviar_img.php'),
          body: {
            'id': widget.id.toString(),
            'name': widget.name.toString(),
            'referencia': widget.referencia.toString(),
            'base64': base64string,
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = response.body;
        print(data);
        print("---");

        if (data == '1') {
          showNotificacion('¡Imagen enviada!', '');
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => StatusPageTimeline(
                id_viaje: widget.id,
              ),
            ),
            (route) => false,
          );
        }
      } else {}
    } on TimeoutException catch (e) {
    } on Error catch (e) {
      print('ERROR 1:');
    } on SocketException catch (e) {
      print('ERROR 2: NO HAY INTERNET');
    } on FormatException catch (e) {
      print('ERROR 3: FORMATO ERRONEO');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
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
              child: Image.file(
                widget.image!,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          startUpload();
                        },
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: Color.fromARGB(255, 34, 69, 151),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 27,
                          ),
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
