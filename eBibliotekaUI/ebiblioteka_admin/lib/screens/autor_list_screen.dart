import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../providers/autor_provider.dart';
import '../models/autor.dart';
import 'dart:async';
import 'autor_dodaj_screen.dart';
import 'package:intl/intl.dart';
import '../providers/utils.dart';

class AutorListScreen extends StatefulWidget {
  const AutorListScreen({super.key});

  @override
  State<AutorListScreen> createState() => _AutorListScreenState();
}

class _AutorListScreenState extends State<AutorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AutorProvider _autorProvider = AutorProvider();
  List<Autor> autori = [];
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
        filter['ImeGTE'] = searchQuery;
      }

      var data = await _autorProvider.get(filter: filter);

      setState(() {
        autori = data.result;
        totalItems = data.count;
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

  void _changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Autori",
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
                        hintText: 'Pretraži autora',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pretraži ili dodaj autora',
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
                                builder: (context) => const AutorDodajScreen(),
                              ),
                            )
                            .then((_) => _loadData());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text("Dodaj autora",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (autori.isEmpty)
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
                              ? 'Nema dostupnih autora'
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
                    GridView.builder(
                      itemCount: autori.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final autor = autori[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: autor.slika != null &&
                                            autor.slika!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child:
                                                imageFromString(autor.slika!),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${autor.ime} ${autor.prezime}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AutorDodajScreen(
                                                        autor: autor,
                                                      ),
                                                    ),
                                                  )
                                                  .then((_) => _loadData());
                                            },
                                            color: const Color.fromARGB(
                                                255, 101, 85, 143),
                                          ),
                                        ],
                                      ),
                                      if (autor.datumRodjenja != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            "Datum rođenja: ${DateFormat('dd.MM.yyyy').format(autor.datumRodjenja!)}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          autor.biografija ?? "Nema biografije",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
