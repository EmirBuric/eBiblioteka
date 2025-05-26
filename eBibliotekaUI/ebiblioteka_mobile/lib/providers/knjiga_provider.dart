import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }
}
