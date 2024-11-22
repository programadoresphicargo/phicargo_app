import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:lottie/lottie.dart';
import 'package:phicargo/Maniobras/Maniobra.dart';
import 'package:phicargo/Maniobras/Seleccion_estatus/formulario_envio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../Conexion/Conexion.dart';
import '../../Ubicacion/ubicacion.dart';
import 'ItemStatus.dart';
import '../cuerpo.dart';

class seleccion_estatus_maniobra extends StatefulWidget {
  String id_maniobra;
  String referencia;
  String id_vehiculo;
  seleccion_estatus_maniobra(
      {required this.id_maniobra,
      required this.referencia,
      required this.id_vehiculo,
      super.key});

  @override
  State<seleccion_estatus_maniobra> createState() => _StatusState();
}

class _StatusState extends State<seleccion_estatus_maniobra> {
  loc.LocationData? locationData;
  List<Placemark>? placemark;
  List<StatusItem> Listado = [];
  late Future<void> fetchDataFuture;

  Future<void> fetchData() async {
    String url = '${conexion}phicargo/aplicacion/maniobras/getEstatus.php';
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response);
        var data = jsonDecode(response.body);
        print('Datos obtenidos: $data');
        for (var item in data) {
          String id_status = item['id_status'].toString();
          String status_nombre = item['status'].toString();
          String imagen = item['imagen'].toString();

          Listado.add(StatusItem(id_status, status_nombre, imagen));
        }
      } else {
        print('Error->: ${response.statusCode}');
      }
    } catch (e) {
      print('Error->: $e');
    }
  }

  Future<void> PedirPermiso() async {
    if (await Permission.location.isGranted) {
      _getLocation();
      Permission.location.request();
    } else {
      Navigator.pop(context);
      Permission.location.request();
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
        calle = placemarks[0].street!;
        localidad = placemarks[0].locality!;
        sublocalidad = placemarks[0].subLocality!;
        ciudad = placemarks[0].country!;
        codigo_postal = placemarks[0].postalCode!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la dirección.'),
        ),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del Column
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/animaciones/location.json',
                    width: 230,
                    height: 230,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Obteniendo tu ubicación,\nespera un momento",
                    textAlign:
                        TextAlign.center, // Asegura que el texto esté centrado
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _getLocation() async {
    _showLoadingDialog(context);
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
          builder: (BuildContext context) => Maniobras(),
        ),
        (route) => false,
      );
    }
    _hideLoadingDialog();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await PedirPermiso();
    fetchDataFuture = fetchData();
    setState(() {});
  }

  int selectedService = -1;
  String id_status = '';
  String status_nombre = '';
  String referencia = '';
  String img = '';
  double latitud = 0.0;
  double longitud = 0.0;
  String calle = '';
  String localidad = '';
  String sublocalidad = '';
  String ciudad = '';
  String codigo_postal = '0';
  String fecha_hora = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Elige el estatus',
          style: TextStyle(
            fontFamily: 'Product Sans',
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 69, 151),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: selectedService >= 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => envio_estatus_form_maniobra(
                      id_status: id_status,
                      status_nombre: status_nombre,
                      url_imagen:
                          'https://phicargo-sistemas.online/phicargo/img/status/$img',
                      latitud: latitud,
                      longitud: longitud,
                      id_maniobra: widget.id_maniobra.toString(),
                      referencia: widget.referencia,
                      calle: calle,
                      localidad: localidad,
                      sublocalidad: sublocalidad,
                      codigo_postal: codigo_postal,
                      id_vehiculo: widget.id_vehiculo,
                    ),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(255, 34, 69, 151),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 25,
                color: Colors.white,
              ),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: fetchDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color.fromARGB(255, 34, 69, 151),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Cargando estatus',
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 15,
                            color: Color.fromARGB(255, 34, 69, 151)),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: Listado.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return ItemStatus(
                      id_stat: Listado[index].id_status,
                      title: Listado[index].status_nombre,
                      image: Listado[index].icono,
                      index: index,
                      selected: selectedService == index,
                      onTap: () {
                        setState(() {
                          selectedService =
                              selectedService == index ? -1 : index;
                          id_status = Listado[index].id_status;
                          status_nombre = Listado[index].status_nombre;
                          img = Listado[index].icono;
                        });
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
