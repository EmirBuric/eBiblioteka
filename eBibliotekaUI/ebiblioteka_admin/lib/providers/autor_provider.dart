import 'package:ebiblioteka_admin/models/autor.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

class AutorProvider extends BaseProvider<Autor> {
  AutorProvider() : super("Autor");

  @override
  Autor fromJson(data) {
    return Autor.fromJson(data);
  }
}
