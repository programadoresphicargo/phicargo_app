String printTime(String fecha) {
  DateTime startDate = DateTime.parse(fecha);
  DateTime now = DateTime.now();
  Duration difference = now.difference(startDate);

  if (difference.inDays > 365) {
    int years = difference.inDays ~/ 365;
    return 'hace ${years == 1 ? '1 año' : '$years años'}';
  } else if (difference.inDays >= 30) {
    int months = difference.inDays ~/ 30;
    return 'hace ${months == 1 ? '1 mes' : '$months meses'}';
  } else if (difference.inDays >= 1) {
    return 'hace ${difference.inDays == 1 ? '1 día' : '${difference.inDays} días'}';
  } else if (difference.inHours >= 1) {
    return 'hace ${difference.inHours == 1 ? '1 hora' : '${difference.inHours} horas'}';
  } else if (difference.inMinutes >= 1) {
    return 'hace ${difference.inMinutes == 1 ? '1 minuto' : '${difference.inMinutes} minutos'}';
  } else if (difference.inSeconds >= 1) {
    return 'hace ${difference.inSeconds == 1 ? '1 segundo' : '${difference.inSeconds} segundos'}';
  } else {
    return 'justo ahora';
  }
}
