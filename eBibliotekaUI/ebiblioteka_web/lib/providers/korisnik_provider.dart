import 'package:ebiblioteka_web/models/korisnik.dart';
import 'package:ebiblioteka_web/providers/auth_provider.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';
import 'package:http/http.dart' as http;

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

      if (isValidResponse(response)) {
        AuthProvider.uloga = response.body;
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

      if (isValidResponse(response)) {
        AuthProvider.trenutniKorisnikId = int.parse(response.body);
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  static bool isAdmin() {
    return AuthProvider.uloga?.trim() == "Admin";
  }
}
