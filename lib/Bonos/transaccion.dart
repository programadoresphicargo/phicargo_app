import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phicargo/Bonos/colors.dart';
import 'package:phicargo/Bonos/styles.dart';
import 'divider.dart';

class TransactionPage extends StatefulWidget {
  final String operador;

  final String km_recorridos;
  final String excelencia;
  final String productividad;
  final String operacion;
  final String seguridad_vial;
  final String cuidado_unidad;
  final String rendimiento;
  final String calificacion;
  final String total;

  TransactionPage({
    required this.operador,
    required this.km_recorridos,
    required this.excelencia,
    required this.productividad,
    required this.operacion,
    required this.seguridad_vial,
    required this.cuidado_unidad,
    required this.rendimiento,
    required this.calificacion,
    required this.total,
  });
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Detalles de bonos',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: Image.asset(
                  'assets/perfil.png',
                  fit: BoxFit.fill,
                  width: 55,
                  height: 100,
                  alignment: Alignment.center,
                ),
                title: Text(widget.operador),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KM RECORRIDOS',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text(widget.km_recorridos + ' km',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXCELENCIA',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.excelencia + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRODUCTIVIDAD',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.productividad + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OPERACION', style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.operacion + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SEGURIDAD VIAL',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.seguridad_vial + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CUIDADO DE UNIDAD',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.cuidado_unidad + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RENDIMIENTO',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.rendimiento + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CALIFICACIÓN',
                        style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text(widget.calificacion,
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              OtherDetailsDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL', style: ThemeStyles.otherDetailsSecondary),
                    SizedBox(height: 5.0),
                    Text('\$ ' + widget.total + '.00',
                        style: ThemeStyles.otherDetailsPrimary),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
