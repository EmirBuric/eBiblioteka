import 'dart:async';

import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/autor.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/models/zanr.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_autor_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_izabrana_knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_provider.dart';
import 'package:ebiblioteka_mobile/screens/autor_details_screen.dart';
import 'package:ebiblioteka_mobile/screens/autor_list_screen.dart';
import 'package:ebiblioteka_mobile/screens/knjiga_details_screen.dart';
import 'package:ebiblioteka_mobile/screens/knjige_list_screen.dart';
import 'package:ebiblioteka_mobile/screens/rezervacija_list_screen.dart';
import 'package:ebiblioteka_mobile/screens/zanr_details_screen.dart';
import 'package:ebiblioteka_mobile/screens/zanr_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/zanr_provider.dart';
import 'package:ebiblioteka_mobile/providers/autor_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'historija_rezervacija_screen.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({Key? key}) : super(key: key);

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ZanrProvider _zanrProvider = ZanrProvider();
  final AutorProvider _autorProvider = AutorProvider();
  final KnjigaAutorProvider _knjigaAutorProvider = KnjigaAutorProvider();
  final KorisnikIzabranaKnjigaProvider _korisnikIzabranaKnjigaProvider =
      KorisnikIzabranaKnjigaProvider();
  final KorisnikProvider _korisnikProvider = KorisnikProvider();
  List<Knjiga> knjige = [];
  List<Knjiga> knjigaDana = [];
  List<Knjiga> preporuceneKnjige = [];
  List<Knjiga> zaVasKnjige = [];
  List<Autor> autori = [];
  Map<int, String> zanrNames = {};
  Map<int, List<String>> knjigeAutori = {};
  bool isLoading = true;
  int brojRezervacija = 0;
  bool isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<Knjiga> searchResults = [];
  bool isSearching = false;

  int currentPage = 1;
  int pageSize = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getBrojRezervacija();
    _loadZaVasPreporuke();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> filter = {
        'Page': currentPage,
        'PageSize': pageSize,
      };
      Map<String, dynamic> knjigaDanafilter = {
        'KnjigaDana': true,
      };
      Map<String, dynamic> preporuceneKnjigeFilter = {
        'Preporuceno': true,
        'Page': 1,
        'PageSize': 3,
      };
      Map<String, dynamic> filterZanr = {
        'Page': 1,
        'PageSize': 8,
      };

      var data = await _knjigaProvider.get(filter: filter);
      var knjigaDanaData = await _knjigaProvider.get(filter: knjigaDanafilter);
      var preporuceneKnjigeData =
          await _knjigaProvider.get(filter: preporuceneKnjigeFilter);

      var zanroviData = await _zanrProvider.get(filter: filterZanr);
      var autoriData = await _autorProvider.get();
      var knjigeAutoriData = await _knjigaAutorProvider.get();

      var zanroviMap = {
        for (var zanr in zanroviData.result)
          zanr.zanrId ?? 0: zanr.naziv ?? "Nepoznat žanr"
      };

      var autoriMap = {
        for (var autor in autoriData.result)
          autor.autorId ?? 0: "${autor.ime} ${autor.prezime}"
      };

      var knjigeAutoriMap = <int, List<String>>{};
      for (var knjigaAutor in knjigeAutoriData.result) {
        var knjigaId = knjigaAutor.knjigaId;
        var autorId = knjigaAutor.autorId;
        if (knjigaId != null && autorId != null) {
          knjigeAutoriMap.putIfAbsent(knjigaId, () => []);
          var autorIme = autoriMap[autorId] ?? "Nepoznat autor";
          knjigeAutoriMap[knjigaId]!.add(autorIme);
        }
      }

      setState(() {
        knjige = data.result;
        zanrNames = zanroviMap;
        knjigeAutori = knjigeAutoriMap;
        isLoading = false;
        autori = autoriData.result;
        knjigaDana = knjigaDanaData.result;
        preporuceneKnjige = preporuceneKnjigeData.result;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

  Future<void> _getBrojRezervacija() async {
    if (AuthProvider.trenutniKorisnikId == null) return;

    try {
      var data = await _korisnikIzabranaKnjigaProvider.get(filter: {
        'KorisnikId': AuthProvider.trenutniKorisnikId.toString(),
        'IsChecked': 'true'
      });

      setState(() {
        brojRezervacija = data.count;
      });
    } catch (e) {
      print('Greška pri učitavanju broja rezervacija: $e');
    }
  }

  Future<void> _loadZaVasPreporuke() async {
    if (AuthProvider.trenutniKorisnikId == null) return;

    try {
      final preporuke = await _korisnikProvider.getPreporuke();

      setState(() {
        zaVasKnjige = preporuke;
      });
    } catch (e) {
      print('Greška pri učitavanju personaliziranih preporuka: $e');
    }
  }

  Future<void> _searchKnjige(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      var filter = {'NazivGTE': query};
      var result = await _knjigaProvider.get(filter: filter);

      setState(() {
        searchResults = result.result;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      print('Greška pri pretraživanju knjiga: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: isSearchVisible
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Pretražite knjige...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _searchKnjige(value);
                  },
                )
              : const Text('eBiblioteka'),
          actions: [
            IconButton(
              icon: Icon(isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;
                  if (!isSearchVisible) {
                    _searchController.clear();
                    searchResults = [];
                  }
                });
              },
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Moje rezervacije',
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                          builder: (context) => const RezervacijaListScreen()),
                    )
                        .then((_) {
                      _getBrojRezervacija();
                    });
                  },
                ),
                if (brojRezervacija > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        brojRezervacija.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'theme') {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                } else if (value == 'historija') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HistorijaRezervacijaScreen(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                return [
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          themeProvider.isDarkMode
                              ? 'Svijetli način'
                              : 'Tamni način',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'historija',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 12),
                        Text('Historija rezervacija'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSearchVisible && searchResults.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Rezultati pretrage',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final knjiga = searchResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: knjiga.slika != null
                                          ? imageFromString(knjiga.slika!)
                                          : const Icon(Icons.book),
                                    ),
                                    title: Text(knjiga.naziv ?? 'Naziv knjige'),
                                    subtitle: Text(
                                      knjigeAutori[knjiga.knjigaId]
                                              ?.join(", ") ??
                                          "Nepoznat autor",
                                    ),
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
                                  ),
                                );
                              },
                            ),
                            const Divider(thickness: 1),
                          ],
                        ),
                      if (isSearching)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (!isSearchVisible ||
                          searchResults.isEmpty && !isSearching)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Knjiga dana',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (knjigaDana.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => KnjigaDetailsScreen(
                                        knjiga: knjigaDana[0],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: knjigaDana[0].slika != null
                                              ? imageFromString(
                                                  knjigaDana[0].slika!)
                                              : const Icon(Icons.book,
                                                  size: 40),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                knjigaDana[0].naziv ??
                                                    'Naziv knjige',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(knjigeAutori[knjigaDana[0]
                                                          .knjigaId]
                                                      ?.join(", ") ??
                                                  "Nepoznat autor"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Trenutno nema knjige dana',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            const Text(
                              'Naša preporuka',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (preporuceneKnjige.isNotEmpty)
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: preporuceneKnjige.length,
                                  itemBuilder: (context, index) {
                                    final knjiga = preporuceneKnjige[index];
                                    return GestureDetector(
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
                                      child: Container(
                                        width: 150,
                                        margin:
                                            const EdgeInsets.only(right: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
                                              ),
                                              child: knjiga.slika != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: imageFromString(
                                                          knjiga.slika!),
                                                    )
                                                  : Center(
                                                      child: Icon(Icons.book,
                                                          size: 40,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color),
                                                    ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              knjiga.naziv ?? 'Naziv knjige',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              knjigeAutori[knjiga.knjigaId]
                                                      ?.join(", ") ??
                                                  "Nepoznat autor",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Trenutno nema preporučenih knjiga',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => ZanrListScreen()),
                                );
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Žanrovi',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: zanrNames.isNotEmpty
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: zanrNames.length,
                                      itemBuilder: (context, index) {
                                        final zanrId = index + 1;
                                        final zanr = Zanr(
                                          zanrId: zanrId,
                                          naziv: zanrNames[zanrId],
                                        );
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ZanrDetailsScreen(
                                                  zanr: zanr,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 70,
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.grey[800]
                                                        : Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.category,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: Text(
                                                    zanrNames[zanrId] ??
                                                        'Nepoznat Žanr',
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        'Trenutno nema dostupnih žanrova',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AutorListScreen()),
                                );
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Autori',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: autori.isNotEmpty
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: autori.length,
                                      itemBuilder: (context, index) {
                                        final autor = autori[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AutorDetailsScreen(
                                                  autor: autor,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: autor.slika != null
                                                      ? ClipOval(
                                                          child:
                                                              imageFromString(
                                                                  autor.slika!),
                                                        )
                                                      : const Icon(
                                                          Icons.person),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                    '${autor.ime} ${autor.prezime}'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        'Trenutno nema dostupnih autora',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => KnjigeListScreen()),
                                );
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Knjige',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            knjige.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: knjige.length,
                                    itemBuilder: (context, index) {
                                      final knjiga = knjige[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: knjiga.slika != null
                                                      ? imageFromString(
                                                          knjiga.slika!)
                                                      : const Icon(Icons.book),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        knjiga.naziv ??
                                                            'Nema naziva',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Autor: ${knjigeAutori[knjiga.knjigaId]?.join(", ") ?? "Nepoznat autor"}",
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        'Godina izdanja: ${knjiga.godinaIzdanja ?? 'Nepoznato'}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          'Trenutno nema dostupnih knjiga',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                            if (AuthProvider.trenutniKorisnikId != null) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Za Vas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              zaVasKnjige.isNotEmpty
                                  ? SizedBox(
                                      height: 220,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: zaVasKnjige.length,
                                        itemBuilder: (context, index) {
                                          final knjiga = zaVasKnjige[index];
                                          return GestureDetector(
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
                                            child: Container(
                                              width: 150,
                                              margin: const EdgeInsets.only(
                                                  right: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[800]
                                                          : Colors.grey[200],
                                                    ),
                                                    child: knjiga.slika != null
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child:
                                                                imageFromString(
                                                                    knjiga
                                                                        .slika!),
                                                          )
                                                        : Center(
                                                            child: Icon(
                                                                Icons.book,
                                                                size: 40,
                                                                color: Theme.of(
                                                                        context)
                                                                    .iconTheme
                                                                    .color),
                                                          ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    knjiga.naziv ??
                                                        'Naziv knjige',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    knjigeAutori[
                                                                knjiga.knjigaId]
                                                            ?.join(", ") ??
                                                        "Nepoznat autor",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            'Trenutno nema personaliziranih preporuka',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
