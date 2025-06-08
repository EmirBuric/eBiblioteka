import 'package:ebiblioteka_mobile/models/korisnik_izabrana_knjiga.dart';
import 'package:ebiblioteka_mobile/models/rezervacija.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_izabrana_knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/rezervacija_provider.dart';
import 'package:ebiblioteka_mobile/screens/pocetna_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RezervacijaListScreen extends StatefulWidget {
  const RezervacijaListScreen({Key? key}) : super(key: key);

  @override
  _RezervacijaListScreenState createState() => _RezervacijaListScreenState();
}

class _RezervacijaListScreenState extends State<RezervacijaListScreen> {
  List<KorisnikIzabranaKnjiga> _izabraneKnjige = [];
  bool _isLoading = true;
  final KorisnikIzabranaKnjigaProvider _knjigaProvider =
      KorisnikIzabranaKnjigaProvider();
  final RezervacijaProvider _rezervacijaProvider = RezervacijaProvider();

  @override
  void initState() {
    super.initState();
    _loadIzabraneKnjige();
  }

  Future<void> _loadIzabraneKnjige() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var data = await _knjigaProvider.get(filter: {
        'KorisnikId': AuthProvider.trenutniKorisnikId.toString(),
        'IsChecked': 'true'
      });

      setState(() {
        _izabraneKnjige = data.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju izabranih knjiga: $e')),
      );
    }
  }

  Future<void> _toggleIsChecked(KorisnikIzabranaKnjiga knjiga) async {
    try {
      if (knjiga.korisnikIzabranaKnjigaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška: Knjiga nema ID')),
        );
        return;
      }

      await _knjigaProvider.updateIsChecked(knjiga.korisnikIzabranaKnjigaId!);

      await _loadIzabraneKnjige();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri ažuriranju statusa knjige: $e')),
      );
    }
  }

  Future<void> _rezervisiOdabrano() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<int> izabraneKnjigeIds = _izabraneKnjige
          .where((knjiga) => knjiga.korisnikIzabranaKnjigaId != null)
          .map((knjiga) => knjiga.korisnikIzabranaKnjigaId!)
          .toList();

      await _knjigaProvider.updateIsCheckedList(izabraneKnjigeIds);

      for (var knjiga in _izabraneKnjige) {
        var rezervacija = Rezervacija(
          knjigaId: knjiga.knjigaId,
          korisnikId: knjiga.korisnikId,
          datumRezervacije: knjiga.datumRezervacije,
          datumVracanja: knjiga.datumVracanja,
        );

        await _rezervacijaProvider.insert(rezervacija);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uspješno ste rezervisali knjige!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PocetnaScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri rezervaciji knjiga: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izabrane knjige'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _izabraneKnjige.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nema izabranih knjiga'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const PocetnaScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                        child: const Text('Nazad na početnu',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _izabraneKnjige.length,
                        itemBuilder: (ctx, index) {
                          final knjiga = _izabraneKnjige[index];
                          final formattedDate = knjiga.datumRezervacije != null
                              ? DateFormat('dd.MM.yyyy')
                                  .format(knjiga.datumRezervacije!)
                              : 'N/A';
                          final formattedEndDate = knjiga.datumVracanja != null
                              ? DateFormat('dd.MM.yyyy')
                                  .format(knjiga.datumVracanja!)
                              : 'N/A';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple[100],
                                child: const Text('K'),
                              ),
                              title: Text(
                                  knjiga.knjiga?.naziv ?? 'Nepoznat naslov'),
                              subtitle:
                                  Text('$formattedDate - $formattedEndDate'),
                              trailing: Checkbox(
                                value: knjiga.isChecked ?? false,
                                onChanged: (bool? value) {
                                  _toggleIsChecked(knjiga);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('Nazad na pretragu',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: _izabraneKnjige.isNotEmpty
                                ? _rezervisiOdabrano
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                            ),
                            child: const Text('Rezerviši odabrano',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
