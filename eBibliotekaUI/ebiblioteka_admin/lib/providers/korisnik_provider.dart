import 'dart:convert';
import 'package:ebiblioteka_admin/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ebiblioteka_admin/models/korisnik.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

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

  static bool isAdmin() {
    return AuthProvider.uloga?.trim() == "Admin";
  }
}
