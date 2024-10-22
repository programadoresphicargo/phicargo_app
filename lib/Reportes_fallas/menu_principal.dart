import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phicargo/Reportes_fallas/reportes_app.dart';
import 'package:phicargo/Reportes_fallas/reportes_mecanicos.dart';
import 'package:phicargo/Reportes_fallas/form_app.dart';

class menu_principal_fallas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
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
        title: const Text(
          'Reportes de fallas',
          style: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => reporte_fallas_app(),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/fondo333.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text('Reporte de app',
                          style: TextStyle(
                              fontSize: 20, fontFamily: 'Product Sans')),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => Reporte_fallas(),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/mecanico.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Fallas mecánicas',
                        style:
                            TextStyle(fontSize: 20, fontFamily: 'Product Sans'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
