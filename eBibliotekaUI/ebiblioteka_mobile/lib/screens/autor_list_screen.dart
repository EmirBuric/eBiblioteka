import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/list_screen.dart';
import 'package:ebiblioteka_mobile/models/autor.dart';
import 'package:ebiblioteka_mobile/providers/autor_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:ebiblioteka_mobile/screens/autor_details_screen.dart';

class AutorListScreen extends StatelessWidget {
  final AutorProvider _autorProvider = AutorProvider();

  AutorListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListScreen<Autor>(
      title: 'Autori',
      fetchData: (params) => _autorProvider.get(filter: params),
      onSearch: (value) {},
      addSearchParams: (String searchQuery) => {
        'ImeGTE': searchQuery,
      },
      selectedIndex: 0,
      itemBuilder: (autor) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: autor.slika != null
                ? imageFromString(autor.slika!)
                : const Icon(Icons.person),
          ),
          title: Text("${autor.ime} ${autor.prezime}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datum rođenja: ${formatDateToLocal(autor.datumRodjenja!)}'),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          isThreeLine: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AutorDetailsScreen(
                  autor: autor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
