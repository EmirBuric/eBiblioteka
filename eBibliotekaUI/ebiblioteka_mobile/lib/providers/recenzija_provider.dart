import 'package:ebiblioteka_mobile/models/recenzija.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class RecenzijaProvider extends BaseProvider<Recenzija> {
  RecenzijaProvider() : super("Recenzija");

  @override
  Recenzija fromJson(data) {
    return Recenzija.fromJson(data);
  }
}
