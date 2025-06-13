import 'dart:convert';

import 'package:ebiblioteka_mobile/models/termin.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class TerminProvider extends BaseProvider<Termin> {
  TerminProvider() : super("Termin");

  @override
  Termin fromJson(data) {
    return Termin.fromJson(data);
  }

  Future<void> rezervisiTermin(int terminId, int korisnikId) async {
    String endpoint = "Termin/Rezervisi";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();
    final body = {"terminId": terminId, "korisnikId": korisnikId};

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (!isValidResponse(response)) {
        throw Exception('Greška prilikom rezervacije termina');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<void> otkaziTermin(int terminId) async {
    String endpoint = "Termin/Otkazi?terminId=$terminId";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();

    try {
      final response = await http.put(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw Exception('Greška prilikom otkazivanja termina');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
