import 'package:ebiblioteka_mobile/models/zanr.dart';
import 'package:ebiblioteka_mobile/providers/base_provider.dart';

class ZanrProvider extends BaseProvider<Zanr> {
  ZanrProvider() : super("Zanr");

  @override
  Zanr fromJson(data) {
    return Zanr.fromJson(data);
  }
}
