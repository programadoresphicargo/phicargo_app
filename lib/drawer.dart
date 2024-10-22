import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phicargo/Login/Perfil.dart';
import 'package:phicargo/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20);
  late String nombre_op = '';
  late String tipo = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre_op = (prefs.getString('nombre') ?? '');
      tipo = (prefs.getString('tipo') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = nombre_op;
    final email = '';

    return Drawer(
      child: Material(
        color: Color.fromARGB(255, 34, 69, 151),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/phicargo.png',
              color: Colors.white,
              height: 75,
            ),
            buildHeader(
              name: name,
              email: email,
              onClicked: () => Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (context) => Perfil())),
            ),
            listado(tipo: tipo),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/auxuser.png')),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget listado({required String tipo}) {
    if (tipo == '26') {
      return Container(
        padding: padding,
        child: Column(
          children: [
            const SizedBox(height: 30),
            buildMenuItem(
              text: 'Boletines',
              icon: Icons.newspaper_rounded,
              onClicked: () => selectedItem(context, 0),
            ),
            const SizedBox(height: 5),
            buildMenuItem(
              text: 'Contactos',
              icon: Icons.phone,
              onClicked: () => selectedItem(context, 1),
            ),
            const SizedBox(height: 5),
            buildMenuItem(
              text: 'Maniobras',
              icon: Icons.anchor_sharp,
              onClicked: () => selectedItem(context, 2),
            ),
            const SizedBox(height: 5),
            buildMenuItem(
              text: 'Viaje',
              icon: Icons.location_on_sharp,
              onClicked: () => selectedItem(context, 3),
            ),
            const SizedBox(height: 5),
            buildMenuItem(
              text: 'Reporte de fallas',
              icon: Icons.report_problem_sharp,
              onClicked: () => selectedItem(context, 4),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    } else if (tipo == '55') {
      return Container(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 30),
              buildMenuItem(
                text: 'Turnos',
                icon: Icons.format_list_numbered_rounded,
                onClicked: () => selectedItem(context, 0),
              ),
              buildMenuItem(
                text: 'Boletines',
                icon: Icons.newspaper_rounded,
                onClicked: () => selectedItem(context, 1),
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                text: 'Contactos',
                icon: Icons.phone,
                onClicked: () => selectedItem(context, 2),
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                text: 'Maniobras',
                icon: Icons.anchor_sharp,
                onClicked: () => selectedItem(context, 3),
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                text: 'Viaje',
                icon: Icons.location_on_sharp,
                onClicked: () => selectedItem(context, 4),
              ),
              buildMenuItem(
                text: 'Reporte de fallas',
                icon: Icons.report_problem_sharp,
                onClicked: () => selectedItem(context, 5),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 30),
            ],
          ));
    } else {
      return Container(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 30),
              buildMenuItem(
                text: 'Turnos',
                icon: Icons.format_list_numbered_rounded,
                onClicked: () => selectedItem(context, 0),
              ),
              buildMenuItem(
                text: 'Boletines',
                icon: Icons.newspaper_rounded,
                onClicked: () => selectedItem(context, 1),
              ),
              buildMenuItem(
                text: 'Contactos',
                icon: Icons.phone,
                onClicked: () => selectedItem(context, 2),
              ),
              buildMenuItem(
                text: 'Bonos',
                icon: Icons.attach_money_rounded,
                onClicked: () => selectedItem(context, 3),
              ),
              buildMenuItem(
                text: 'Maniobras',
                icon: Icons.anchor_sharp,
                onClicked: () => selectedItem(context, 4),
              ),
              buildMenuItem(
                text: 'Viaje',
                icon: Icons.location_on_sharp,
                onClicked: () => selectedItem(context, 5),
              ),
              buildMenuItem(
                text: 'Reporte de fallas',
                icon: Icons.description,
                onClicked: () => selectedItem(context, 6),
              ),
              const SizedBox(height: 30),
            ],
          ));
    }
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 16,
              color: color,
              fontFamily: 'Product Sans')),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => Nav(
          selectedIndex: index,
        ),
      ),
    );
  }
}
