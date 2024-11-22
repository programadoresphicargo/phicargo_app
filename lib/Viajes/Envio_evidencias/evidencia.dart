import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../Conexion/Conexion.dart';
import '../../Ubicacion/ubicacion.dart';
import '../Pantalla_principal/MiViaje.dart';

class MyAppScan extends StatefulWidget {
  final String id_viaje;
  final String id_vehiculo;

  const MyAppScan({
    required this.id_viaje,
    required this.id_vehiculo,
  });

  @override
  State<MyAppScan> createState() => _MyAppState();
}

class _MyAppState extends State<MyAppScan> {
  List<String> _pictures = [];
  List<File> _pdfFiles = [];
  double? latitud;
  double? longitud;
  String? calle;
  String? localidad;
  String? sublocalidad;
  String? ciudad;
  String? codigoPostal;

  @override
  void initState() {
    super.initState();
    _getLocation();
    getEvidencias();
    initPlatformState();
    requestPermissions().then((_) => _loadPdfFiles());
  }

  Future<void> initPlatformState() async {}

  Future<void> _getLocation() async {
    final locationService = LocationService();
    final locationData = await locationService.getCurrentLocation();

    if (locationData != null) {
      setState(() {
        _getDireccion(locationData.latitude!, locationData.longitude!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio de ubicación no habilitado.'),
        ),
      );
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MiViaje(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _getDireccion(double latitude, double longitude) async {
    final geolocationService = GeolocationService();

    List<Placemark> placemarks =
        await geolocationService.getPlacemarks(latitude, longitude);

    if (placemarks.isNotEmpty) {
      setState(() {
        latitud = latitude;
        longitud = longitude;
        calle = placemarks[0].street;
        localidad = placemarks[0].locality;
        sublocalidad = placemarks[0].subLocality;
        ciudad = placemarks[0].country;
        codigoPostal = placemarks[0].postalCode;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la dirección.'),
        ),
      );
    }
  }

  Future<List<dynamic>> getEvidencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_operador = prefs.getString('id');

    try {
      final response = await http.post(
        Uri.parse('${conexion}phicargo/aplicacion/viajes/estatus_enviados.php'),
        body: {
          'id_viaje': widget.id_viaje.toString(),
          'id_operador': id_operador.toString(),
          'evidencias': '1'
        },
      ).timeout(const Duration(seconds: 90));

      print('estatus enviajes');
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } on TimeoutException catch (e) {
      throw Exception('Request timed out');
    } on SocketException catch (e) {
      throw Exception('No Internet connection');
    } on FormatException catch (e) {
      throw Exception('Invalid format');
    }
  }

  Future<Color> _updatePalette(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
      );
      return paletteGenerator.dominantColor?.color ?? Colors.grey;
    } catch (e) {
      // Handle exceptions if needed
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: const Text(
          'Evidencias',
          style: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Pendientes de envío',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 20,
                    color: Colors.red[900],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: _pdfFiles.isEmpty
                    ? const Center(
                        child: Text('No hay evidencias pendientes de envío.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _pdfFiles.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 180, 25, 13),
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                _pdfFiles[index].path.split('/').last,
                                style: const TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () async {
                                  File file = File(_pdfFiles[index].path);
                                  if (await sendPDF(file)) {
                                    await file.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Archivo enviado y eliminado.'),
                                      ),
                                    );
                                    setState(() {
                                      _pdfFiles.removeAt(index);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Error al enviar el archivo.'),
                                      ),
                                    );
                                  }
                                },
                                child: Icon(Icons.replay_outlined),
                              ),
                              onTap: () {
                                OpenFile.open(_pdfFiles[index].path);
                              },
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Enviadas',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 20,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FutureBuilder<List<dynamic>>(
                  future: getEvidencias(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue[700],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var item = snapshot.data![index];
                          String imageUrl = '${conexion}phicargo/img/status/' +
                              item['imagen'];

                          return FutureBuilder<Color>(
                            future: _updatePalette(imageUrl),
                            builder: (context, colorSnapshot) {
                              Color cardColor =
                                  colorSnapshot.data ?? Colors.white;
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            cardColor.withOpacity(0.5),
                                        child: Image.network(
                                          '${conexion}phicargo/img/status/' +
                                              item['imagen'],
                                        ),
                                      ),
                                      title: Text(
                                        item['nombre_estatus'],
                                        style: const TextStyle(
                                          fontFamily: 'Product Sans',
                                          fontSize: 20,
                                        ),
                                      ),
                                      subtitle: Text(item['fecha_envio']),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onPressed();
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de almacenamiento denegado.'),
          ),
        );
        return;
      }
    }
    _loadPdfFiles();
  }

  Future<void> _loadPdfFiles() async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      String docPath = docDir.path;
      Directory directory = Directory(docPath);
      List<FileSystemEntity> files = directory.listSync();

      List<File> pdfFiles = files
          .where((file) => file.path.endsWith('.pdf'))
          .map((file) => File(file.path))
          .toList();

      setState(() {
        _pdfFiles = pdfFiles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar PDFs: $e'),
        ),
      );
    }
  }

  Future<void> onPressed() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (pictures.isNotEmpty) {
        List<Uint8List> bytesList = [];
        for (String picturePath in pictures) {
          final bytes = await pictureToBytes(picturePath);
          bytesList.add(bytes);
        }

        final pdf = await generatePDF(bytesList);
        final file = await savePDFLocally(pdf);
        final bool success = await sendPDF(file);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF enviado exitosamente.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar el PDF. Guardado localmente.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron imágenes.'),
          ),
        );
      }
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener imágenes: $exception'),
        ),
      );
    }
  }

  Future<Uint8List> pictureToBytes(String picturePath) async {
    final image = img.decodeImage(File(picturePath).readAsBytesSync());
    final resizedImage = img.copyResize(image!, width: 800);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<Uint8List> generatePDF(List<Uint8List> bytesList) async {
    final pdf = pw.Document();

    for (Uint8List bytes in bytesList) {
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  Future<bool> sendPDF(File pdfFile) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enviando archivo'),
      ),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idOperador = prefs.getString('id');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${conexion}phicargo/aplicacion/viajes/enviar_evidencia.php'),
      );

      request.fields['id_viaje'] = widget.id_viaje;
      request.fields['id_operador'] = idOperador!;
      request.fields['latitud'] = latitud.toString();
      request.fields['longitud'] = longitud.toString();
      request.fields['calle'] = calle.toString();
      request.fields['localidad'] = localidad.toString();
      request.fields['sublocalidad'] = sublocalidad.toString();
      request.fields['codigo_postal'] = codigoPostal.toString();
      request.fields['id_vehiculo'] = widget.id_vehiculo;

      request.files.add(await http.MultipartFile.fromPath(
        'pdf_file',
        pdfFile.path,
      ));

      var response = await request.send().timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        bool esNumerico = num.tryParse(responseBody.body) != null;
        if (esNumerico) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Archivo enviado exitosamente: ${responseBody.body}'),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Respuesta del servidor: ${responseBody.body}'),
            ),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la solicitud: ${response.reasonPhrase}'),
          ),
        );
        return false;
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiempo de espera excedido al enviar el archivo.'),
        ),
      );
      return false;
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
      return false;
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de red: $e'),
        ),
      );
      return false;
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de formato: $e'),
        ),
      );
      return false;
    }
  }

  Future<File> savePDFLocally(Uint8List pdf) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      String docPath = docDir.path;
      String fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final File file = File('$docPath/$fileName');
      await file.writeAsBytes(pdf);
      print('PDF guardado localmente como $fileName.');
      return file;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el PDF localmente: $e'),
        ),
      );
      throw e;
    }
  }
}
