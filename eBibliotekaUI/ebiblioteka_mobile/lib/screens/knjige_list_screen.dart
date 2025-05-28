import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/list_screen.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';

class KnjigeListScreen extends StatelessWidget {
  final KnjigaProvider _knjigaProvider = KnjigaProvider();

  KnjigeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListScreen<Knjiga>(
      title: 'Knjige',
      fetchData: (params) => _knjigaProvider.get(filter: params),
      onSearch: (value) {},
      addSearchParams: (String searchQuery) => {
        'NazivGTE': searchQuery,
      },
      selectedIndex: 0,
      itemBuilder: (knjiga) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: knjiga.slika != null
                ? imageFromString(knjiga.slika!)
                : const Icon(Icons.book),
          ),
          title: Text(knjiga.naziv ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Godina: ${knjiga.godinaIzdanja}'),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
