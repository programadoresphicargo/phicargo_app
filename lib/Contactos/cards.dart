import 'package:flutter/material.dart';
import 'package:phicargo/Contactos/modelo_departamento.dart';

class AlbumCell extends StatelessWidget {
  const AlbumCell(this.context, this.album);
  @required
  final Departamento album;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Color.fromRGBO(245, 245, 245, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Image.asset(
                  album.icono,
                  width: 80,
                  height: 80,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  album.alias,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
