import 'dart:convert';

import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ebiblioteka_mobile/models/korisnik.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnik");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  Future<void> getTrenutniKorisnikUloga() async {
    String endpoint = "Korisnik/Uloga";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        AuthProvider.uloga = response.body;
      } else {
        throw Exception(
            'Greška prilikom dohvatanja uloge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<void> getTrenutniKorisnikId() async {
    String endpoint = "Korisnik/TrenutniId";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        AuthProvider.trenutniKorisnikId = int.parse(response.body);
      } else {
        throw Exception(
            'Greška prilikom dohvatanja ID-a korisnika: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<List<Knjiga>> getPreporuke() async {
    var url =
        "${BaseProvider.baseUrl}Korisnik/PreporuceneKnjige/${AuthProvider.trenutniKorisnikId}";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var obj = jsonDecode(response.body);

      if (obj is List) {
        List<Knjiga> lista = obj.map((item) => Knjiga.fromJson(item)).toList();
        return lista;
      } else {
        throw new Exception(
            'Greška prilikom dohvatanja preporučenih knjiga: ${response.statusCode}');
      }
    }
    throw new Exception('Greška prilikom komunikacije sa serverom');
  }
}
