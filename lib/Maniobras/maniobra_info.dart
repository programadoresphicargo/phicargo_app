import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Maniobras/enviados.dart';
import 'package:phicargo/Maniobras/formulario_step1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import '../Estatus/convertir_tiempos.dart';
import 'package:responsive_grid/responsive_grid.dart';

class Maniobras extends StatefulWidget {
  @override
  _ManiobrasState createState() => _ManiobrasState();
}

class _ManiobrasState extends State<Maniobras> {
  var data;
  var length;

  fetchDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    try {
      var response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/maniobras/getManiobra.php'),
          body: {
            'operador_id': id.toString(),
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        print(data);
        length = jsonDecode(response.body).length;
      } else {
        throw Exception('Error de solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al realizar la solicitud HTTP: $e');
    }
  }

  Future refresh() async {
    setState(() {
      fetchDatos();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text(
          'Mi Maniobra',
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Colors.blue.shade800,
        child: FutureBuilder(
          future: fetchDatos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.blue.shade800,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/car.json', height: 150),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Obteniendo maniobra,\nfavor espere un segundo...',
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 15,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Container(
                  color: Colors.lightBlue.shade800,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/nowifi.png', height: 150),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            '¡Ocurrió un error!\nVerifica tu conexión a internet.',
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontSize: 15,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white)),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Volver",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800),
                                      )),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    refresh();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white)),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Reintentar",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ]),
                  ),
                );
              } else {
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: false,
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (context, index) {
                    return Maniobra_info(
                      id_maniobra: data[index]['id_maniobra'].toString(),
                      terminal: data[index]['terminal'].toString(),
                      tipo_maniobra: data[index]['tipo_maniobral'].toString(),
                      inicio_programado:
                          data[index]['inicio_programado'].toString(),
                      vehiculo: data[index]['vehicle_name'].toString(),
                      remolque1: data[index]['trailer1_name'].toString(),
                      remolque2: data[index]['trailer2_name'].toString(),
                      dolly: data[index]['dolly_name'].toString(),
                      estado_maniobra:
                          data[index]['estado_maniobra'].toString(),
                    );
                  },
                );
              }
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class equipo extends StatelessWidget {
  String titulo;
  String nombre;
  String icono;

  equipo({
    Key? key,
    required this.titulo,
    required this.nombre,
    required this.icono,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: SizedBox(
              width: 20,
              height: 20,
              child: Image.asset(icono),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontSize: 15, fontFamily: 'Product Sans'),
            ),
            subtitle: Text(nombre),
          ),
        ],
      ),
    );
  }
}

class Maniobra_info extends StatelessWidget {
  String id_maniobra;
  String tipo_maniobra;
  String terminal;
  String inicio_programado;
  String vehiculo;
  String remolque1;
  String remolque2;
  String dolly;
  String estado_maniobra;

  Maniobra_info({
    Key? key,
    required this.id_maniobra,
    required this.tipo_maniobra,
    required this.terminal,
    required this.inicio_programado,
    required this.vehiculo,
    required this.remolque1,
    required this.remolque2,
    required this.dolly,
    required this.estado_maniobra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Badge(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              backgroundColor: Colors.blue.shade800,
              largeSize: 20,
              textStyle: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Product Sans'),
              textColor: Colors.white,
              label: Text(
                'Maniobra M-$id_maniobra',
                style: const TextStyle(fontSize: 25),
              ),
              isLabelVisible: true,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('Terminal',
              style: TextStyle(
                fontFamily: 'Product Sans',
                color: Colors.grey,
                fontSize: 14,
              )),
          Text((terminal),
              style: const TextStyle(
                fontSize: 20,
              )),
          const SizedBox(
            height: 15,
          ),
          const Text(('Inicio programado'),
              style: TextStyle(
                fontFamily: 'Product Sans',
                color: Colors.grey,
                fontSize: 14,
              )),
          Text(
            (inicio_programado),
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Badge(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              backgroundColor: Colors.blue,
              largeSize: 20,
              textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Product Sans'),
              textColor: Colors.white,
              label: Text(
                'Equipo asignado',
                style: TextStyle(fontSize: 12),
              ),
              isLabelVisible: true,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ResponsiveGridRow(
            children: [
              ResponsiveGridCol(
                xs: 6,
                md: 3,
                child: Container(
                  height: 100,
                  alignment: Alignment(0, 0),
                  child: equipo(
                      titulo: 'Vehiculo',
                      nombre: vehiculo,
                      icono: 'assets/usuario.png'),
                ),
              ),
              ResponsiveGridCol(
                xs: 6,
                md: 3,
                child: Container(
                  height: 100,
                  alignment: Alignment(0, 0),
                  child: equipo(
                      titulo: 'Remolque 1',
                      nombre: remolque1,
                      icono: 'assets/usuario.png'),
                ),
              ),
              ResponsiveGridCol(
                xs: 6,
                md: 3,
                child: Container(
                  height: 100,
                  alignment: Alignment(0, 0),
                  child: equipo(
                      titulo: 'Remolque 2',
                      nombre: remolque2,
                      icono: 'assets/usuario.png'),
                ),
              ),
              ResponsiveGridCol(
                xs: 6,
                md: 3,
                child: Container(
                  height: 100,
                  alignment: Alignment(0, 0),
                  child: equipo(
                      titulo: 'Dolly',
                      nombre: dolly,
                      icono: 'assets/usuario.png'),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: estado_maniobra == 'activa'
                  ? () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => EnviarStatusManiobras(
                              id_cp: id_maniobra,
                              referencia: 'referencia',
                              contenedor: 'contenedores',
                              tipo: '',
                              tipoterminal: 'tipoterminal,'),
                        ),
                      );
                    }
                  : null,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  'Enviar nuevo estatus',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    color: Colors.white,
                    fontSize: 18,
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
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Estatus enviados",
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.timeline_sharp,
                    size: 24.0,
                    color: Colors.white,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => Status_Enviados_Maniobras(
                      referencia: ' referencia',
                      id_cp: id_maniobra,
                      tipo: ' tipo',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
