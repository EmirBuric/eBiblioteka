import 'package:ebiblioteka_mobile/models/korisnik_izabrana_knjiga.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class KorisnikIzabranaKnjigaProvider
    extends BaseProvider<KorisnikIzabranaKnjiga> {
  KorisnikIzabranaKnjigaProvider() : super("KorisnikIzabranaKnjiga");

  @override
  KorisnikIzabranaKnjiga fromJson(data) {
    return KorisnikIzabranaKnjiga.fromJson(data);
  }
}
