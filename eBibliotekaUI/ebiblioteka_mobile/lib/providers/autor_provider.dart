import 'package:ebiblioteka_mobile/models/autor.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class AutorProvider extends BaseProvider<Autor> {
  AutorProvider() : super("Autor");

  @override
  Autor fromJson(data) {
    return Autor.fromJson(data);
  }
}
