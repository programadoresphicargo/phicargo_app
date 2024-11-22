import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:phicargo/Alertas/alerta.dart';
import 'package:phicargo/Login/Welcome.dart';
import 'package:phicargo/Maniobras/Enviados/estatus_enviados.dart';
import 'package:phicargo/Viajes/Enviados/estatus_enviados.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../Conexion/Conexion.dart';
import '../../notificaciones/services.dart';

class envio_estatus_form_maniobra extends StatefulWidget {
  String id_status;
  String status_nombre;
  String url_imagen;
  String id_maniobra;
  String id_vehiculo;
  String referencia;
  double latitud;
  double longitud;
  String calle;
  String localidad;
  String sublocalidad;
  String codigo_postal;

  envio_estatus_form_maniobra(
      {required this.id_maniobra,
      required this.referencia,
      required this.id_status,
      required this.status_nombre,
      required this.url_imagen,
      required this.id_vehiculo,
      required this.latitud,
      required this.longitud,
      required this.calle,
      required this.localidad,
      required this.sublocalidad,
      required this.codigo_postal,
      super.key});
  @override
  State<envio_estatus_form_maniobra> createState() => _MyScreenMapaState();
}

class _MyScreenMapaState extends State<envio_estatus_form_maniobra> {
  final comentarios = TextEditingController();

  Color backgroundColor = Colors.grey;
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  List<Placemark>? placemark;

  List<File> images = [];

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

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.url_imagen),
    );
    setState(() {
      backgroundColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
    });
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id_operador = prefs.getString('id');

      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${conexion}phicargo/aplicacion/maniobras/insertar_estatus.php'));

      for (int i = 0; i < images.length; i++) {
        request.files.add(http.MultipartFile('image_$i',
            images[i].readAsBytes().asStream(), images[i].lengthSync(),
            filename: 'image_$i.jpg'));
      }

      request.fields.addAll({
        'id_maniobra': widget.id_maniobra.toString(),
        'referencia': widget.referencia.toString(),
        'id_estatus': widget.id_status.toString(),
        'estatus_nombre': widget.status_nombre.toString(),
        'comentarios': comentarios.text.toString(),
        'latitud': widget.latitud.toString(),
        'longitud': widget.longitud.toString(),
        'calle': widget.calle.toString(),
        'localidad': widget.localidad.toString(),
        'sublocalidad': widget.sublocalidad.toString(),
        'codigo_postal': widget.codigo_postal.toString(),
        'id_operador': id_operador.toString(),
        'id_vehiculo': widget.id_vehiculo.toString(),
      });

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 90));

      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.body == '1') {
        showNotificacion('¡estatus enviado con éxito!', '');
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) =>
                  EstatusOperadorManiobra(id_maniobra: widget.id_maniobra)),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
        error_alert(
          'Error: No se logro el envio',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SlidingUpPanel(
        color: Colors.white,
        maxHeight: 700.00,
        minHeight: 500.00,
        parallaxEnabled: true,
        parallaxOffset: .5,
        panelBuilder: (sc) => _panel(sc),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        body: Stack(
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                height: constraints.maxHeight / 2.5,
                child: FlutterMap(
                  options: MapOptions(
                      center: LatLng(widget.latitud, widget.longitud),
                      initialCenter: LatLng(widget.latitud, widget.longitud),
                      initialZoom: 13,
                      interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.doubleTapZoom)),
                  children: [
                    openStreetMapTileLayer,
                    MarkerLayer(markers: [
                      Marker(
                          point: LatLng(widget.latitud, widget.longitud),
                          child: const Icon(
                            Icons.location_pin,
                            size: 60,
                            color: Colors.red,
                          ))
                    ])
                  ],
                ),
              );
            })
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        child: FloatingActionButton.extended(
          onPressed: () {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.confirm,
              text: 'Para validar el envio presiona confirmar.',
              title: '',
              confirmBtnText: 'Confirmar',
              cancelBtnText: 'Cancelar',
              confirmBtnColor: Color.fromARGB(255, 34, 69, 151),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              cancelBtnTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 34, 69, 151),
                  fontFamily: 'Product Sans'),
              confirmBtnTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Product Sans'),
              titleColor: const Color.fromARGB(255, 0, 0, 0),
              textColor: const Color.fromARGB(255, 0, 0, 0),
              onConfirmBtnTap: () async {
                enviar_status();
              },
            );
          },
          backgroundColor: const Color.fromARGB(255, 34, 69, 151),
          label: const Text(
            'Enviar estatus',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Product Sans', fontSize: 20),
          ),
          icon: const Icon(
            Icons.send,
            size: 25,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  Widget _panel(ScrollController sc) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Card(
            color: backgroundColor.withOpacity(0.2),
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: backgroundColor.withOpacity(0.5),
                child: Hero(
                  tag: 'statusImage_${widget.id_status}',
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
                widget.status_nombre,
                style:
                    const TextStyle(fontFamily: 'Product Sans', fontSize: 25),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                'Añadir imagenes:',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  color: background,
                  fontSize: 16,
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
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
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
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
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
                                        Icon(Icons.warning, color: Colors.red),
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
              Text(
                'Añadir comentarios: ',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  color: backgroundColor,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: comentarios,
                style: const TextStyle(
                  fontFamily: 'Product Sans',
                  fontSize: 12.0,
                  color: Colors.black,
                ),
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: backgroundColor.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Escribe un comentario aquí :)',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 36.0,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleafflet.flutter_map.example',
      );
}
