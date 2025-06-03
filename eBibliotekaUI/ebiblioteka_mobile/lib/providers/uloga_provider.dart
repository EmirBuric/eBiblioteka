import 'package:ebiblioteka_mobile/models/uloga.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class UlogaProvider extends BaseProvider<Uloga> {
  UlogaProvider() : super("Uloga");

  @override
  Uloga fromJson(data) {
    return Uloga.fromJson(data);
  }
}
