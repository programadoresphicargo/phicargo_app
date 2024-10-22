class Departamento {
  late String id_departamento;
  late String nombre_departamento;
  late String alias;
  late String icono;

  Departamento(
      {required this.id_departamento,
      required this.nombre_departamento,
      required this.icono,
      required this.alias});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id_departamento: json['ID_DEPARTAMENTO'] as String,
      alias: json['ALIAS'] as String,
      nombre_departamento: json['NOMBRE_DEP'] as String,
      icono: json['ICONO'] as String,
    );
  }
}
