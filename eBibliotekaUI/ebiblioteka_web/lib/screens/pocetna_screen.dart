import 'package:flutter/material.dart';
import '../layouts/master_screen.dart';
import '../models/knjiga.dart';
import '../providers/knjiga_provider.dart';
import '../providers/zanr_provider.dart';
import '../providers/utils.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ZanrProvider _zanrProvider = ZanrProvider();
  Knjiga? knjigaDana;
  List<Knjiga> preporuceneKnjige = [];
  Map<int, String> zanrovi = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      var zanroviData = await _zanrProvider.get();
      zanrovi = {
        for (var zanr in zanroviData.result) zanr.zanrId ?? 0: zanr.naziv ?? ''
      };

      var data = await _knjigaProvider.get(filter: {'KnjigaDana': true});
      if (data.result.isNotEmpty) {
        knjigaDana = data.result.first;
      }

      var preporuceneData =
          await _knjigaProvider.get(filter: {'Preporuceno': true});
      preporuceneKnjige = preporuceneData.result;

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _openSearchModal() async {
    List<Knjiga> modalBooks = [];
    int modalCurrentPage = 1;
    int modalTotalItems = 0;
    const int modalPageSize = 8;
    final controller = TextEditingController();

    Future<void> fetchModalBooks(
        {int? page,
        required void Function(void Function()) dialogSetState}) async {
      int p = page ?? modalCurrentPage;
      var response = await _knjigaProvider.get(filter: {
        if (controller.text.trim().isNotEmpty) 'NazivGTE': controller.text,
        'Page': p,
        'PageSize': modalPageSize,
      });
      dialogSetState(() {
        modalBooks = response.result;
        modalTotalItems = response.count;
        modalCurrentPage = p;
      });
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if ((controller.text.trim().isEmpty ||
                  controller.text.trim().length >= 3) &&
              modalBooks.isEmpty) {
            fetchModalBooks(page: 1, dialogSetState: setModalState);
          }
          return AlertDialog(
            title: const Text("Pretraži knjige"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Pretraži..."),
                  onChanged: (query) {
                    if (query.isEmpty) {
                      fetchModalBooks(page: 1, dialogSetState: setModalState);
                    } else if (query.trim().length < 3) {
                      setModalState(() {
                        modalBooks = [];
                        modalTotalItems = 0;
                        modalCurrentPage = 1;
                      });
                    } else {
                      fetchModalBooks(page: 1, dialogSetState: setModalState);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.maxFinite,
                  height: 300,
                  child: modalBooks.isNotEmpty
                      ? ListView.builder(
                          itemCount: modalBooks.length,
                          itemBuilder: (context, index) {
                            var knjiga = modalBooks[index];
                            return Card(
                              child: ListTile(
                                leading: knjiga.slika != null
                                    ? SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: imageFromString(knjiga.slika!),
                                      )
                                    : const Icon(Icons.image),
                                title: Text(knjiga.naziv ?? 'Nepoznat naziv'),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _knjigaProvider
                                          .getById(knjiga.knjigaId!);
                                      var data = await _knjigaProvider
                                          .get(filter: {'KnjigaDana': true});
                                      setState(() {
                                        if (data.result.isNotEmpty) {
                                          knjigaDana = data.result.first;
                                        }
                                      });
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      Navigator.of(context).pop();
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Greška"),
                                          content: Text(
                                              "Dogodila se greška prilikom postavljanja knjige dana: $e"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Odaberi"),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("Nema rezultata")),
                ),
                const SizedBox(height: 8),
                if (modalTotalItems > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: modalCurrentPage > 1
                            ? () {
                                fetchModalBooks(
                                    page: modalCurrentPage - 1,
                                    dialogSetState: setModalState);
                              }
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Text(
                          'Stranica $modalCurrentPage od ${(modalTotalItems / modalPageSize).ceil()}'),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: modalCurrentPage <
                                (modalTotalItems / modalPageSize).ceil()
                            ? () {
                                fetchModalBooks(
                                    page: modalCurrentPage + 1,
                                    dialogSetState: setModalState);
                              }
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPreporuceneModal() async {
    List<Knjiga> modalBooks = [];
    int modalCurrentPage = 1;
    int modalTotalItems = 0;
    const int modalPageSize = 8;
    final controller = TextEditingController();
    List<int> selectedIds = [];

    Future<void> fetchModalBooks(
        {int? page,
        required void Function(void Function()) dialogSetState}) async {
      int p = page ?? modalCurrentPage;
      var response = await _knjigaProvider.get(filter: {
        if (controller.text.trim().isNotEmpty) 'NazivGTE': controller.text,
        'Page': p,
        'PageSize': modalPageSize,
        'KnjigaDana': false,
      });
      dialogSetState(() {
        modalBooks = response.result;
        modalTotalItems = response.count;
        modalCurrentPage = p;
        selectedIds = modalBooks
            .where((knjiga) =>
                knjiga.preporuceno == true && knjiga.knjigaId != null)
            .map((knjiga) => knjiga.knjigaId!)
            .toList();
      });
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if ((controller.text.trim().isEmpty ||
                  controller.text.trim().length >= 3) &&
              modalBooks.isEmpty) {
            fetchModalBooks(page: 1, dialogSetState: setModalState);
          }
          return AlertDialog(
            title: const Text("Pretraži preporučene knjige"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Pretraži..."),
                  onChanged: (query) {
                    if (query.isEmpty) {
                      fetchModalBooks(page: 1, dialogSetState: setModalState);
                    } else if (query.trim().length < 3) {
                      setModalState(() {
                        modalBooks = [];
                        modalTotalItems = 0;
                        modalCurrentPage = 1;
                      });
                    } else {
                      fetchModalBooks(page: 1, dialogSetState: setModalState);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.maxFinite,
                  height: 300,
                  child: modalBooks.isNotEmpty
                      ? ListView.builder(
                          itemCount: modalBooks.length,
                          itemBuilder: (context, index) {
                            var knjiga = modalBooks[index];
                            bool isSelected =
                                selectedIds.contains(knjiga.knjigaId);
                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(knjiga.naziv ?? 'Nepoznat naziv'),
                              secondary: knjiga.slika != null
                                  ? SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: imageFromString(knjiga.slika!),
                                    )
                                  : const Icon(Icons.image),
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    selectedIds.add(knjiga.knjigaId!);
                                  } else {
                                    selectedIds.remove(knjiga.knjigaId);
                                  }
                                });
                              },
                            );
                          },
                        )
                      : const Center(child: Text("Nema rezultata")),
                ),
                const SizedBox(height: 8),
                if (modalTotalItems > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: modalCurrentPage > 1
                            ? () {
                                fetchModalBooks(
                                    page: modalCurrentPage - 1,
                                    dialogSetState: setModalState);
                              }
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Text(
                          'Stranica $modalCurrentPage od ${(modalTotalItems / modalPageSize).ceil()}'),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: modalCurrentPage <
                                (modalTotalItems / modalPageSize).ceil()
                            ? () {
                                fetchModalBooks(
                                    page: modalCurrentPage + 1,
                                    dialogSetState: setModalState);
                              }
                            : null,
                      ),
                    ],
                  ),
                if (modalBooks.isNotEmpty) const SizedBox(height: 16),
                if (modalBooks.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _knjigaProvider.get();
                        var data = await _knjigaProvider
                            .get(filter: {'Preporuceno': true});
                        setState(() {
                          preporuceneKnjige = data.result;
                        });
                        Navigator.of(context).pop();
                      } catch (e) {
                        Navigator.of(context).pop();
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Greška"),
                            content: Text(
                                "Dogodila se greška prilikom postavljanja preporučenih knjiga: $e"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text("Potvrdi"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Početna',
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            // Knjiga dana sekcija
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : knjigaDana == null
                      ? Column(
                          children: [
                            const Center(
                              child: Text(
                                'Nema knjige dana',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _openSearchModal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Promijeni knjigu',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Knjiga dana',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          zanrovi[knjigaDana?.zanrId] ??
                                              'Nepoznat žanr',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          knjigaDana?.naziv ?? 'Nepoznat naziv',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          knjigaDana?.kratkiOpis ??
                                              'Nema opisa',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: knjigaDana?.slika != null
                                      ? SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: imageFromString(
                                              knjigaDana!.slika!),
                                        )
                                      : Container(
                                          color: Colors.white,
                                          width: 100,
                                          height: 100,
                                          child: const Icon(Icons.image,
                                              size: 60, color: Colors.grey),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _openSearchModal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Promijeni knjigu',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preporučene knjige',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 16),
                if (!isLoading && preporuceneKnjige.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: preporuceneKnjige
                        .take(3)
                        .map((knjiga) =>
                            _BookCard(knjiga: knjiga, zanrovi: zanrovi))
                        .toList(),
                  )
                else
                  const Center(
                    child: Text(
                      'Nemate preporučenih knjiga',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _openPreporuceneModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Promijeni preporučene knjige',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Knjiga knjiga;
  final Map<int, String> zanrovi;

  const _BookCard({required this.knjiga, required this.zanrovi});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: knjiga.slika != null
                  ? SizedBox(
                      width: 60,
                      height: 60,
                      child: imageFromString(knjiga.slika!),
                    )
                  : const Icon(Icons.image, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              zanrovi[knjiga.zanrId] ?? 'Nepoznat žanr',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              knjiga.naziv ?? 'Nepoznat naziv',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              knjiga.kratkiOpis ?? 'Nema opisa',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
