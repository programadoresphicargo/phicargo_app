import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:phicargo/Comunicados/boletin.dart';
import 'package:phicargo/Comunicados/vista_previa.dart';
import 'package:phicargo/Metodos/diferencia_tiempo.dart';
import 'package:phicargo/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Conexion/Conexion.dart';
import '../nav.dart';

class Comunicados extends StatefulWidget {
  @override
  _ComunicadosState createState() => _ComunicadosState();
}

class _ComunicadosState extends State<Comunicados> {
  var data;
  var length;
  bool CorreosLigadosAViaje = false;
  late String mensaje = '';

  _updateStoredRecordsCount(int newCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('recordsCount', newCount);
    print('Actualizo');
  }

  fetchDatos() async {
    try {
      var response = await http
          .get(
            Uri.parse(
                '${conexion}phicargo/app/comunicados/get_comunicados.php'),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        length = jsonDecode(response.body).length;
      } else {
        throw Exception('Error de solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al realizar la solicitud HTTP4: $e');
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
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        centerTitle: true,
        title: const Text(
          'Boletines',
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
                color: Colors.blue.shade700,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/car.json', height: 150),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Obteniendo boletines,\nfavor espere un segundo...',
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
                _updateStoredRecordsCount(data.length);
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: false,
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (context, index) {
                    return Comunicado(
                      id_comunicado: data[index]['id_comunicado'].toString(),
                      usuario: data[index]['nombre'].toString(),
                      fecha_hora: data[index]['fecha_hora'].toString(),
                      titulo: data[index]['titulo'].toString(),
                      descripcion: data[index]['descripcion'].toString(),
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

class Comunicado extends StatefulWidget {
  final String id_comunicado;
  final String titulo;
  final String usuario;
  final String descripcion;
  // ignore: non_constant_identifier_names
  final String fecha_hora;

  Comunicado({
    required this.id_comunicado,
    required this.titulo,
    required this.usuario,
    required this.descripcion,
    required this.fecha_hora,
  });

  @override
  State<Comunicado> createState() => _ComunicadoState();
}

class _ComunicadoState extends State<Comunicado> {
  var data;
  var length;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchFotos();
  }

  fetchFotos() async {
    try {
      var response = await http.post(
        Uri.parse('${conexion}phicargo/app/comunicados/get_fotos.php'),
        body: {'id_comunicado': widget.id_comunicado},
      ).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = jsonDecode(response.body);
          for (var item in jsonData) {
            imageUrls.add(item['nombre']);
          }
        });
      } else {
        throw Exception('Error de solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al realizar la solicitud HTTP5: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => boletin(
              id_comunicado: widget.id_comunicado,
              titulo: widget.titulo,
              descripcion: widget.descripcion,
              usuario: widget.usuario,
              fecha_hora: widget.fecha_hora,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(18.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(200)),
              child: Image.asset(
                'assets/usuario.png',
                width: 50,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 18.0, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.usuario,
                        style: const TextStyle(
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          printTime(widget.fecha_hora).toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 189, 189, 189),
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Chip(
                      label: Text(
                        widget.titulo,
                        style: const TextStyle(
                            fontFamily: 'Product Sans',
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.blue.shade800),
                  SizedBox(
                    height: 10,
                  ),
                  Text(widget.descripcion),
                  SizedBox(
                    height: 10,
                  ),
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                    ),
                    items: imageUrls.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => vista_foto(
                                    imagen:
                                        '${conexion}phicargo/comunicados/fotos/${widget.id_comunicado}/$imageUrl',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${conexion}phicargo/comunicados/fotos/${widget.id_comunicado}/$imageUrl'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.favorite_border),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
