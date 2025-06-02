import 'package:ebiblioteka_mobile/models/citaonica.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class CitaonicaProvider extends BaseProvider<Citaonica> {
  CitaonicaProvider() : super("Citaonica");

  @override
  Citaonica fromJson(data) {
    return Citaonica.fromJson(data);
  }
}
