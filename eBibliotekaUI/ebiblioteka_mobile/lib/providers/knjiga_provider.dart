import 'dart:convert';

import 'package:ebiblioteka_mobile/models/dostupnost_knjige.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }

  Future<DostupnostKnjige> getDostupnostZaPeriod(
      int knjigaId, DateTime datumOd, DateTime datumDo) async {
    String endpoint =
        "Knjiga/Kalendar/$knjigaId?datumOd=${datumOd.toIso8601String()}&datumDo=${datumDo.toIso8601String()}";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');
    //print(uri);

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final json = jsonDecode(response.body);
        return DostupnostKnjige.fromJson(json);
      }

      throw Exception('Greška prilikom dohvatanja dostupnosti knjige');
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
