import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phicargo/Contactos/cards.dart';
import 'package:phicargo/Contactos/contactos.dart';
import 'package:phicargo/Contactos/modelo_departamento.dart';
import 'package:phicargo/Contactos/services.dart';
import 'package:phicargo/drawer.dart';
import 'package:http/http.dart' as http;

import '../Conexion/Conexion.dart';
import 'perfil.dart';

class GridViewDemo extends StatefulWidget {
  GridViewDemo() : super();

  final String title = "Contactos";

  @override
  GridViewDemoState createState() => GridViewDemoState();
}

class GridViewDemoState extends State<GridViewDemo> {
  //
  StreamController<int> streamController = new StreamController<int>();
  List<dynamic> data = [];
  bool isLoading = true;

  gridview(AsyncSnapshot<List<Departamento>> snapshot) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: snapshot.data!.map(
          (album) {
            return GestureDetector(
              child: GridTile(
                child: AlbumCell(
                  context,
                  album,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => searchpage(
                      id_departamento: album.id_departamento,
                      nombre_departamento: album.nombre_departamento,
                    ),
                  ),
                );
              },
            );
          },
        ).toList(),
      ),
    );
  }

  Future<List<dynamic>> fetchData() async {
    final response = await http
        .get(Uri.parse('${conexion}phicargo/app/contactos/getFav.php'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  circularProgress() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        child: Column(children: [
          Lottie.asset('assets/car.json'),
          SizedBox(
            width: 15,
          ),
          Text(
            'Cargando...',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 34, 69, 151)),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: StreamBuilder(
          initialData: 0,
          stream: streamController.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Text(
              '${widget.title}',
              style: const TextStyle(
                  fontFamily: 'Product Sans', color: Colors.white),
            );
          },
        ),
      ),
      drawer: NavigationDrawerWidget(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FutureBuilder<List<dynamic>>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = snapshot.data![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.blue.shade800,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: (() {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => Profile(
                                        user: 'holi',
                                        foto: item['foto'],
                                        nombre: item['nombre_empleado'] +
                                            ' ' +
                                            item['apellido_paterno'] +
                                            ' ' +
                                            item['apellido_materno'],
                                        numero: item['NUMERO_CELULAR'],
                                        puesto: item['puesto'],
                                      ),
                                    ),
                                  );
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        item['puesto'],
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            fontSize: 24,
                                            color: Colors.white),
                                      ),
                                      Container(height: 10),
                                      Text(item['NUMERO_CELULAR'],
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[200])),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.blue[800],
              onRefresh: () async {
                setState(
                  () {
                    Services.getPhotos();
                  },
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: FutureBuilder<List<Departamento>>(
                      future: Services.getPhotos(),
                      builder: (context, snapshot) {
                        // not setstate here
                        //
                        if (snapshot.hasError) {
                          return Text('Error 1. ${snapshot.error}');
                        }
                        //
                        if (snapshot.hasData) {
                          streamController.sink.add(snapshot.data!.length);
                          // gridview
                          return gridview(snapshot);
                        }

                        return circularProgress();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}
