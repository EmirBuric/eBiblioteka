import 'package:ebiblioteka_admin/models/knjiga.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }
}
