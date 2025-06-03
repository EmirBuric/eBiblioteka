import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ebiblioteka_mobile/models/clanarina.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class ClanarinaProvider extends BaseProvider<Clanarina> {
  ClanarinaProvider() : super("Clanarina");

  @override
  Clanarina fromJson(data) {
    return Clanarina.fromJson(data);
  }

  Future<Clanarina?> getClanarinaByKorisnikId(int korisnikId) async {
    String endpoint = "Clanarina/ByKorisnikId?korisnikId=$korisnikId";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Clanarina.fromJson(json);
      } else if (response.statusCode == 204) {
        return null;
      } else {
        throw Exception(
            'Greška prilikom dohvatanja članarine: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
