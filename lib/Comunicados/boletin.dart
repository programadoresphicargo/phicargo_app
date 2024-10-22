import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:phicargo/Comunicados/vista_previa.dart';
import 'package:phicargo/Metodos/diferencia_tiempo.dart';
import 'package:phicargo/drawer.dart';
import '../Conexion/Conexion.dart';

class boletin extends StatefulWidget {
  @override
  late String id_comunicado;
  late String titulo;
  late String descripcion;
  late String usuario;
  late String fecha_hora;

  boletin({
    required this.id_comunicado,
    required this.titulo,
    required this.usuario,
    required this.descripcion,
    required this.fecha_hora,
  });

  _boletinState createState() => _boletinState();
}

class _boletinState extends State<boletin> {
  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Product Sans',
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Comunicado(
          id_comunicado: widget.id_comunicado,
          usuario: widget.usuario,
          fecha_hora: widget.fecha_hora,
          titulo: widget.titulo,
          descripcion: widget.descripcion,
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
  final String fecha_hora;

  Comunicado({
    required this.id_comunicado,
    required this.titulo,
    required this.usuario,
    required this.descripcion,
    required this.fecha_hora,
  });

  @override
  State<Comunicado> createState() => _boletintate();
}

class _boletintate extends State<Comunicado> {
  List<String> imageUrls = [];

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
  void initState() {
    super.initState();
    fetchFotos();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(200)),
                  child: Image.asset(
                    'assets/usuario.png',
                    width: 50,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.usuario,
                          style: const TextStyle(
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
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
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(widget.descripcion),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: CarouselSlider(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
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
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.favorite_outline_sharp),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
