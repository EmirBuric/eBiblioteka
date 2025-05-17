import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../providers/knjiga_provider.dart';
import '../providers/zanr_provider.dart';
import '../providers/autor_provider.dart';
import '../providers/knjiga_autor_provider.dart';
import '../models/knjiga.dart';
import 'dart:async';
import 'knjiga_dodaj_screen.dart';
import '../providers/utils.dart';

class KnjigeListScreen extends StatefulWidget {
  const KnjigeListScreen({super.key});

  @override
  State<KnjigeListScreen> createState() => _KnjigeListScreenState();
}

class _KnjigeListScreenState extends State<KnjigeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ZanrProvider _zanrProvider = ZanrProvider();
  final AutorProvider _autorProvider = AutorProvider();
  final KnjigaAutorProvider _knjigaAutorProvider = KnjigaAutorProvider();
  List<Knjiga> books = [];
  Map<int, String> zanrNames = {};
  Map<int, List<String>> knjigeAutori = {};
  bool isLoading = true;
  String searchQuery = "";
  Timer? _debounce;

  int currentPage = 1;
  int pageSize = 8;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchController.text;
        currentPage = 1;
      });
      _loadData();
    });
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

      if (searchQuery.isNotEmpty) {
        filter['NazivGTE'] = searchQuery;
      }

      var data = await _knjigaProvider.get(filter: filter);

      var zanroviData = await _zanrProvider.get();
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
        books = data.result;
        totalItems = data.count;
        zanrNames = zanroviMap;
        knjigeAutori = knjigeAutoriMap;
        isLoading = false;
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

  Future<void> _deleteKnjiga(int knjigaId) async {
    try {
      await _knjigaProvider.Delete(knjigaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knjiga je uspješno obrisana'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadData();
    } catch (e) {
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

  void _changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Knjige",
      Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color.fromARGB(255, 101, 85, 143),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Pretraži knjigu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pretraži ili dodaj knjigu',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const KnjigaDodajScreen(),
                              ),
                            )
                            .then((_) => _loadData());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text("Dodaj knjigu",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (books.isEmpty)
                Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 50,
                          color: Color.fromARGB(255, 101, 85, 143),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'Nema dostupnih knjiga'
                              : 'Nema rezultata za pretragu "$searchQuery"',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 101, 85, 143),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Book cards
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        itemCount: books.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: book.slika != null &&
                                            book.slika!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            child: imageFromString(book.slika!),
                                          )
                                        : const Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          zanrNames[book.zanrId] ??
                                              "Nepoznat žanr",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.naziv ?? "Bez naziva",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          knjigeAutori[book.knjigaId]
                                                  ?.join(", ") ??
                                              "Nepoznat autor",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.kratkiOpis ?? "Bez opisa",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: book.dostupna ?? false
                                                    ? Colors.green[100]
                                                    : Colors.red[100],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                book.dostupna ?? false
                                                    ? 'Dostupna'
                                                    : 'Nedostupna',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: book.dostupna ?? false
                                                      ? Colors.green[800]
                                                      : Colors.red[800],
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      size: 20),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                KnjigaDodajScreen(
                                                              knjiga: book,
                                                            ),
                                                          ),
                                                        )
                                                        .then(
                                                            (_) => _loadData());
                                                  },
                                                  color: const Color.fromARGB(
                                                      255, 101, 85, 143),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      size: 20),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            "Potvrda brisanja"),
                                                        content: const Text(
                                                            "Da li ste sigurni da želite obrisati ovu knjigu?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                "Odustani"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteKnjiga(book
                                                                  .knjigaId!);
                                                            },
                                                            child: const Text(
                                                                "Obriši",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  color: Colors.red,
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
                          );
                        },
                      ),
                    ),
                    if (totalItems > 0)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 1
                                  ? () => _changePage(currentPage - 1)
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Stranica $currentPage od ${(totalItems / pageSize).ceil()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed:
                                  currentPage < (totalItems / pageSize).ceil()
                                      ? () => _changePage(currentPage + 1)
                                      : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
