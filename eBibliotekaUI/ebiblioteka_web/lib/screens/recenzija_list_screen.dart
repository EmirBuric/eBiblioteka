import 'package:flutter/material.dart';
import '../models/recenzija.dart';
import '../providers/recenzija_provider.dart';
import '../providers/utils.dart';
import '../layouts/master_screen.dart';

class RecenzijaListScreen extends StatefulWidget {
  const RecenzijaListScreen({super.key});

  @override
  State<RecenzijaListScreen> createState() => _RecenzijaListScreenState();
}

class _RecenzijaListScreenState extends State<RecenzijaListScreen> {
  final RecenzijaProvider _recenzijaProvider = RecenzijaProvider();
  List<Recenzija> recenzije = [];
  bool isLoading = true;
  String search = '';
  String searchParam = 'knjiga'; // default parametar
  final TextEditingController _searchController = TextEditingController();
  RangeValues _rangeValues = const RangeValues(1, 5);

  final List<Map<String, String>> searchOptions = [
    {'value': 'knjiga', 'label': 'Knjiga'},
    {'value': 'ocjena', 'label': 'Ocjena'},
    {'value': 'autor', 'label': 'Ime i prezime korisnika'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Priprema filtera prema odabranom searchParam
    Map<String, dynamic> filter = {};
    if (searchParam == 'knjiga' && search.isNotEmpty) {
      filter['NazivGTE'] = search;
    } else if (searchParam == 'autor' && search.isNotEmpty) {
      filter['ImePrezimeGTE'] = search;
    } else if (searchParam == 'ocjena' && search.isNotEmpty) {
      // Pretpostavljamo da korisnik unosi broj ocjene ili raspon (npr. "3-5")
      if (search.contains('-')) {
        var parts = search.split('-');
        if (parts.length == 2) {
          filter['OcjenaGTE'] = int.tryParse(parts[0].trim());
          filter['OcjenaLTE'] = int.tryParse(parts[1].trim());
        }
      } else {
        filter['OcjenaGTE'] = int.tryParse(search);
        filter['OcjenaLTE'] = int.tryParse(search);
      }
    }

    try {
      var data = await _recenzijaProvider.get(filter: filter);
      setState(() {
        recenzije = data.result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  void _onSearchChanged() {
    setState(() {
      search = _searchController.text;
    });
    _loadData();
  }

  void _onSearchParamChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        searchParam = newValue;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Recenzije',
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7, // 70%
                  child: searchParam == 'ocjena'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RangeSlider(
                              values: _rangeValues,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              labels: RangeLabels(
                                _rangeValues.start.round().toString(),
                                _rangeValues.end.round().toString(),
                              ),
                              onChanged: (values) {
                                setState(() {
                                  _rangeValues = values;
                                  search =
                                      '${_rangeValues.start.round()}-${_rangeValues.end.round()}';
                                });
                                _loadData();
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Ocjena ≥ ${_rangeValues.start.round()}'),
                                Text('Ocjena ≤ ${_rangeValues.end.round()}'),
                              ],
                            ),
                          ],
                        )
                      : TextField(
                          controller: _searchController,
                          onChanged: (_) => _onSearchChanged(),
                          decoration: InputDecoration(
                            hintText: 'Pretraga recenzija po...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3, // 30%
                  child: DropdownButtonFormField<String>(
                    value: searchParam,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.filter_alt,
                          color: Colors.deepPurple),
                    ),
                    items: searchOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        searchParam = newValue!;
                        if (searchParam == 'ocjena') {
                          _rangeValues = const RangeValues(1, 5);
                          search = '1-5';
                          _searchController.clear();
                        } else {
                          search = '';
                          _rangeValues = const RangeValues(1, 5);
                          _searchController.clear();
                        }
                      });
                      _loadData();
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: recenzije.length,
                      itemBuilder: (context, index) {
                        final recenzija = recenzije[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 80,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: recenzija.knjiga?.slika != null &&
                                          recenzija.knjiga!.slika!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: imageFromString(
                                              recenzija.knjiga!.slika!),
                                        )
                                      : const Icon(Icons.menu_book,
                                          size: 48, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recenzija.knjiga?.naziv ?? 'Knjiga',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 101, 85, 143),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Korisnik: ${recenzija.korisnik?.ime ?? ''} ${recenzija.korisnik?.prezime ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                      5,
                                      (i) => Icon(
                                            i < (recenzija.ocjena ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 22,
                                          )),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    recenzija.opis ?? 'Opis recenzije...',
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Datum: ${recenzija.datumRecenzije != null ? formatDateToLocal(recenzija.datumRecenzije!) : '-'}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recenzija.odobrena == null
                                      ? 'Na čekanju'
                                      : (recenzija.odobrena!
                                          ? 'Prihvaćena'
                                          : 'Odbijena'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: recenzija.odobrena == null
                                        ? Colors.grey
                                        : (recenzija.odobrena!
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye,
                                          color: Colors.deepPurple),
                                      tooltip: 'Detalji',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Detalji recenzije'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (recenzija.knjiga?.slika !=
                                                          null &&
                                                      recenzija.knjiga!.slika!
                                                          .isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: SizedBox(
                                                        width: 120,
                                                        height: 160,
                                                        child: imageFromString(
                                                            recenzija.knjiga!
                                                                .slika!),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                      'Knjiga: ${recenzija.knjiga?.naziv ?? ''}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  if (recenzija.knjiga
                                                          ?.godinaIzdanja !=
                                                      null)
                                                    Text(
                                                        'Godina izdanja: ${recenzija.knjiga!.godinaIzdanja}'),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                      'Korisnik: ${recenzija.korisnik?.ime ?? ''} ${recenzija.korisnik?.prezime ?? ''}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  if (recenzija
                                                          .korisnik?.email !=
                                                      null)
                                                    Text(
                                                        'Email: ${recenzija.korisnik!.email}'),
                                                  if (recenzija.korisnik
                                                          ?.korisnickoIme !=
                                                      null)
                                                    Text(
                                                        'Korisničko ime: ${recenzija.korisnik!.korisnickoIme}'),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: List.generate(
                                                        5,
                                                        (i) => Icon(
                                                              i <
                                                                      (recenzija
                                                                              .ocjena ??
                                                                          0)
                                                                  ? Icons.star
                                                                  : Icons
                                                                      .star_border,
                                                              color:
                                                                  Colors.amber,
                                                              size: 22,
                                                            )),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text('Opis recenzije:',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(recenzija.opis ?? ''),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                      'Datum: ${recenzija.datumRecenzije != null ? formatDateToLocal(recenzija.datumRecenzije!) : '-'}'),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                      'Status: ${recenzija.odobrena == null ? 'Na čekanju' : (recenzija.odobrena! ? 'Odobrena' : 'Odbijena')}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Zatvori'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: recenzija.odobrena == null
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      tooltip: 'Prihvati',
                                      onPressed: recenzija.odobrena == null
                                          ? () async {
                                              await _recenzijaProvider.prihvati(
                                                  recenzija.recenzijaId!);
                                              _loadData();
                                            }
                                          : null,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: recenzija.odobrena == null
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      tooltip: 'Odbij',
                                      onPressed: recenzija.odobrena == null
                                          ? () async {
                                              await _recenzijaProvider.odbij(
                                                  recenzija.recenzijaId!);
                                              _loadData();
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
