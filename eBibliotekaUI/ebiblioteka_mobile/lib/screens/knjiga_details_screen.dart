import 'package:ebiblioteka_mobile/models/autor.dart';
import 'package:ebiblioteka_mobile/providers/autor_provider.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_autor_provider.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/zanr_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';

class KnjigaDetailsScreen extends StatefulWidget {
  final Knjiga knjiga;

  const KnjigaDetailsScreen({
    super.key,
    required this.knjiga,
  });

  @override
  State<KnjigaDetailsScreen> createState() => _KnjigaDetailsScreenState();
}

class _KnjigaDetailsScreenState extends State<KnjigaDetailsScreen> {
  final AutorProvider _autorProvider = AutorProvider();
  final KnjigaAutorProvider _knjigaAutorProvider = KnjigaAutorProvider();
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ZanrProvider _zanrProvider = ZanrProvider();

  List<Autor> autori = [];
  Map<int, List<String>> knjigeAutori = {};
  List<Knjiga> knjige = [];
  bool isLoading = true;
  String? zanrNaziv;
  String? zanrNazivLower;
  int currentPage = 1;
  int pageSize = 3;

  // Add this to your existing state variables
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      if (widget.knjiga.zanrId != null) {
        final zanr = await _zanrProvider.getById(widget.knjiga.zanrId!);
        zanrNaziv = zanr.naziv;
      }
      zanrNazivLower = zanrNaziv?.toLowerCase();

      final knjigaAutorFilter = {
        'KnjigaId': widget.knjiga.knjigaId,
      };

      final knjigaAutorData =
          await _knjigaAutorProvider.get(filter: knjigaAutorFilter);

      final autorIds = knjigaAutorData.result
          .map((ka) => ka.autorId)
          .where((id) => id != null)
          .toList();
      print('AutorIds: $autorIds');

      if (autorIds.isNotEmpty) {
        final autoriData = await _autorProvider.get();
        setState(() {
          autori = List<Autor>.from(
              autoriData.result.where((a) => autorIds.contains(a.autorId)));
        });
      }
      Map<String, dynamic> filter = {
        'Page': currentPage,
        'PageSize': pageSize,
        'ZanrId': widget.knjiga.zanrId,
      };
      var data = await _knjigaProvider.get(filter: filter);

      setState(() {
        knjige = data.result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Greška"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Knjiga'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book image and basic info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book image
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.knjiga.slika != null
                                ? imageFromString(widget.knjiga.slika!)
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book, size: 50),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Book details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.knjiga.naziv ?? '',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  autori.isNotEmpty
                                      ? autori
                                          .map((a) => '${a.ime} ${a.prezime}')
                                          .join(', ')
                                      : 'Nepoznat autor',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (zanrNaziv != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Žanr: ${zanrNaziv}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Colors.white, // Add this line
                                    minimumSize:
                                        const Size(double.infinity, 45),
                                  ),
                                  child: const Text(
                                    'Rezerviši',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opis knjige',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.knjiga.kratkiOpis ?? 'Nema opisa.',
                                maxLines: _isDescriptionExpanded ? null : 3,
                                overflow: _isDescriptionExpanded
                                    ? null
                                    : TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if ((widget.knjiga.kratkiOpis ?? '').length >
                                  100) ...[
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _isDescriptionExpanded
                                            ? 'Prikaži manje'
                                            : 'Pročitaj još',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        _isDescriptionExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Theme.of(context).primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Categories section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iz žanra ${zanrNazivLower ?? ""}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: knjige.length,
                            itemBuilder: (context, index) {
                              final knjiga = knjige[index];
                              if (knjiga.knjigaId == widget.knjiga.knjigaId) {
                                return const SizedBox.shrink();
                              }
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            KnjigaDetailsScreen(
                                          knjiga: knjiga,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Book image
                                        Container(
                                          width: 60,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: knjiga.slika != null
                                              ? imageFromString(knjiga.slika!)
                                              : Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.book),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Book info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                knjiga.naziv ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Godina izdanja: ${knjiga.godinaIzdanja ?? 'Nepoznato'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
