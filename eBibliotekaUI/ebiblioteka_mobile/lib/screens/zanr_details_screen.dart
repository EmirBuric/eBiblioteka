import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/details_screen.dart';
import 'package:ebiblioteka_mobile/models/zanr.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';

class ZanrDetailsScreen extends StatelessWidget {
  final Zanr zanr;
  final KnjigaProvider _knjigaProvider = KnjigaProvider();

  ZanrDetailsScreen({
    Key? key,
    required this.zanr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailsScreen<Zanr>(
      item: zanr,
      title: zanr.naziv ?? 'Žanr',
      detailsBuilder: (zanr) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    zanr.naziv ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Knjige iz ovog žanra',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      fetch: (params) => _knjigaProvider.get(filter: params),
      addSearchParams: (String searchQuery) => {
        'NazivGTE': searchQuery,
      },
      filterField: 'ZanrId',
      filterId: zanr.zanrId!,
    );
  }
}
