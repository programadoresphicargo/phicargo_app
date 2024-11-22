import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  late WebSocketChannel _channel;

  WebSocketService(this.url);

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    print("Conectado a $url");
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
    print("Mensaje enviado: $message");
  }

  Stream<dynamic> get messages => _channel.stream;

  void close() {
    _channel.sink.close();
    print("Conexión cerrada");
  }
}
