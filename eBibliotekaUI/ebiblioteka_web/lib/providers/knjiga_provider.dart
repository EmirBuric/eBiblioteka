import 'package:ebiblioteka_web/models/knjiga.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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

      if (isValidResponse(response)) {
        return;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> setPreporucenaKnjiga(List<int> ids) async {
    String endpoint = "Knjiga/Preporuka";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();
    var jsonRequest = jsonEncode(ids);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (!isValidResponse(response)) {
      throw Exception('Greška prilikom slanja preporučenih knjiga');
    }
  }
}
