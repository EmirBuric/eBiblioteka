import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/details_screen.dart';
import 'package:ebiblioteka_mobile/models/autor.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';

class AutorDetailsScreen extends StatefulWidget {
  final Autor autor;

  const AutorDetailsScreen({
    Key? key,
    required this.autor,
  }) : super(key: key);

  @override
  State<AutorDetailsScreen> createState() => _AutorDetailsScreenState();
}

class _AutorDetailsScreenState extends State<AutorDetailsScreen> {
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  bool _isBiographyExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DetailsScreen<Autor>(
      item: widget.autor,
      title: '${widget.autor.ime} ${widget.autor.prezime}',
      detailsBuilder: (autor) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (autor.slika != null) ...[
              Center(
                child: ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: imageFromString(autor.slika!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '${autor.ime} ${autor.prezime}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (autor.datumRodjenja != null) ...[
              Text(
                'Datum rođenja: ${formatDateToLocal(autor.datumRodjenja!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (autor.biografija != null && autor.biografija!.isNotEmpty) ...[
              Text(
                'Biografija',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    autor.biografija!,
                    maxLines: _isBiographyExpanded ? null : 3,
                    overflow:
                        _isBiographyExpanded ? null : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  if (autor.biografija!.length > 150)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isBiographyExpanded = !_isBiographyExpanded;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _isBiographyExpanded
                                ? 'Prikaži manje'
                                : 'Pročitaj više',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _isBiographyExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Knjige autora',
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
      filterField: 'AutorId',
      filterId: widget.autor.autorId!,
    );
  }
}
