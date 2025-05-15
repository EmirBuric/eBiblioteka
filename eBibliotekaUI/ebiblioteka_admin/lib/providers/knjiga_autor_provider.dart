import 'package:ebiblioteka_admin/models/knjiga_autor.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

class KnjigaAutorProvider extends BaseProvider<KnjigaAutor> {
  KnjigaAutorProvider() : super("KnjigaAutor");

  @override
  KnjigaAutor fromJson(data) {
    return KnjigaAutor.fromJson(data);
  }
}
