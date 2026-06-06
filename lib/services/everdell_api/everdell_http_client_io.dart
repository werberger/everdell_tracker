import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';

http.Client createEverdellHttpClient() {
  final ioClient = HttpClient();
  return IOClient(ioClient);
}
