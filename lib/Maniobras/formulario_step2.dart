import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:phicargo/Alertas/alerta.dart';
import 'package:phicargo/Maniobras/enviados.dart';
import 'package:phicargo/Maniobras/maniobra_info.dart';
import 'package:phicargo/estatus/vista_previa.dart';
import 'package:phicargo/notificaciones/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:shared_preferences/shared_preferences.dart';

final comentarios = TextEditingController();

class FormStatusEnviarManiobra extends StatefulWidget {
  final String id_maniobra;
  final String id_estatus;
  final String estatus_nombre;
  final String url_imagen;
  final double latitud;
  final double longitud;
  final String calle;
  final String localidad;
  final String sublocalidad;
  final String codigo_postal;

  const FormStatusEnviarManiobra({
    required this.id_maniobra,
    required this.id_estatus,
    required this.estatus_nombre,
    required this.url_imagen,
    required this.latitud,
    required this.longitud,
    required this.calle,
    required this.localidad,
    required this.sublocalidad,
    required this.codigo_postal,
  });

  @override
  State<FormStatusEnviarManiobra> createState() =>
      _FormStatusEnviarManiobraState();
}

class _FormStatusEnviarManiobraState extends State<FormStatusEnviarManiobra> {
  @override
  void initState() {
    comentarios.clear();
  }

  List<File> images = [];

  @override
  Widget build(BuildContext context) {
    String coments = '';

    void _showAlertDialog() {
      showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: const Text(
              "Borrar Imagen",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 69, 151)),
            ),
            content: const Text("¿Realmente deseas borrar la imagen?"),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 154, 4, 4),
                ),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 34, 69, 151),
                ),
                child: const Text(
                  "Si",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
              )
            ],
          );
        },
      );
    }

    Future pickImages(ImageSource source) async {
      try {
        final pickedImages = await ImagePicker().pickImage(
            maxHeight: 680, maxWidth: 840, imageQuality: 100, source: source);

        if (pickedImages == null) return;

        setState(() {
          images.add(File(pickedImages.path));
        });
      } on PlatformException catch (e) {
        print('Failed: $e');
      }
    }

    void enviar_status() async {
      try {
        // Mostrar diálogo de carga
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          },
        );

        // Obtener el ID del operador de SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? id_operador = prefs.getString('id');

        // Crear una solicitud multipart/form-data
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                '${conexion}phicargo/aplicacion/maniobras/insertar_estatus.php'));

        // Adjuntar imágenes al formulario
        for (int i = 0; i < images.length; i++) {
          request.files.add(http.MultipartFile('image_$i',
              images[i].readAsBytes().asStream(), images[i].lengthSync(),
              filename: 'image_$i.jpg'));
        }

        // Adjuntar otras variables al formulario
        request.fields.addAll({
          'id_maniobra': widget.id_maniobra.toString(),
          'id_estatus': widget.id_estatus.toString(),
          'estatus_nombre': widget.estatus_nombre.toString(),
          'comentarios': comentarios.text.toString(),
          'latitud': widget.latitud.toString(),
          'longitud': widget.longitud.toString(),
          'calle': widget.calle.toString(),
          'localidad': widget.localidad.toString(),
          'sublocalidad': widget.sublocalidad.toString(),
          'codigo_postal': widget.codigo_postal.toString(),
          'operador_id': id_operador.toString(),
          'vehiculo_id': id_operador.toString(),
        });

        // Enviar la solicitud con un tiempo de espera
        var streamedResponse =
            await request.send().timeout(const Duration(seconds: 90));

        // Obtener la respuesta
        var response = await http.Response.fromStream(streamedResponse);
        print(response.body);

        // Procesar la respuesta
        if (response.body == '1') {
          showNotificacion('¡estatus enviado con éxito!', '');
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => Maniobras()),
            (route) => false,
          );
        } else {
          Navigator.pop(context); // Cerrar el diálogo de carga
          error_alert(
            'Error: No se pudo enviar el estatus',
            response.body,
            const Icon(
              Icons.info_sharp,
              color: Colors.white,
              size: 25,
            ),
            context,
          );
        }
      } on TimeoutException catch (e) {
        print('ERROR: $e');
      } on Error catch (e) {
        print('ERROR: $e');
      } on SocketException catch (e) {
        print('ERROR: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text(
          'Datos de envio',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Hero(
                        tag: 'statusImage_${widget.id_estatus}',
                        child: CachedNetworkImage(
                          imageUrl: (widget.url_imagen),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                        ),
                      ),
                    ),
                    title: const Text(
                      'Estatus seleccionado',
                      style: TextStyle(fontSize: 10),
                    ),
                    subtitle: Text(
                      widget.estatus_nombre,
                      style: const TextStyle(
                          fontFamily: 'Product Sans', fontSize: 25),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FlutterLogo(size: 72.0),
                    title: Text('Ubicación'),
                    subtitle: Text(
                        '${widget.latitud} ${widget.longitud} ${widget.calle} ${widget.localidad} ${widget.sublocalidad} ${widget.codigo_postal}'),
                  ),
                ),
                const Text(
                  'AÑADIR EVIDENCIAS:',
                  style: TextStyle(
                    color: Color.fromARGB(255, 34, 69, 151),
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () => pickImages(ImageSource.camera),
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Cámara",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.blue.shade800,
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () => pickImages(ImageSource.gallery),
                            icon: const Icon(
                              Icons.insert_photo,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Galería",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.blue.shade700,
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: images.length == 0 ? false : true,
              child: Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(8),
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          Image.file(images[index],
                              fit: BoxFit.cover, width: 100, height: 100),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Row(
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.red),
                                          SizedBox(width: 10),
                                          Text('Alerta'),
                                        ],
                                      ),
                                      content: const Text(
                                          '¿Realmente deseas borrar esta imagen?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Eliminar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              images.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                const Text('COMENTARIOS: ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 34, 69, 151),
                      fontSize: 17,
                    )),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  maxLines: 5,
                  controller: comentarios,
                  decoration: InputDecoration(
                    helperMaxLines: 5,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 34, 69, 151),
                        width: 2.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 236, 234, 234)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    text:
                        'Para validar el envio del status presiona confirmar.',
                    title: '',
                    confirmBtnText: 'Confirmar',
                    cancelBtnText: 'Cancelar',
                    confirmBtnColor: Colors.blue.shade700,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    confirmBtnTextStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans'),
                    cancelBtnTextStyle:
                        const TextStyle(fontFamily: 'Product Sans'),
                    titleColor: const Color.fromARGB(255, 0, 0, 0),
                    textColor: const Color.fromARGB(255, 0, 0, 0),
                    onConfirmBtnTap: () async {
                      coments = comentarios.text;
                      enviar_status();
                    },
                  );
                },
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    "Enviar estatus",
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.send_rounded,
                    size: 24.0,
                    color: Colors.white,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
