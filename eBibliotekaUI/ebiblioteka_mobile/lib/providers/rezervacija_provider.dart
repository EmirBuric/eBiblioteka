import 'package:ebiblioteka_mobile/models/rezervacija.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }
}
