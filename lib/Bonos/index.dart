import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:phicargo/Bonos/meses.dart';
import 'package:phicargo/Bonos/operadores.dart';
import 'package:phicargo/drawer.dart';

import '../Conexion/Conexion.dart';

class Bonos extends StatefulWidget {
  @override
  _BonosState createState() => _BonosState();
}

class _BonosState extends State<Bonos> {
  late String data;
  bool loading = true;
  var superheros_length;
  @override
  void initState() {
    // TODO: implement initState
    loading = true;
    super.initState();
    getData();
  }

  void getData() async {
    http.Response response =
        await http.get(Uri.parse('${conexion}phicargo/app/bonos/getMeses.php'));
    if (response.statusCode == 200) {
      data = response.body;
      setState(() {
        loading = false;
        superheros_length = jsonDecode(data);
      });
      var venam = jsonDecode(data)[0]['mes'];
      print(venam);
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Bonos",
          style: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: Container(
          color: Color.fromARGB(255, 248, 246, 246),
          child: loading == true
              ? Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    child: Column(
                      children: [
                        Lottie.asset('assets/car.json'),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Cargando...',
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 34, 69, 151)),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount:
                      superheros_length == null ? 0 : superheros_length.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => OperadoresBonos(
                              year: jsonDecode(data)[index]['año'],
                              month: jsonDecode(data)[index]['mes'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/calendario.png',
                                height: 50,
                                width: 50,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      monthsInYear[jsonDecode(data)[index]
                                              ['mes']]! +
                                          ' ' +
                                          jsonDecode(data)[index]['año'],
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
