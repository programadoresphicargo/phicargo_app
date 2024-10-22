import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phicargo/Comunicados/index.dart';
import 'package:phicargo/Bonos/index.dart';
import 'package:phicargo/Contactos/index.dart';
import 'package:phicargo/Reportes_fallas/menu_principal.dart';
import 'package:phicargo/Estatus/Pantalla_principal/MiViaje.dart';
import 'package:phicargo/drawer.dart';
import 'package:phicargo/Turnos/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Conexion/Conexion.dart';
import 'Maniobras/maniobra_info.dart';

class Nav extends StatefulWidget {
  int selectedIndex = 0;

  Nav({required this.selectedIndex});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _currentIndex = 0;
  int actual_count = 0;
  int save_count = 0;
  String tipo_usuario = '25';

  Future<void> leer_usuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? variableValue = prefs.getString('tipo');
    setState(() {
      print(variableValue);
      tipo_usuario = variableValue.toString();
      cambiar_lista();
    });
  }

  List _screens = [
    Turnos(),
    Comunicados(),
    GridViewDemo(),
    Bonos(),
    Maniobras(),
    MiViaje(),
    menu_principal_fallas(),
  ];

  void cambiar_lista() {
    if (tipo_usuario == '55') {
      setState(() {
        _screens = [
          Turnos(),
          Comunicados(),
          GridViewDemo(),
          Maniobras(),
          MiViaje(),
          menu_principal_fallas(),
        ];
      });
    } else if (tipo_usuario == '26') {
      _screens = [
        Comunicados(),
        GridViewDemo(),
        Maniobras(),
        MiViaje(),
        menu_principal_fallas(),
      ];
    } else {
      _screens = [
        Turnos(),
        Comunicados(),
        GridViewDemo(),
        Bonos(),
        Maniobras(),
        MiViaje(),
        menu_principal_fallas(),
      ];
    }
  }

  void _updateIndex(int value) {
    setState(() {
      widget.selectedIndex = value;
      _currentIndex = widget.selectedIndex;
      print(_currentIndex);
    });
  }

  _loadStoredRecordsCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      save_count = prefs.getInt('recordsCount') ?? 0;
    });
    print('guardado' + save_count.toString());
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
        print(jsonDecode(response.body).length);
        setState(() {
          actual_count = jsonDecode(response.body).length;
        });
        print('ACTUAL' + actual_count.toString());
      } else {
        throw Exception('Error de solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al realizar la solicitud HTTP4: $e');
    }
  }

  @override
  void initState() {
    _updateIndex(widget.selectedIndex);
    super.initState();
    leer_usuario();
    fetchDatos();
    _loadStoredRecordsCount();
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      if (tipo_usuario != '26')
        const BottomNavigationBarItem(
          label: 'Turnos',
          icon: Icon(Icons.format_list_numbered_sharp),
        ),
      BottomNavigationBarItem(
        icon: Stack(
          children: [
            const Icon(Icons.newspaper_rounded),
            if (actual_count - save_count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    (actual_count - save_count).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        label: 'Boletines',
      ),
      const BottomNavigationBarItem(
        label: "Contactos",
        icon: Icon(Icons.phone),
      ),
      if (tipo_usuario != '55' && tipo_usuario != '26')
        const BottomNavigationBarItem(
          label: "Bonos",
          icon: Icon(Icons.attach_money_sharp),
        ),
      const BottomNavigationBarItem(
        label: "Maniobras",
        icon: Icon(Icons.anchor_sharp),
      ),
      const BottomNavigationBarItem(
        label: "Viaje",
        icon: Icon(Icons.place),
      ),
      const BottomNavigationBarItem(
        label: "Reportes",
        icon: Icon(Icons.description),
      ),
    ];

    return Scaffold(
      drawer: NavigationDrawerWidget(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _updateIndex,
        selectedItemColor: Colors.blue.shade800,
        selectedLabelStyle: const TextStyle(fontFamily: 'Product Sans'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Product Sans'),
        selectedFontSize: 13,
        unselectedFontSize: 13,
        elevation: 2,
        iconSize: 25,
        items: items,
      ),
    );
  }
}
