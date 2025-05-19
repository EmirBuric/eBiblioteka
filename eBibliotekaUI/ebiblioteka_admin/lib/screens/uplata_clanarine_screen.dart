import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../models/tip_clanarine.dart';
import '../models/clanarina.dart';
import '../models/korisnik.dart';
import '../providers/clanarina_provider.dart';
import '../providers/tip_clanarine_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class UplataClanarineScreen extends StatefulWidget {
  const UplataClanarineScreen({super.key});

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
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    korisnik = ModalRoute.of(context)?.settings.arguments as Korisnik?;
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      var tipoviData = await _tipClanarineProvider.get();
      var zadnjaData = await _clanarinaProvider.get(filter: {
        'KorisnikId': korisnik?.korisnikId ?? AuthProvider.trenutniKorisnikId
      });

      setState(() {
        tipoviClanarine = tipoviData.result;
        zadnjaClanarina =
            zadnjaData.result.isNotEmpty ? zadnjaData.result.first : null;
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

  Future<void> _uplatiClanarinu(int tipClanarineId) async {
    try {
      await _clanarinaProvider.insert({
        'korisnikId': korisnik?.korisnikId ?? AuthProvider.trenutniKorisnikId,
        'tipClanarineId': tipClanarineId,
        'statusClanarine': 'Aktivan',
        'datumUplate': DateTime.now().toIso8601String()
      });

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
                                    DateFormat('dd.MM.yyyy')
                                        .format(zadnjaClanarina!.datumUplate!),
                                  ),
                                ),
                                ListTile(
                                  title: const Text('Datum isteka'),
                                  subtitle: Text(
                                    DateFormat('dd.MM.yyyy')
                                        .format(zadnjaClanarina!.datumIsteka!),
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
                                const Text('Nemate uplaćenu članarinu'),
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
