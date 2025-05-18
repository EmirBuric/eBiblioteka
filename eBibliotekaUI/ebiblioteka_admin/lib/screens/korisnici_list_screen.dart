import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../models/korisnik.dart';
import '../providers/korisnik_provider.dart';
import '../providers/uloga_provider.dart';
import '../providers/auth_provider.dart';

class KorisniciListScreen extends StatefulWidget {
  const KorisniciListScreen({super.key});

  @override
  State<KorisniciListScreen> createState() => _KorisniciListScreenState();
}

class _KorisniciListScreenState extends State<KorisniciListScreen> {
  final KorisnikProvider _korisnikProvider = KorisnikProvider();
  final UlogaProvider _ulogaProvider = UlogaProvider();

  List<Korisnik> korisnici = [];
  List<Korisnik> filteredKorisnici = [];
  Map<int, String> ulogeMap = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Paginacija
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterKorisnike);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUloge() async {
    try {
      var data = await _ulogaProvider.get();
      setState(() {
        for (var uloga in data.result) {
          ulogeMap[uloga.ulogaId!] = uloga.naziv!;
        }
      });
    } catch (e) {
      print('Error loading uloge: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      var data = await _korisnikProvider.get(filter: {
        'Page': currentPage,
        'PageSize': pageSize,
      });

      setState(() {
        korisnici = data.result;
        filteredKorisnici = data.result;
        totalItems = data.count;
        totalPages = (totalItems / pageSize).ceil();
        isLoading = false;
      });
    } catch (e) {
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

  Future<void> _initializeData() async {
    await _loadUloge(); // Prvo učitaj uloge
    await _loadData(); // Zatim učitaj korisnike
  }

  void _filterKorisnike() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _loadData(); // Resetiraj na prvu stranicu i učitaj ponovo
    } else {
      setState(() {
        filteredKorisnici = korisnici.where((korisnik) {
          final fullName = '${korisnik.ime} ${korisnik.prezime}'.toLowerCase();
          final email = korisnik.email?.toLowerCase() ?? '';
          final username = korisnik.korisnickoIme?.toLowerCase() ?? '';
          return fullName.contains(query) ||
              email.contains(query) ||
              username.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _deleteKorisnik(int id) async {
    try {
      await _korisnikProvider.Delete(id);
      setState(() {
        korisnici.removeWhere((korisnik) => korisnik.korisnikId == id);
        filteredKorisnici.removeWhere((korisnik) => korisnik.korisnikId == id);
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Korisnici",
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Korisnici',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 101, 85, 143),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Pretraži korisnike...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            filteredKorisnici.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.person_off,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Nema pronađenih korisnika',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              cardColor: Colors.white,
                                              dividerColor:
                                                  const Color.fromARGB(
                                                          255, 101, 85, 143)
                                                      .withOpacity(0.1),
                                            ),
                                            child: SizedBox(
                                              width: 1152,
                                              child: DataTable(
                                                columnSpacing: 40,
                                                horizontalMargin: 20,
                                                headingRowColor:
                                                    MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                          255, 101, 85, 143)
                                                      .withOpacity(0.1),
                                                ),
                                                columns: const [
                                                  DataColumn(
                                                    label: Text(
                                                      'Ime',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Prezime',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Email',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Korisničko ime',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Telefon',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Uloge',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Akcije',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                                rows: filteredKorisnici
                                                    .map((korisnik) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(Text(
                                                          korisnik.ime ?? '')),
                                                      DataCell(Text(
                                                          korisnik.prezime ??
                                                              '')),
                                                      DataCell(Text(
                                                          korisnik.email ??
                                                              '')),
                                                      DataCell(Text(korisnik
                                                              .korisnickoIme ??
                                                          '')),
                                                      DataCell(Text(
                                                          korisnik.telefon ??
                                                              '')),
                                                      DataCell(
                                                        Wrap(
                                                          spacing: 4,
                                                          children: (korisnik
                                                                      .korisnikUlogas ??
                                                                  [])
                                                              .map((uloga) {
                                                            return Chip(
                                                              label: Text(
                                                                ulogeMap[uloga
                                                                        .ulogaId] ??
                                                                    "Nepoznata uloga",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      101,
                                                                      85,
                                                                      143),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.edit),
                                                              color:
                                                                  Colors.blue,
                                                              onPressed: korisnik
                                                                          .korisnikId ==
                                                                      AuthProvider
                                                                          .trenutniKorisnikId
                                                                  ? null
                                                                  : () {
                                                                      // TODO: Implement edit
                                                                    },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.delete),
                                                              color: Colors.red,
                                                              onPressed: korisnik
                                                                          .korisnikId ==
                                                                      AuthProvider
                                                                          .trenutniKorisnikId
                                                                  ? null
                                                                  : () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                AlertDialog(
                                                                          title:
                                                                              const Text('Potvrda brisanja'),
                                                                          content:
                                                                              Text('Da li ste sigurni da želite obrisati korisnika ${korisnik.ime} ${korisnik.prezime}?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: const Text('Odustani'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                _deleteKorisnik(korisnik.korisnikId!);
                                                                              },
                                                                              child: const Text(
                                                                                'Obriši',
                                                                                style: TextStyle(color: Colors.red),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon:
                                                const Icon(Icons.chevron_left),
                                            onPressed: currentPage > 1
                                                ? () {
                                                    setState(() {
                                                      currentPage--;
                                                      _loadData();
                                                    });
                                                  }
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Stranica $currentPage od $totalPages',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.chevron_right),
                                            onPressed: currentPage < totalPages
                                                ? () {
                                                    setState(() {
                                                      currentPage++;
                                                      _loadData();
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
