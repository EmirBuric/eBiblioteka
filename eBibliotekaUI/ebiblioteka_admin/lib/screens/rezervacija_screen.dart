import 'package:ebiblioteka_admin/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import 'package:ebiblioteka_admin/models/rezervacija.dart';
import 'package:ebiblioteka_admin/models/korisnik.dart';
import 'package:ebiblioteka_admin/models/dostupnost_knjige.dart';
import 'package:ebiblioteka_admin/models/clanarina.dart';
import 'package:ebiblioteka_admin/providers/rezervacija_provider.dart';
import 'package:ebiblioteka_admin/providers/korisnik_provider.dart';
import 'package:ebiblioteka_admin/providers/knjiga_provider.dart';
import 'package:ebiblioteka_admin/providers/clanarina_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RezervacijaScreen extends StatefulWidget {
  const RezervacijaScreen({super.key});

  @override
  State<RezervacijaScreen> createState() => _RezervacijaScreenState();
}

class _RezervacijaScreenState extends State<RezervacijaScreen> {
  final RezervacijaProvider _rezervacijaProvider = RezervacijaProvider();
  final KorisnikProvider _korisnikProvider = KorisnikProvider();
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final ClanarinaProvider _clanarinaProvider = ClanarinaProvider();

  List<Rezervacija> rezervacije = [];
  List<Rezervacija> filteredRezervacije = [];
  Map<int, Korisnik> korisnici = {};
  Map<int, DostupnostKnjige> dostupnosti = {};
  Map<int, Clanarina?> clanarine = {};
  bool isLoading = true;
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchType = 'korisnik';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text.toLowerCase()) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
        _searchData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);

      // Dohvati sve rezervacije
      var data = await _rezervacijaProvider.get(
          filter: {'DatumRezervacijeGTE': DateTime.now().toIso8601String()});
      rezervacije = data.result;
      filteredRezervacije = rezervacije;

      // Za svaku rezervaciju dohvati korisnika, dostupnost knjige i članarinu
      await _loadAdditionalData(rezervacije);

      setState(() => isLoading = false);
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

  Future<void> _searchData() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        filteredRezervacije = rezervacije;
        isSearching = false;
      });
      return;
    }

    try {
      setState(() => isSearching = true);

      Map<String, dynamic> filter = {
        'DatumRezervacijeGTE': DateTime.now().toIso8601String()
      };

      if (_searchType == 'korisnik') {
        filter['ImePrezimeGTE'] = _searchQuery;
      } else {
        filter['NazivGTE'] = _searchQuery;
      }

      var data = await _rezervacijaProvider.get(filter: filter);
      List<Rezervacija> searchResults = data.result;

      await _loadAdditionalData(searchResults);

      setState(() {
        filteredRezervacije = searchResults;
        isSearching = false;
      });
    } catch (e) {
      setState(() => isSearching = false);
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

  Future<void> _loadAdditionalData(List<Rezervacija> rezervacijeList) async {
    for (var rezervacija in rezervacijeList) {
      if (rezervacija.korisnikId != null &&
          !korisnici.containsKey(rezervacija.korisnikId)) {
        // Dohvati korisnika
        var korisnikData =
            await _korisnikProvider.getById(rezervacija.korisnikId!);
        korisnici[rezervacija.korisnikId!] = korisnikData;

        // Dohvati članarinu korisnika
        var clanarinaData = await _clanarinaProvider
            .getClanarinaByKorisnikId(rezervacija.korisnikId!);
        clanarine[rezervacija.korisnikId!] = clanarinaData;
      }

      if (rezervacija.knjigaId != null &&
          rezervacija.datumRezervacije != null &&
          rezervacija.datumVracanja != null &&
          !dostupnosti.containsKey(rezervacija.rezervacijaId)) {
        // Dohvati dostupnost knjige za period rezervacije
        var dostupnostData = await _knjigaProvider.getDostupnostZaPeriod(
            rezervacija.knjigaId!,
            rezervacija.datumRezervacije!,
            rezervacija.datumVracanja!);
        dostupnosti[rezervacija.rezervacijaId!] = dostupnostData;
      }
    }
  }

  Future<void> _potvrdiRezervaciju(int rezervacijaId, bool potvrda) async {
    try {
      if (potvrda) {
        Rezervacija? rezervacija;
        for (var r in filteredRezervacije) {
          if (r.rezervacijaId == rezervacijaId) {
            rezervacija = r;
            break;
          }
        }

        if (rezervacija != null) {
          bool knjigaDostupna = _isKnjigaDostupna(rezervacijaId);

          bool clanarinaDostupna = false;
          if (rezervacija.korisnikId != null) {
            clanarinaDostupna = _isClanarinaDostupna(rezervacija.korisnikId!);
          }

          if (!knjigaDostupna || !clanarinaDostupna) {
            return;
          }
        }
      }

      await _rezervacijaProvider.potvrdiRezervaciju(rezervacijaId, potvrda);

      setState(() {
        for (var i = 0; i < filteredRezervacije.length; i++) {
          if (filteredRezervacije[i].rezervacijaId == rezervacijaId) {
            filteredRezervacije[i].odobrena = potvrda;
            break;
          }
        }

        for (var i = 0; i < rezervacije.length; i++) {
          if (rezervacije[i].rezervacijaId == rezervacijaId) {
            rezervacije[i].odobrena = potvrda;
            break;
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(potvrda
                ? 'Rezervacija je prihvaćena'
                : 'Rezervacija je odbijena'),
            backgroundColor: potvrda ? Colors.green : Colors.red,
          ),
        );
      }
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

  void _changeSearchType(String? value) {
    if (value != null && value != _searchType) {
      setState(() {
        _searchType = value;
      });

      if (_searchQuery.isNotEmpty) {
        _searchData();
      }
    }
  }

  bool _isKnjigaDostupna(int rezervacijaId) {
    var dostupnost = dostupnosti[rezervacijaId];
    if (dostupnost == null || dostupnost.dostupnost == null) return false;

    return !dostupnost.dostupnost!.values.contains(false);
  }

  bool _isClanarinaDostupna(int korisnikId) {
    var clanarina = clanarine[korisnikId];
    if (clanarina == null) return false;

    return clanarina.statusClanarine ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Rezervacije",
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pretraga rezervacija',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 101, 85, 143),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: _searchType == 'korisnik'
                                        ? 'Pretraži po imenu i prezimenu korisnika...'
                                        : 'Pretraži po nazivu knjige...',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: isSearching
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              DropdownButton<String>(
                                value: _searchType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'korisnik',
                                    child: Text('Po korisniku'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'knjiga',
                                    child: Text('Po knjizi'),
                                  ),
                                ],
                                onChanged: _changeSearchType,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Rezultati pretrage
                Expanded(
                  child: rezervacije.isEmpty
                      ? const Center(child: Text('Nema rezervacija za prikaz'))
                      : filteredRezervacije.isEmpty
                          ? Center(
                              child: Text(
                                'Nema rezultata za pretragu: $_searchQuery',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  for (var rezervacija in filteredRezervacije)
                                    Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Rezervacija',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 101, 85, 143),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: rezervacija
                                                                .odobrena ==
                                                            null
                                                        ? Colors.orange
                                                        : rezervacija.odobrena!
                                                            ? Colors.green
                                                            : Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    rezervacija.odobrena == null
                                                        ? 'Na čekanju'
                                                        : rezervacija.odobrena!
                                                            ? 'Odobrena'
                                                            : 'Odbijena',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),

                                            // Informacije o knjizi
                                            if (rezervacija.knjiga != null) ...[
                                              Text(
                                                'Knjiga',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: _isKnjigaDostupna(
                                                          rezervacija
                                                              .rezervacijaId!)
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _isKnjigaDostupna(
                                                            rezervacija
                                                                .rezervacijaId!)
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (rezervacija
                                                            .knjiga?.slika !=
                                                        null)
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: SizedBox(
                                                          width: 60,
                                                          height: 80,
                                                          child:
                                                              imageFromString(
                                                                  rezervacija
                                                                      .knjiga!
                                                                      .slika!),
                                                        ),
                                                      )
                                                    else
                                                      Container(
                                                        width: 60,
                                                        height: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Icon(
                                                            Icons.book,
                                                            color: Colors.grey),
                                                      ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            rezervacija.knjiga
                                                                    ?.naziv ??
                                                                'Nepoznata knjiga',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            'Godina: ${rezervacija.knjiga?.godinaIzdanja ?? 'Nepoznato'}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                _isKnjigaDostupna(
                                                                        rezervacija
                                                                            .rezervacijaId!)
                                                                    ? Icons
                                                                        .check_circle
                                                                    : Icons
                                                                        .cancel,
                                                                color: _isKnjigaDostupna(
                                                                        rezervacija
                                                                            .rezervacijaId!)
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                _isKnjigaDostupna(
                                                                        rezervacija
                                                                            .rezervacijaId!)
                                                                    ? 'Dostupna'
                                                                    : 'Nije dostupna',
                                                                style:
                                                                    TextStyle(
                                                                  color: _isKnjigaDostupna(
                                                                          rezervacija
                                                                              .rezervacijaId!)
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 16),

                                            // Informacije o korisniku
                                            if (rezervacija.korisnikId !=
                                                    null &&
                                                korisnici.containsKey(
                                                    rezervacija
                                                        .korisnikId)) ...[
                                              Text(
                                                'Korisnik',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: _isClanarinaDostupna(
                                                          rezervacija
                                                              .korisnikId!)
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _isClanarinaDostupna(
                                                            rezervacija
                                                                .korisnikId!)
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          _isClanarinaDostupna(
                                                                  rezervacija
                                                                      .korisnikId!)
                                                              ? Colors.green
                                                              : Colors.red,
                                                      child: Text(
                                                        '${korisnici[rezervacija.korisnikId!]?.ime?.substring(0, 1) ?? ''}${korisnici[rezervacija.korisnikId!]?.prezime?.substring(0, 1) ?? ''}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${korisnici[rezervacija.korisnikId!]?.ime ?? ''} ${korisnici[rezervacija.korisnikId!]?.prezime ?? ''}',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            korisnici[rezervacija
                                                                        .korisnikId!]
                                                                    ?.email ??
                                                                '',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                _isClanarinaDostupna(
                                                                        rezervacija
                                                                            .korisnikId!)
                                                                    ? Icons
                                                                        .check_circle
                                                                    : Icons
                                                                        .cancel,
                                                                color: _isClanarinaDostupna(
                                                                        rezervacija
                                                                            .korisnikId!)
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                _isClanarinaDostupna(
                                                                        rezervacija
                                                                            .korisnikId!)
                                                                    ? 'Aktivna članarina'
                                                                    : 'Neaktivna članarina',
                                                                style:
                                                                    TextStyle(
                                                                  color: _isClanarinaDostupna(
                                                                          rezervacija
                                                                              .korisnikId!)
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 16),

                                            // Datumi rezervacije
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Datum rezervacije',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        rezervacija.datumRezervacije !=
                                                                null
                                                            ? DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(rezervacija
                                                                    .datumRezervacije!)
                                                            : 'Nije određeno',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Datum vraćanja',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        rezervacija.datumVracanja !=
                                                                null
                                                            ? DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(rezervacija
                                                                    .datumVracanja!)
                                                            : 'Nije određeno',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 24),

                                            // Akcije
                                            if (rezervacija.odobrena == null)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  OutlinedButton(
                                                    onPressed: () =>
                                                        _potvrdiRezervaciju(
                                                            rezervacija
                                                                .rezervacijaId!,
                                                            false),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      side: const BorderSide(
                                                          color: Colors.red),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 24,
                                                          vertical: 12),
                                                    ),
                                                    child: const Text('Odbij'),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Tooltip(
                                                    message: !_isKnjigaDostupna(
                                                                rezervacija
                                                                    .rezervacijaId!) &&
                                                            (rezervacija.korisnikId ==
                                                                    null ||
                                                                !_isClanarinaDostupna(
                                                                    rezervacija
                                                                        .korisnikId!))
                                                        ? "Knjiga nije dostupna i korisnik nema aktivnu članarinu"
                                                        : !_isKnjigaDostupna(
                                                                rezervacija
                                                                    .rezervacijaId!)
                                                            ? "Knjiga nije dostupna za traženi period"
                                                            : rezervacija.korisnikId ==
                                                                        null ||
                                                                    !_isClanarinaDostupna(
                                                                        rezervacija
                                                                            .korisnikId!)
                                                                ? "Korisnik nema aktivnu članarinu"
                                                                : "",
                                                    child: ElevatedButton(
                                                      onPressed: _isKnjigaDostupna(
                                                                  rezervacija
                                                                      .rezervacijaId!) &&
                                                              (rezervacija.korisnikId !=
                                                                      null &&
                                                                  _isClanarinaDostupna(
                                                                      rezervacija
                                                                          .korisnikId!))
                                                          ? () => _potvrdiRezervaciju(
                                                              rezervacija
                                                                  .rezervacijaId!,
                                                              true)
                                                          : null,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                101, 85, 143),
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 24,
                                                                vertical: 12),
                                                        disabledBackgroundColor:
                                                            Colors
                                                                .grey.shade300,
                                                        disabledForegroundColor:
                                                            Colors
                                                                .grey.shade600,
                                                      ),
                                                      child: const Text(
                                                          'Prihvati'),
                                                    ),
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
              ],
            ),
    );
  }
}
