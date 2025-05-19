import 'package:ebiblioteka_admin/models/tip_clanarine.dart';
import 'package:ebiblioteka_admin/providers/base_provider.dart';

class TipClanarineProvider extends BaseProvider<TipClanarine> {
  TipClanarineProvider() : super("TipClanarine");

  @override
  TipClanarine fromJson(data) {
    return TipClanarine.fromJson(data);
  }
}
