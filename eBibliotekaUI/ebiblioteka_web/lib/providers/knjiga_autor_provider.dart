import 'package:ebiblioteka_web/models/knjiga_autor.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

class KnjigaAutorProvider extends BaseProvider<KnjigaAutor> {
  KnjigaAutorProvider() : super("KnjigaAutor");

  @override
  KnjigaAutor fromJson(data) {
    return KnjigaAutor.fromJson(data);
  }
}
