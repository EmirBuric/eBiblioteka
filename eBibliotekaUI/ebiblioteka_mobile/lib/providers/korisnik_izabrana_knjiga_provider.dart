import 'dart:convert';

import 'package:ebiblioteka_mobile/models/korisnik_izabrana_knjiga.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KorisnikIzabranaKnjigaProvider
    extends BaseProvider<KorisnikIzabranaKnjiga> {
  KorisnikIzabranaKnjigaProvider() : super("KorisnikIzabranaKnjiga");

  @override
  KorisnikIzabranaKnjiga fromJson(data) {
    return KorisnikIzabranaKnjiga.fromJson(data);
  }

  Future<void> updateIsCheckedList(List<int> ids) async {
    String endpoint = "KorisnikIzabranaKnjiga/UpdateIsCheckedList";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();
    var jsonRequest = jsonEncode(ids);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (response.statusCode != 200) {
      new Exception(
          'Greška prilikom slanja izabranih knjiga: ${response.statusCode}');
    }
  }

  Future<void> updateIsChecked(int id) async {
    String endpoint = "KorisnikIzabranaKnjiga/UpdateIsChecked/$id";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.put(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
            'Greška prilikom slanja izabrane knjige: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
