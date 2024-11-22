import 'package:intl/intl.dart';

convertir_hora(String datetime) {
  var date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(datetime, true);
  var local = date.toLocal().toString();
  print(local);
  return local;
}
