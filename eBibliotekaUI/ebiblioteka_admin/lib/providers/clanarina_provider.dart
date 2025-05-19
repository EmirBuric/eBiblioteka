import 'package:ebiblioteka_admin/models/clanarina.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

class ClanarinaProvider extends BaseProvider<Clanarina> {
  ClanarinaProvider() : super("Clanarina");

  @override
  Clanarina fromJson(data) {
    return Clanarina.fromJson(data);
  }
}
