import 'package:ebiblioteka_web/models/knjiga.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }
}
