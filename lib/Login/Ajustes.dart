import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  bool _secureMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ajustes'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Secure Mode: ${_secureMode.toString()}\n'),
              ElevatedButton(
                  onPressed: () async {
                    final secureModeToggle = !_secureMode;

                    if (secureModeToggle == true) {
                      await FlutterWindowManager.addFlags(
                          FlutterWindowManager.FLAG_SECURE);
                    } else {
                      await FlutterWindowManager.clearFlags(
                          FlutterWindowManager.FLAG_SECURE);
                    }

                    setState(() {
                      _secureMode = !_secureMode;
                    });
                  },
                  child: const Text("Toggle Secure Mode")),
            ],
          ),
        ),
      ),
    );
  }
}
