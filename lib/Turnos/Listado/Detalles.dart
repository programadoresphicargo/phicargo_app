import 'package:flutter/material.dart';

class Detalles extends StatelessWidget {
  final int turno;
  final String nombre;
  final String eco;
  final String fecha;
  final String hora;
  final String comentarios;

  const Detalles(
      {required this.turno,
      required this.nombre,
      required this.eco,
      required this.fecha,
      required this.hora,
      required this.comentarios});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 5,
                width: 60,
                color: Color.fromARGB(255, 34, 69, 151),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(children: [
                      Container(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/usuario.png'),
                          )),
                      SizedBox(width: 20),
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 34, 69, 151),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/status/car.png',
                                    height: 40,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Unidad: ' + eco,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 15,
                                      )),
                                ],
                              )
                            ]),
                      )
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromARGB(255, 34, 69, 151)),
                    child: Row(
                      children: [
                        Icon(Icons.numbers_sharp,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        Text(
                          (turno + 1).toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      'ESPECIFICACIONES DEL TURNO',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 178, 180, 181)),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(('FECHA DE LLEGADA:'),
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 34, 69, 151),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Icon(
                                    Icons.date_range_outlined,
                                    color: Color.fromARGB(255, 34, 69, 151),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text((fecha),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 15,
                                      )),
                                ]),
                          ),
                          Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(('HORA DE LLEGADA:'),
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 34, 69, 151),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: Color.fromARGB(255, 34, 69, 151),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text((hora),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 15,
                                      )),
                                ]),
                          )
                        ]),
                    SizedBox(
                      height: 30,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(('COMENTARIOS:'),
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 34, 69, 151),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: 5,
                              ),
                              Icon(
                                Icons.comment_outlined,
                                color: Color.fromARGB(255, 34, 69, 151),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text((comentarios),
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 15,
                                  )),
                            ]),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
