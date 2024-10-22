import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Contactos/perfil.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

final busqueda = TextEditingController();

class searchpage extends StatefulWidget {
  String id_departamento;
  String nombre_departamento;

  searchpage(
      {required this.nombre_departamento, required this.id_departamento});

  @override
  State<searchpage> createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  final search = TextEditingController();
  bool loading = true;

  var jsondata;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _newlist = [];
  getdata() async {
    try {
      var response = await http.post(
          Uri.parse(
              "${conexion}/phicargo/app/contactos/getNumerosEmpleados.php"),
          body: {
            'id_departamento': widget.id_departamento,
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        print(widget.id_departamento);
        jsondata = json.decode(response.body);

        print(jsondata);
        print('-->');
        print(widget.id_departamento);
        print('-->');
      } else {
        print("Error");
      }
      for (var i = 0; i < jsondata.length; i++) {
        _allUsers.add({
          "nombre_empleado": jsondata[i]["nombre_empleado"] +
              ' ' +
              jsondata[i]["apellido_paterno"] +
              ' ' +
              jsondata[i]["apellido_materno"],
          "id_activo": jsondata[i]["id_activo"],
          "puesto": jsondata[i]["puesto"],
          "NUMERO_CELULAR": jsondata[i]["NUMERO_CELULAR"],
          "foto": jsondata[i]["foto"],
        });
      }

      //TO SHOW ALL LIST AT INITIAL
      setState(() {
        loading = false;
        _newlist = _allUsers;
      });
    } on Error catch (e) {
      print('ERROR 404');
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
            .where((element) => (element['nombre_empleado'] + element['puesto'])
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
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: Text(
          widget.nombre_departamento,
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Colors.blue.shade700,
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
            : Container(
                child: Column(
                  children: [
                    Container(
                      height: 73,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
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
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _newlist.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (() {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                    builder: (context) => Profile(
                                          user: 'holi',
                                          foto: _newlist[index]['foto'],
                                          nombre: _newlist[index]
                                              ['nombre_empleado'],
                                          numero: _newlist[index]
                                              ['NUMERO_CELULAR'],
                                          puesto: _newlist[index]['puesto'],
                                        )),
                              );
                            }),
                            child: Contacto(
                              user: _newlist[index]['nombre_empleado'],
                              age: _newlist[index]['puesto'],
                              numero: _newlist[index]['NUMERO_CELULAR'],
                              foto: _newlist[index]['foto'],
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

Contacto(
    {required String user,
    required String age,
    required String numero,
    required String foto}) {
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
          child: foto != '0'
              ? Image.network(
                  foto,
                  height: 60,
                  width: 60,
                )
              : Image.asset(
                  'assets/perfil.png',
                  height: 60,
                  width: 60,
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
              Text(
                age,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ))
      ],
    ),
  );
}
