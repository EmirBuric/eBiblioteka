import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/citaonica.dart';
import 'package:ebiblioteka_mobile/models/termin.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/citaonica_provider.dart';
import 'package:ebiblioteka_mobile/providers/termin_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:flutter/material.dart';

class TerminListScreen extends StatefulWidget {
  final int? citaonicaId;
  final String? citaonicaNaziv;
  final int? korisnikId;
  final String? naslov;
  final bool isPromjenaTermina;
  final Function? onTerminOdabran;

  const TerminListScreen({
    Key? key,
    this.citaonicaId,
    this.citaonicaNaziv,
    this.korisnikId,
    this.naslov,
    this.isPromjenaTermina = false,
    this.onTerminOdabran,
  })  : assert((citaonicaId != null && citaonicaNaziv != null) ||
            (korisnikId != null && naslov != null)),
        super(key: key);

  @override
  State<TerminListScreen> createState() => _TerminListScreenState();
}

class _TerminListScreenState extends State<TerminListScreen> {
  final TerminProvider _terminProvider = TerminProvider();
  final CitaonicaProvider _citaonicaProvider = CitaonicaProvider();
  List<Termin> _termini = [];
  Map<int, String> _citaoniceNazivi = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _pageSize = 8;
  bool _hasMoreData = true;
  bool _isRezervisanje = false;
  bool _isOtkazivanje = false;
  bool _terminOdabran = false;

  final ScrollController _scrollController = ScrollController();

  bool get _isPrikazKorisnika => widget.korisnikId != null;

  @override
  void initState() {
    super.initState();
    _loadTermini();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoadingMore &&
          _hasMoreData) {
        _loadMoreTermini();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, String> _getFilters() {
    Map<String, String> filters = {
      'page': '1',
      'pageSize': _pageSize.toString(),
      'jeProsao': 'false',
    };

    if (_isPrikazKorisnika) {
      filters['korisnikId'] = widget.korisnikId.toString();
    } else {
      filters['citaonicaId'] = widget.citaonicaId.toString();
      filters['jeRezervisan'] = 'false';
    }

    return filters;
  }

  Future<void> _loadTermini() async {
    try {
      var result = await _terminProvider.get(filter: _getFilters());
      setState(() {
        _termini = result.result;
        _isLoading = false;
        _page = 1;
        _hasMoreData = result.result.length >= _pageSize;
      });

      if (_isPrikazKorisnika) {
        _loadCitaoniceNazivi();
      }
    } catch (e) {
      print('Greška prilikom učitavanja termina: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCitaoniceNazivi() async {
    try {
      var citaonice = await _citaonicaProvider.get();
      if (citaonice.result.isNotEmpty) {
        setState(() {
          for (var citaonica in citaonice.result) {
            _citaoniceNazivi[citaonica.citaonicaId!] = citaonica.naziv!;
          }
        });
      }
    } catch (e) {
      print('Greška prilikom učitavanja naziva čitaonica: $e');
    }
  }

  Future<void> _loadMoreTermini() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Map<String, String> filters = _getFilters();
      filters['page'] = (_page + 1).toString();

      var result = await _terminProvider.get(filter: filters);

      if (result.result.isNotEmpty) {
        setState(() {
          _termini.addAll(result.result);
          _page++;
          _hasMoreData = result.result.length >= _pageSize;
        });

        if (_isPrikazKorisnika) {
          _loadCitaoniceNazivi();
        }
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('Greška prilikom učitavanja više termina: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadTermini();
  }

  Future<void> _rezervisiTermin(int terminId) async {
    if (AuthProvider.trenutniKorisnikId == null) {
      _prikaziPoruku(
          'Niste prijavljeni. Molimo prijavite se da biste rezervisali termin.');
      return;
    }

    setState(() {
      _isRezervisanje = true;
    });

    try {
      await _terminProvider.rezervisiTermin(
          terminId, AuthProvider.trenutniKorisnikId!);

      setState(() {
        _terminOdabran = true;
      });

      _prikaziPoruku('Termin je uspješno rezervisan!');

      if (widget.isPromjenaTermina && widget.onTerminOdabran != null) {
        widget.onTerminOdabran!();
        Navigator.of(context).pop();
      } else {
        _loadTermini();
      }
    } catch (e) {
      _prikaziPoruku('Greška prilikom rezervacije termina: ${e.toString()}');
    } finally {
      setState(() {
        _isRezervisanje = false;
      });
    }
  }

  Future<void> _otkaziTermin(int terminId) async {
    setState(() {
      _isOtkazivanje = true;
    });

    try {
      await _terminProvider.otkaziTermin(terminId);

      _prikaziPoruku('Termin je uspješno otkazan!');
      _loadTermini();
    } catch (e) {
      _prikaziPoruku('Greška prilikom otkazivanja termina: ${e.toString()}');
    } finally {
      setState(() {
        _isOtkazivanje = false;
      });
    }
  }

  void _prikaziPoruku(String poruka) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(poruka),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _prikaziModalZaPotvrdu(Termin termin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.isPromjenaTermina
              ? 'Potvrda novog termina'
              : 'Potvrda rezervacije'),
          content: Text(widget.isPromjenaTermina
              ? 'Da li želite odabrati ${_formatTerminTitle(termin).toLowerCase()} kao novi termin?'
              : 'Da li želite rezervisati ${_formatTerminTitle(termin).toLowerCase()}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zatvori modal
              },
              child: const Text('Ne'),
            ),
            TextButton(
              onPressed: _isRezervisanje
                  ? null // Onemogućavamo dugme dok traje rezervacija
                  : () {
                      Navigator.of(context).pop(); // Zatvori modal
                      _rezervisiTermin(termin.terminId!);
                    },
              child: _isRezervisanje
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Da'),
            ),
          ],
        );
      },
    );
  }

  void _prikaziModalZaOtkazivanje(Termin termin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda otkazivanja'),
          content: Text(
              'Da li ste sigurni da želite otkazati ${_formatTerminTitle(termin).toLowerCase()}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ne'),
            ),
            TextButton(
              onPressed: _isOtkazivanje
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _otkaziTermin(termin.terminId!);
                    },
              child: _isOtkazivanje
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Da'),
            ),
          ],
        );
      },
    );
  }

  void _prikaziModalZaPromjenu(Termin termin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Promjena termina'),
          content: Text(
              'Da li želite promijeniti ${_formatTerminTitle(termin).toLowerCase()}? Trenutni termin će biti otkazan, a vi ćete moći odabrati novi termin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ne'),
            ),
            TextButton(
              onPressed: _isOtkazivanje
                  ? null
                  : () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _isOtkazivanje = true;
                      });

                      try {
                        await _terminProvider.otkaziTermin(termin.terminId!);

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TerminListScreen(
                                citaonicaId: termin.citaonicaId,
                                citaonicaNaziv: 'Odabir novog termina',
                                isPromjenaTermina: true,
                                onTerminOdabran: () {},
                              ),
                            ),
                          ).then((_) {
                            _loadTermini();
                          });
                        }
                      } catch (e) {
                        _prikaziPoruku(
                            'Greška prilikom promjene termina: ${e.toString()}');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isOtkazivanje = false;
                          });
                        }
                      }
                    },
              child: _isOtkazivanje
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Da'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleWillPop() async {
    if (widget.isPromjenaTermina && !_terminOdabran) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Obavještenje'),
          content: const Text(
              'Morate odabrati novi termin prije povratka. Molimo odaberite jedan od dostupnih termina.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: MasterScreen(
        selectedIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: widget.isPromjenaTermina
                ? Text('Odabir novog termina')
                : (_isPrikazKorisnika ? Text(widget.naslov!) : null),
            centerTitle: true,
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (!_isPrikazKorisnika && !widget.isPromjenaTermina)
                      _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.isPromjenaTermina
                              ? 'Odaberite novi termin'
                              : (_isPrikazKorisnika
                                  ? 'Vaši rezervisani termini'
                                  : 'Dostupni termini'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTerminiList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        image: DecorationImage(
          image: AssetImage('assets/images/Citaonica.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black26,
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.citaonicaNaziv!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminiList() {
    if (_termini.isEmpty) {
      return Center(
        child: Text(widget.isPromjenaTermina
            ? 'Nema dostupnih termina za odabir'
            : (_isPrikazKorisnika
                ? 'Nemate rezervisanih termina'
                : 'Nema dostupnih termina')),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _termini.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _termini.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final termin = _termini[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.access_time,
                      color: Colors.grey,
                    ),
                  ),
                  title: Text(
                    _formatTerminTitle(termin),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: _isPrikazKorisnika && termin.citaonicaId != null
                      ? Text(
                          'Čitaonica: ${_getCitaonicaNaziv(termin.citaonicaId!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        )
                      : Text(
                          widget.isPromjenaTermina
                              ? 'Odaberite ovaj termin'
                              : 'Rezerviši termin',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                  trailing: (!_isPrikazKorisnika || widget.isPromjenaTermina)
                      ? const Icon(Icons.more_vert)
                      : null,
                  onTap: () {
                    if (!_isPrikazKorisnika || widget.isPromjenaTermina) {
                      _prikaziModalZaPotvrdu(termin);
                    }
                  },
                ),
                if (_isPrikazKorisnika && !widget.isPromjenaTermina)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _prikaziModalZaOtkazivanje(termin),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Otkaži'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _prikaziModalZaPromjenu(termin),
                          child: const Text('Promijeni'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCitaonicaNaziv(int citaonicaId) {
    return _citaoniceNazivi[citaonicaId] ?? 'Nepoznata čitaonica';
  }

  String _formatTerminTitle(Termin termin) {
    if (termin.datum == null || termin.start == null) return 'Termin';

    final date = formatDateToLocal(termin.datum!);

    String time =
        '${termin.start!.hour}:${termin.start!.minute.toString().padLeft(2, '0')}';

    return 'Termin $date $time';
  }
}
