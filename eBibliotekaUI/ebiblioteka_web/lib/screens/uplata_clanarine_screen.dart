import 'package:flutter/material.dart';
import 'package:ebiblioteka_web/layouts/master_screen.dart';
import '../models/tip_clanarine.dart';
import '../models/clanarina.dart';
import '../models/korisnik.dart';
import '../providers/clanarina_provider.dart';
import '../providers/tip_clanarine_provider.dart';
import '../providers/utils.dart';

class UplataClanarineScreen extends StatefulWidget {
  final Korisnik? korisnik;

  const UplataClanarineScreen({super.key, this.korisnik});

  @override
  State<UplataClanarineScreen> createState() => _UplataClanarineScreenState();
}

class _UplataClanarineScreenState extends State<UplataClanarineScreen> {
  final ClanarinaProvider _clanarinaProvider = ClanarinaProvider();
  final TipClanarineProvider _tipClanarineProvider = TipClanarineProvider();
  List<TipClanarine> tipoviClanarine = [];
  Clanarina? zadnjaClanarina;
  bool isLoading = true;
  Korisnik? korisnik;

  @override
  void initState() {
    super.initState();
    korisnik = widget.korisnik;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      var tipoviData = await _tipClanarineProvider.get();

      if (korisnik != null) {
        zadnjaClanarina = await _clanarinaProvider
            .getClanarinaByKorisnikId(korisnik!.korisnikId!);

        setState(() {
          tipoviClanarine = tipoviData.result;
          isLoading = false;
        });
      } else {
        setState(() {
          tipoviClanarine = tipoviData.result;
          isLoading = false;
        });
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

  Future<void> _uplatiClanarinu(int tipClanarineId) async {
    try {
      if (korisnik == null) {
        throw Exception('Korisnik nije odabran');
      }

      final Map<String, dynamic> clanarinaData = {
        'korisnikId': korisnik!.korisnikId,
        'tipClanarineId': tipClanarineId,
        'statusClanarine': true,
        'datumUplate': DateTime.now().toIso8601String()
      };

      if (zadnjaClanarina != null) {
        // Ažuriranje postojeće članarine
        await _clanarinaProvider.update(
            zadnjaClanarina!.clanarinaId!, clanarinaData);
      } else {
        // Kreiranje nove članarine
        await _clanarinaProvider.insert(clanarinaData);
      }

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Članarina je uspješno uplaćena!'),
            backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Uplata članarine",
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                              Text(
                                'Status članarine - ${korisnik?.ime ?? ''} ${korisnik?.prezime ?? ''}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 101, 85, 143),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (zadnjaClanarina != null) ...[
                                ListTile(
                                  title: const Text('Datum uplate'),
                                  subtitle: Text(
                                    formatDateToLocal(
                                        zadnjaClanarina!.datumUplate!),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Datum isteka'),
                                  subtitle: Text(
                                    formatDateToLocal(
                                        zadnjaClanarina!.datumIsteka!),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Status'),
                                  subtitle: Text(
                                    DateTime.now().isBefore(
                                            zadnjaClanarina!.datumIsteka!)
                                        ? 'Aktivna'
                                        : 'Istekla',
                                    style: TextStyle(
                                      color: DateTime.now().isBefore(
                                              zadnjaClanarina!.datumIsteka!)
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ] else
                                const Text('Nema uplaćene članarine'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                                'Uplata članarine',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 101, 85, 143),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...tipoviClanarine
                                  .map((tip) => Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ListTile(
                                          title: Text(
                                              'Tip članarine ${tip.tipClanarineId}'),
                                          subtitle: Text(
                                            'Trajanje: ${tip.vrijemeTrajanja} mjeseci\nCijena: ${tip.cijena} KM',
                                          ),
                                          trailing: ElevatedButton(
                                            onPressed: () => _uplatiClanarinu(
                                                tip.tipClanarineId!),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 101, 85, 143),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Odaberi'),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
