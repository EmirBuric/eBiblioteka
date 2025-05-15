import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../providers/knjiga_provider.dart';
import '../providers/zanr_provider.dart';
import '../providers/autor_provider.dart';
import '../models/zanr.dart';
import '../models/autor.dart';
import 'autor_dodaj_screen.dart';

class KnjigaDodajScreen extends StatefulWidget {
  const KnjigaDodajScreen({super.key});

  @override
  State<KnjigaDodajScreen> createState() => _KnjigaDodajScreenState();
}

class _KnjigaDodajScreenState extends State<KnjigaDodajScreen> {
  final _formKey = GlobalKey<FormState>();
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ZanrProvider _zanrProvider = ZanrProvider();
  final AutorProvider _autorProvider = AutorProvider();
  final TextEditingController _autorSearchController = TextEditingController();
  bool isLoading = true;

  List<Zanr> zanrovi = [];
  List<Autor> autori = [];
  List<Autor> filteredAutori = [];
  List<int> selectedAutori = [];

  final TextEditingController _nazivController = TextEditingController();
  final TextEditingController _kratkiOpisController = TextEditingController();
  final TextEditingController _godinaIzdanjaController =
      TextEditingController();
  final TextEditingController _kolicinaController = TextEditingController();
  int? selectedZanrId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _autorSearchController.addListener(_filterAutori);
  }

  @override
  void dispose() {
    _autorSearchController.dispose();
    _nazivController.dispose();
    _kratkiOpisController.dispose();
    _godinaIzdanjaController.dispose();
    _kolicinaController.dispose();
    super.dispose();
  }

  void _filterAutori() {
    final query = _autorSearchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredAutori = [...autori];
      } else {
        filteredAutori = autori.where((autor) {
          final fullName = '${autor.ime} ${autor.prezime}'.toLowerCase();
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      var zanroviData = await _zanrProvider.get();
      var autoriData = await _autorProvider.get();

      setState(() {
        zanrovi = zanroviData.result;
        autori = autoriData.result;
        filteredAutori = autoriData.result.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Greška pri učitavanju: $e");
      print("Stack trace: ${StackTrace.current}");
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final knjiga = {
          'naziv': _nazivController.text,
          'kratkiOpis': _kratkiOpisController.text,
          'godinaIzdanja': int.parse(_godinaIzdanjaController.text),
          'zanrId': selectedZanrId,
          'kolicina': int.parse(_kolicinaController.text),
          'autori': selectedAutori,
          'dostupna': true,
          'knjigaDana': false,
        };

        await _knjigaProvider.insert(knjiga);
        if (mounted) {
          Navigator.of(context).pop();
        }
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
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Dodaj knjigu",
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dodaj novu knjigu',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 101, 85, 143),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nazivController,
                            decoration: InputDecoration(
                              labelText: 'Naziv knjige',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.book),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ovo polje ne može biti prazno';
                              }
                              if (value.length < 2) {
                                return 'Naziv knjige ne može imati manje od dva karaktera';
                              }
                              if (value.length > 50) {
                                return 'Naziv knjige ne može imati više od 50 karaktera';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _kratkiOpisController,
                            decoration: InputDecoration(
                              labelText: 'Kratki opis',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.description),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _godinaIzdanjaController,
                                  decoration: InputDecoration(
                                    labelText: 'Godina izdanja',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obavezno polje';
                                    }
                                    final godina = int.tryParse(value);
                                    if (godina == null) {
                                      return 'Unesite validan broj';
                                    }
                                    if (godina < 1 || godina > 2025) {
                                      return 'Godina 1-2025';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  controller: _kolicinaController,
                                  decoration: InputDecoration(
                                    labelText: 'Količina',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.library_books),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obavezno polje';
                                    }
                                    final kolicina = int.tryParse(value);
                                    if (kolicina == null) {
                                      return 'Unesite broj';
                                    }
                                    if (kolicina < 1) {
                                      return 'Min. 1';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            value: selectedZanrId,
                            decoration: InputDecoration(
                              labelText: 'Žanr',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.category),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            items: zanrovi.map((zanr) {
                              return DropdownMenuItem<int>(
                                value: zanr.zanrId,
                                child: Text(zanr.naziv ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedZanrId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Odaberite žanr';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Odaberite autore:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 101, 85, 143),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _autorSearchController,
                            decoration: InputDecoration(
                              hintText: 'Pretraži autore...',
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
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade50,
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: filteredAutori.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Nema pronađenih autora',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AutorDodajScreen(
                                                      onAutorAdded: () {
                                                        _loadData();
                                                      },
                                                    ),
                                                  ),
                                                )
                                                .then((_) => _loadData());
                                          },
                                          icon: const Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Dodaj novog autora',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 101, 85, 143),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: filteredAutori.map((autor) {
                                        final isSelected = selectedAutori
                                            .contains(autor.autorId);
                                        return FilterChip(
                                          label: Text(
                                            '${autor.ime} ${autor.prezime}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedAutori
                                                    .add(autor.autorId!);
                                              } else {
                                                selectedAutori
                                                    .remove(autor.autorId!);
                                              }
                                            });
                                          },
                                          backgroundColor: Colors.white,
                                          selectedColor: const Color.fromARGB(
                                              255, 101, 85, 143),
                                          checkmarkColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 101, 85, 143),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Spremi knjigu',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
