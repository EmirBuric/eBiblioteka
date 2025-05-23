import 'dart:convert';

import 'package:ebiblioteka_admin/models/knjiga.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }

  Future<void> setKnjigaDana(int id) async {
    String endpoint = "Knjiga/KnjigaDana/$id";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
            'Greška prilikom slanja knjige dana: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<void> setPreporucenaKnjiga(List<int> ids) async {
    String endpoint = "Knjiga/Preporuka";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();
    var jsonRequest = jsonEncode(ids);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (response.statusCode != 200) {
      new Exception(
          'Greška prilikom slanja preporučenih knjiga: ${response.statusCode}');
    }
  }
}
