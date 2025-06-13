import 'package:ebiblioteka_admin/models/recenzija.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RecenzijaProvider extends BaseProvider<Recenzija> {
  RecenzijaProvider() : super("Recenzija");

  @override
  Recenzija fromJson(data) {
    return Recenzija.fromJson(data);
  }

  Future<void> prihvati(int recenzijaId) async {
    String endpoint = "Recenzija/Prihvati/$recenzijaId";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw Exception('Greška prilikom prihvatanja recenzije');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<void> odbij(int recenzijaId) async {
    String endpoint = "Recenzija/Odbij/$recenzijaId";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw Exception('Greška prilikom odbijanja recenzije');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
