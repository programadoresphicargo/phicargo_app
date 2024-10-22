import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:phicargo/Reportes_fallas/vista.dart';
import 'package:phicargo/nav.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Alertas/alerta.dart';
import '../Conexion/Conexion.dart';
import '../notificaciones/services.dart';
import 'city.dart';
import 'cuerpo.dart';

class formulario_reporte_fallas extends StatefulWidget {
  @override
  bool editable;
  int id_reporte;
  formulario_reporte_fallas({required this.editable, required this.id_reporte});
  _formulario_reporte_fallasState createState() =>
      _formulario_reporte_fallasState();
}

class _formulario_reporte_fallasState extends State<formulario_reporte_fallas> {
  TextEditingController comentarios_operador = TextEditingController();

  List<DropdownItem> dropdownItems = [];
  int selectedId = 0;
  String titulo = '';

  @override
  void initState() {
    super.initState();
    if (widget.editable == false) {
      getReporte(widget.id_reporte);
      getEvidencias(widget.id_reporte);
    } else {
      titulo = 'Nuevo reporte';
    }
  }

  void getReporte(id_reporte) async {
    try {
      var response = await http.post(
          Uri.parse('${conexion}/phicargo/app/reportes_fallas/getReporte.php'),
          body: {
            'id': id_reporte.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        var firstItem = jsonResponse[0];
        var id = firstItem['id'];
        var vehicleId = firstItem['vehicle_id'][0];
        var xNotasOperador = firstItem['x_notas_operador'];

        setState(() {
          titulo = firstItem['name'];
          _controller.text = firstItem['vehicle_id'][1];
          selectedId = firstItem['vehicle_id'][0];
          comentarios_operador.text = xNotasOperador;
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
          Uri.parse(
              '${conexion}/phicargo/app/reportes_fallas/getEvidencias.php'),
          body: {
            'id': id_reporte.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        for (var data in jsonData) {
          String base64String = data['datas'];
          Uint8List bytes = base64.decode(base64String);
          File tempFile = File('${data['id']}.png');
          String tempDir = Directory.systemTemp.path;
          tempFile = File('$tempDir/${data['id']}.png');
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
          Uri.parse(
              '${conexion}/phicargo/app/reportes_fallas/crear_reporte.php'),
          body: {
            'id_operador': id_operador.toString(),
            'id_vehiculo': selectedId.toString(),
            'comentarios': comentarios_operador.text.toString(),
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
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 100, 100, 100),
        title: Text(
          titulo,
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            TypeAheadField<MyItem>(
              textFieldConfiguration: TextFieldConfiguration(
                enabled: widget.editable,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar vehículo',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                final response = await http.get(Uri.parse(
                    '$conexion/phicargo/app/reportes_fallas/unidades.php'));

                if (response.statusCode == 200) {
                  final List<dynamic> jsonResponse = json.decode(response.body);
                  return jsonResponse
                      .map((item) => MyItem.fromJson(item))
                      .where((item) {
                    return item.name
                        .toLowerCase()
                        .contains(pattern.toLowerCase());
                  }).toList();
                } else {
                  throw Exception('Failed to load suggestions');
                }
              },
              itemBuilder: (context, MyItem suggestion) {
                return ListTile(
                  title: Text(suggestion.name),
                );
              },
              onSuggestionSelected: (MyItem suggestion) {
                _controller.text = suggestion.name;
                setState(() {
                  selectedId = suggestion.id;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              enabled: widget.editable,
              controller: comentarios_operador,
              decoration: const InputDecoration(
                labelText: 'Descripción del problema',
                border: OutlineInputBorder(),
              ),
              minLines: 6,
              maxLines: null,
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
                        backgroundColor: Colors.grey,
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
                      backgroundColor: Colors.grey,
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
            SizedBox(
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
          backgroundColor: Color.fromARGB(255, 100, 100, 100),
          foregroundColor: Colors.black,
          onPressed: () {
            if (selectedId != 0) {
              print("ID seleccionado: $selectedId");
              enviar_reporte();
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Por favor, selecciona un vehículo para llenar el reporte."),
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
