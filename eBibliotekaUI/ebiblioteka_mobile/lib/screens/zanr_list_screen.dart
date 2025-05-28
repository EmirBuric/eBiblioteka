import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/list_screen.dart';
import 'package:ebiblioteka_mobile/models/zanr.dart';
import 'package:ebiblioteka_mobile/providers/zanr_provider.dart';

class ZanrListScreen extends StatelessWidget {
  final ZanrProvider _zanrProvider = ZanrProvider();

  ZanrListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListScreen<Zanr>(
      title: 'Žanrovi',
      fetchData: (params) => _zanrProvider.get(filter: params),
      onSearch: (value) {},
      addSearchParams: (String searchQuery) => {
        'NazivGTE': searchQuery,
      },
      selectedIndex: 0,
      itemBuilder: (zanr) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          title: Text(
            zanr.naziv ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ),
    );
  }
}
