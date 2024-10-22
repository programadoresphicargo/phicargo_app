import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phicargo/Bonos/meses.dart';
import 'package:phicargo/Bonos/transaccion.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Contactos/perfil.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

final busqueda = TextEditingController();

class OperadoresBonos extends StatefulWidget {
  String month;
  String year;

  OperadoresBonos({required this.month, required this.year});

  @override
  State<OperadoresBonos> createState() => _OperadoresBonosState();
}

class _OperadoresBonosState extends State<OperadoresBonos> {
  final search = TextEditingController();
  bool loading = true;
  var jsondata;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _newlist = [];
  getdata() async {
    try {
      var response = await http.post(
          Uri.parse("${conexion}/phicargo/app/bonos/getOperadores.php"),
          body: {
            'mes': widget.month,
            'año': widget.year,
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        print(widget.month);
        jsondata = json.decode(response.body);

        print(jsondata);
        print('-->');
        print(widget.year);
        print('-->');
      } else {
        print("Error");
      }
      for (var i = 0; i < jsondata.length; i++) {
        _allUsers.add({
          "nombre_operador": jsondata[i]["nombre_operador"],
          "km_recorridos": jsondata[i]["km_recorridos"],
          "excelencia": jsondata[i]["excelencia"],
          "productividad": jsondata[i]["productividad"],
          "operacion": jsondata[i]["operacion"],
          "seguridad_vial": jsondata[i]["seguridad_vial"],
          "cuidado_unidad": jsondata[i]["cuidado_unidad"],
          "rendimiento": jsondata[i]["rendimiento"],
          "calificacion": jsondata[i]["calificacion"],
          "total": jsondata[i]["total"],
        });
      }

      //TO SHOW ALL LIST AT INITIAL
      setState(() {
        loading = false;
        _newlist = _allUsers;
      });
    } on Error catch (e) {
      print('ERROR 044');
    }
  }

  //
  @override
  void initState() {
    loading = true;
    super.initState();
    getdata();
  }

  Future refresh() async {
    _newlist = _allUsers;
  }

  void _searchlist(String value) {
    setState(() {
      if (value.isEmpty) {
        _newlist = _allUsers;
      } else {
        _newlist = _allUsers
            .where((element) => (element['nombre_operador'])
                .toString()
                .toLowerCase()
                .contains(value.toString().toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 34, 69, 151),
        centerTitle: true,
        title: Text(
          monthsInYear[widget.month]! + ' ' + widget.year,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: Container(
          child: Column(
            children: [
              Container(
                height: 73,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 34, 69, 151),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 43,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: busqueda,
                          onChanged: (value) {
                            _searchlist(value);
                          },
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                          cursorColor: Color.fromARGB(255, 255, 255, 255),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _newlist = _allUsers;

                                      busqueda.clear();
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.white.withOpacity(0.3),
                                  )),
                              hintText: "Busqueda",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 17)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: loading == true
                    ? Center(
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
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 34, 69, 151)),
                            )
                          ]),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(15),
                        itemCount: _newlist.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (() {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => TransactionPage(
                                    km_recorridos: _newlist[index]
                                            ['km_recorridos']
                                        .toString(),
                                    excelencia: _newlist[index]['excelencia']
                                        .toString(),
                                    productividad: _newlist[index]
                                            ['productividad']
                                        .toString(),
                                    operacion:
                                        _newlist[index]['operacion'].toString(),
                                    seguridad_vial: _newlist[index]
                                            ['seguridad_vial']
                                        .toString(),
                                    rendimiento: _newlist[index]['rendimiento']
                                        .toString(),
                                    calificacion: _newlist[index]
                                            ['calificacion']
                                        .toString(),
                                    cuidado_unidad: _newlist[index]
                                            ['cuidado_unidad']
                                        .toString(),
                                    total: _newlist[index]['total'].toString(),
                                    operador: _newlist[index]['nombre_operador']
                                        .toString(),
                                  ),
                                ),
                              );
                            }),
                            child: Operador(
                              user: _newlist[index]['nombre_operador'],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Operador({
  required String user,
}) {
  return Container(
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
            'assets/perfil.png',
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
                user,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ))
      ],
    ),
  );
}
