import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:phicargo/Conexion/Conexion.dart';

import 'envio.dart';

class Galeria extends StatefulWidget {
  late String id;
  late String referencia;

  Galeria({required this.referencia, required this.id});

  @override
  _GaleriaState createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  @override
  void initState() {
    getStatus(widget.referencia);
    super.initState();
  }

  var data;
  var length;
  bool loading = true;
  Future<void> getStatus(referencia) async {
    try {
      final response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/viajes/obtener-img.php'),
          body: {
            'referencia': referencia.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body.toString());
          length = jsonDecode(response.body).length;

          loading = false;
        });
      } else {}
    } on TimeoutException catch (e) {
    } on Error catch (e) {
      print('ERROR :()');
      getStatus(referencia);
    } on SocketException catch (e) {
      print('ERROR 2: NO HAY INTERNET');
      getStatus(referencia);
    } on FormatException catch (e) {
      print('ERROR 3: FORMATO ERRONEO');
      getStatus(referencia);
    }
  }

  Future refresh() async {
    setState(() {
      getStatus(widget.referencia);
    });
  }

  File? image;
  @override
  Widget build(BuildContext context) {
    Future pickImage(ImageSource source) async {
      try {
        final image = await ImagePicker().pickImage(
            source: source, maxHeight: 480, maxWidth: 640, imageQuality: 100);
        if (image == null) return;

        final imageTemporary = File(image.path);
        final fileName = File(image.path);
        print(imageTemporary);
        print(fileName);

        setState(() {
          this.image = imageTemporary;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Envio(
                image: imageTemporary,
                name: fileName.toString(),
                referencia: widget.referencia,
                id: widget.id,
              ),
            ),
          );
        });
      } on PlatformException catch (e) {
        print('Failed');
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: loading == true
            ? Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/car.json', height: 150),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Obteniendo imagenes, espere un minuto...',
                        style: TextStyle(
                          color: Color.fromARGB(255, 34, 69, 151),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : length == 0
                ? Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/status/camara.png',
                            height: 100,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'No hay imagenes.',
                            style: TextStyle(
                              color: Color.fromARGB(255, 34, 69, 151),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        crossAxisCount: 3),
                    itemCount: data == null ? 0 : data.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detalles(
                            name: (data[index]['name']),
                            datas: (data[index]['datas']),
                          ),
                        ),
                      ),
                      child: Hero(
                        tag: data[index]['name'].toString(),
                        child: Image.memory(
                          Base64Decoder().convert(
                            (data[index]['datas'].toString()),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Adjuntar imagen:',
                          style: TextStyle(),
                        ),
                      ),
                      ListTile(
                        leading: Image.asset('assets/camara.png'),
                        title: Text(
                          'Usar cámara',
                          style: TextStyle(),
                        ),
                        onTap: () => pickImage(ImageSource.camera),
                      ),
                      ListTile(
                        leading: Image.asset('assets/galeria.png'),
                        title: const Text(
                          'Escoger de la galeria',
                          style: TextStyle(),
                        ),
                        onTap: () => pickImage(ImageSource.gallery),
                      )
                    ],
                  ),
                );
              });
        },
        backgroundColor: const Color.fromARGB(255, 34, 69, 151),
        child: const Icon(Icons.add_a_photo_rounded),
      ),
    );
  }
}

class Detalles extends StatelessWidget {
  late String name;
  late String datas;
  Detalles({required this.name, required this.datas});

  late var _decodedImage = base64Decode(datas);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 34, 69, 151),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Center(
          child: Hero(
              tag: name.toString(),
              child: PhotoView(
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  initialScale: PhotoViewComputedScale.contained,
                  basePosition: Alignment.center,
                  gaplessPlayback: false,
                  customSize: MediaQuery.of(context).size,
                  minScale: PhotoViewComputedScale.contained * 1.0,
                  maxScale: PhotoViewComputedScale.covered * 4.0,
                  imageProvider: MemoryImage(_decodedImage))),
        ),
      ),
    );
  }
}
