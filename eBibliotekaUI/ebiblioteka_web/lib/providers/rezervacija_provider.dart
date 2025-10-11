import 'package:ebiblioteka_web/models/rezervacija.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }

  Future<void> potvrdiRezervaciju(int rezervacijaId, bool potvrda) async {
    String endpoint =
        "Rezervacija/PortvrdiRezervaciju?id=$rezervacijaId&potvrda=$potvrda";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.put(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw Exception('Greška prilikom potvrđivanja rezervacije');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
