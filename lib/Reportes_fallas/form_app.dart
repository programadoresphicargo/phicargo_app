import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:phicargo/nav.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Alertas/alerta.dart';
import '../Conexion/Conexion.dart';
import '../notificaciones/services.dart';
import 'city.dart';
import 'cuerpo.dart';
import 'vista.dart';

class form_app extends StatefulWidget {
  @override
  bool editable;
  String id_reporte;
  form_app({required this.editable, required this.id_reporte});
  _form_appState createState() => _form_appState();
}

class _form_appState extends State<form_app> {
  TextEditingController comentarios_operador = TextEditingController();

  List<DropdownItem> dropdownItems = [];
  String titulo = '';
  String usuario_resolvio = '';
  String fecha_resuelto = '';
  String comentarios_resuelto = '';

  @override
  void initState() {
    super.initState();
    if (widget.editable == false) {
      getReporte(widget.id_reporte);
      getEvidencias(widget.id_reporte);
    } else {}
  }

  void getReporte(id_reporte) async {
    try {
      var response = await http.post(
          Uri.parse('${conexion}/phicargo/app/reportes_app/getReporte.php'),
          body: {
            'id_reporte': id_reporte.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        var firstItem = jsonResponse[0];
        var id_reporte = firstItem['id_reporte'];
        var NotasOperador = firstItem['notas_operador'];

        setState(() {
          titulo = id_reporte;
          comentarios_operador.text = NotasOperador;
          if (widget.editable == false) {
            usuario_resolvio = firstItem['nombre'];
            fecha_resuelto = firstItem['fecha_resuelto'];
            comentarios_resuelto = firstItem['comentarios_resuelto'];
          }
        });
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('ERROR');
    } on Error catch (e) {
      print(e.toString());
    } on SocketException catch (e) {}
  }

  void getEvidencias(id_reporte) async {
    try {
      var response = await http.post(
          Uri.parse('${conexion}/phicargo/app/reportes_app/getEvidencias.php'),
          body: {
            'res_id': id_reporte.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        for (var data in jsonData) {
          print('ahscult' + data['res_id']);

          String base64String = data['datas'];
          Uint8List bytes = base64.decode(base64String);
          File tempFile = File('${data['id_file']}.png');
          String tempDir = Directory.systemTemp.path;
          tempFile = File('$tempDir/${data['id_file']}.png');
          tempFile.writeAsBytesSync(bytes);
          setState(() {
            selectedImages.add(tempFile);
          });
        }
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('ERROR');
    } on Error catch (e) {
      print(e.toString());
    } on SocketException catch (e) {}
  }

  void enviar_reporte() async {
    try {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id_operador = prefs.getString('id');

      List<String> base64Images = [];
      for (var image in selectedImages) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        base64Images.add(base64Image);
      }

      var response = await http.post(
          Uri.parse('${conexion}/phicargo/app/reportes_app/crear_reporte.php'),
          body: {
            'id_operador': id_operador.toString(),
            'notas_operador': comentarios_operador.text.toString(),
            'images': jsonEncode(base64Images)
          }).timeout(const Duration(seconds: 90));

      if (response.body == '1') {
        showNotificacion('¡Reporte enviado con exito!', '');
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => Nav(
              selectedIndex: 6,
            ),
          ),
          (route) => false,
        );
      } else {
        print(response.body);
        error_alert(response.body, response.body, Icon(Icons.abc), context);
      }
    } on TimeoutException catch (e) {
      print('ERROR');
    } on Error catch (e) {
      print(e.toString());
    } on SocketException catch (e) {}
  }

  final ImagePicker picker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> takePhotosAndUpload(ImageSource source) async {
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 60);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.blue.shade700,
        title: Text(
          'RF.$titulo',
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            Visibility(
              visible: usuario_resolvio != '' ? true : false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resuelto por:'),
                      Text(usuario_resolvio)
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fecha resuelto:'),
                      Text(fecha_resuelto)
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comentarios'),
                      Text(comentarios_resuelto)
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            TextFormField(
              enabled: widget.editable,
              controller: comentarios_operador,
              decoration: const InputDecoration(
                labelText: 'Descripción del problema',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Evidencias: '),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: widget.editable,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 20, 80, 200),
                      ),
                      onPressed: () {
                        takePhotosAndUpload(ImageSource.camera);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cámara',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 20, 80, 200),
                    ),
                    onPressed: () {
                      takePhotosAndUpload(ImageSource.gallery);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Galería',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  final base64Image = selectedImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              FullScreenImage(imagen: base64Image),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                base64Image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.editable,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    selectedImages.removeAt(index);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: widget.editable,
        child: FloatingActionButton.extended(
          backgroundColor: Color.fromARGB(255, 20, 80, 200),
          foregroundColor: Colors.black,
          onPressed: () {
            if (comentarios_operador.text != '') {
              enviar_reporte();
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text("Por favor, añada un comentario."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Aceptar"),
                      ),
                    ],
                  );
                },
              );
            }
          },
          icon: const Icon(
            Icons.send_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Enviar reporte',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'Product Sans'),
          ),
        ),
      ),
    );
  }
}
