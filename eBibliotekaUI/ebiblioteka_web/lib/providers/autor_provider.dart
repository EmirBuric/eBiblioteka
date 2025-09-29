import 'package:ebiblioteka_web/models/autor.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

class AutorProvider extends BaseProvider<Autor> {
  AutorProvider() : super("Autor");

  @override
  Autor fromJson(data) {
    return Autor.fromJson(data);
  }
}
