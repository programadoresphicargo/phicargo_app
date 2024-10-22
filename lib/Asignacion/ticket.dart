import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget Ticket(
    String id,
    String sucursal,
    String ruta,
    String modalidad,
    String hora,
    String custodia,
    String ejecutiva,
    String clase,
    String categoria) {
  return Padding(
    padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: SizedBox(
                      height: 8,
                      width: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 34, 69, 151),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: <Widget>[
                          SizedBox(
                            height: 24,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  children: List.generate(
                                      (constraints.constrainWidth() / 6)
                                          .floor(),
                                      (index) => SizedBox(
                                            height: 1,
                                            width: 3,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey),
                                            ),
                                          )),
                                  direction: Axis.horizontal,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                );
                              },
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Center(
                                child: Image.asset(
                              'assets/carrito2.png',
                              height: 35,
                              matchTextDirection: true,
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: SizedBox(
                      height: 8,
                      width: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 94, 185, 38),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      ruta,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 94, 185, 38)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                      width: 100,
                      child: Text(
                        sucursal,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )),
                  Text(
                    "",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                      width: 100,
                      child: Text(
                        ruta,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Ejecutiva",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ejecutiva,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "Viaje No : ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        id,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 20,
                width: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: Colors.grey.shade200),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        children: List.generate(
                            (constraints.constrainWidth() / 10).floor(),
                            (index) => SizedBox(
                                  height: 1,
                                  width: 5,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade400),
                                  ),
                                )),
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
                width: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      color: Colors.grey.shade200),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: Offset(0, 4),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24))),
          child: Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (modalidad == 'single'
                          ? Color.fromARGB(255, 22, 198, 48)
                          : Color.fromARGB(255, 154, 4, 4)),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text((modalidad == 'single' ? 'SENCILLO' : 'FULL'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ))),
              SizedBox(
                width: 16,
              ),
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (custodia == 'yes'
                          ? Color.fromARGB(255, 255, 174, 0)
                          : Color.fromARGB(255, 255, 255, 255)),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text((custodia == 'yes' ? 'CUSTODIA' : ''),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ))),
              SizedBox(
                width: 16,
              ),
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (Colors.blue),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text((clase),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ))),
              Text("",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey)),
              Expanded(
                  child: Text("",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
            ],
          ),
        ),
      ],
    ),
  );
}
