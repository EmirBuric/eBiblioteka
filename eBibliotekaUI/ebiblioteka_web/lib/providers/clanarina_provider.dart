import 'dart:convert';

import 'package:ebiblioteka_web/models/izvjestaj_clanarina.dart';
import 'package:http/http.dart' as http;
import 'package:ebiblioteka_web/models/clanarina.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

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

      if (response.statusCode == 204) {
        return null;
      }

      if (isValidResponse(response)) {
        final json = jsonDecode(response.body);
        return Clanarina.fromJson(json);
      }

      return null;
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<ClanarinaIzvjestaj> getKnjigaIzvjestaj(int mjesec, int godina) async {
    String endpoint =
        "Clanarina/GetMjesecniIzvjestaj?mjesec=$mjesec&godina=$godina";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final json = jsonDecode(response.body);
        return ClanarinaIzvjestaj.fromJson(json);
      } else {
        throw Exception('Greška prilikom dohvatanja izvještaja');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
