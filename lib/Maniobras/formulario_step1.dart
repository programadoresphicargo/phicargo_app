import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phicargo/Maniobras/formulario_step2.dart';
import 'package:phicargo/Maniobras/maniobra_info.dart';
import 'package:phicargo/drawer.dart';
import '../Conexion/Conexion.dart';
import 'package:http/http.dart' as http;

import '../Ubicacion/ubicacion.dart';
import 'status.dart';

class EnviarStatusManiobras extends StatefulWidget {
  String id_cp;
  String referencia;
  String tipo;
  String contenedor;
  String tipoterminal;

  EnviarStatusManiobras(
      {super.key,
      required String this.id_cp,
      required String this.referencia,
      required String this.tipo,
      required String this.contenedor,
      required String this.tipoterminal});

  @override
  EnviarStatusManiobrasState createState() => EnviarStatusManiobrasState();
}

class EnviarStatusManiobrasState extends State<EnviarStatusManiobras> {
  loc.LocationData? locationData;
  List<Placemark>? placemark;
  StreamController<int> streamController = new StreamController<int>();

  int selectedService = -1;
  String idstatus = '';
  String status_name = '';
  String img = '';
  String ubicacion = '';

  double latitud = 0.0;
  double longitud = 0.0;
  String calle = '';
  String localidad = '';
  String sublocalidad = '';
  String ciudad = '';
  String codigo_postal = '0';
  String fecha_hora = '';

  bool loading = true;
  var jsondata;
  List<StatusItem> _allUsers = [];
  List<StatusItem> _newlist = [];

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
          builder: (BuildContext context) => Maniobras(),
        ),
        (route) => false,
      );
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

  Future<void> GetDireccion() async {
    if (locationData != null) {
      placemark = await placemarkFromCoordinates(
          locationData!.latitude!, locationData!.longitude!);

      print(placemark![0].street);
      print(placemark![0].locality);
      print(placemark![0].subLocality);
      print(placemark![0].postalCode);
      print(placemark![0].administrativeArea);

      setState(() {
        calle = placemark![0].street.toString();
        localidad = placemark![0].locality.toString();
        sublocalidad = placemark![0].subLocality.toString();
        ciudad = placemark![0].country.toString();
        codigo_postal = placemark![0].postalCode.toString();
      });
    }
  }

  Future<List<StatusItem>> getdata() async {
    try {
      var response = await http
          .post(Uri.parse(
              "$conexion/phicargo/aplicacion/maniobras/getEstatus.php"))
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print(jsondata);

        List<StatusItem> allUsers = [];
        for (var i = 0; i < jsondata.length; i++) {
          allUsers.add(StatusItem(
            jsondata[i]["id_status"],
            jsondata[i]["status"],
            jsondata[i]["imagen"].toString(),
            jsondata[i]["foto"] == '1',
            jsondata[i]["email"] == '1',
            jsondata[i]["comentarios"] == '1',
          ));
        }
        return allUsers;
      } else {
        print("Error en la obtención de los estatus");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  ItemStatus(String id_status, String status, String image, int index,
      bool comentario, bool foto, bool correo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedService == index) {
            selectedService = -1;
            idstatus = id_status;
            status_name = status;
            img = image;
          } else {
            selectedService = index;
            idstatus = id_status;
            status_name = status;
            img = image;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedService == index
              ? Colors.blue.shade800.withOpacity(.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: selectedService == index
                ? Colors.blue.shade800
                : Colors.grey.shade100,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
                '${conexion}phicargo/aplicacion/maniobras/iconos/$image',
                height: 80),
            const SizedBox(
              height: 5,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    PedirPermiso();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
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
        title: StreamBuilder(
          initialData: 0,
          stream: streamController.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return const Text(
              'Nuevo estatus',
              style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<StatusItem>>(
              future: getdata(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<StatusItem>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No data available'),
                  );
                } else {
                  List<StatusItem> data = snapshot.data!;
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: data.length,
                      physics: const ScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return ItemStatus(
                          data[index].id_status,
                          data[index].status,
                          data[index].imagen,
                          index,
                          data[index].comentarios,
                          data[index].foto,
                          data[index].email,
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: selectedService >= 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => FormStatusEnviarManiobra(
                      id_maniobra: widget.id_cp,
                      id_estatus: idstatus,
                      estatus_nombre: status_name,
                      latitud: latitud,
                      longitud: longitud,
                      calle: calle,
                      localidad: localidad,
                      sublocalidad: sublocalidad,
                      codigo_postal: codigo_postal,
                      url_imagen: img,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.blue[700],
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 25,
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}
