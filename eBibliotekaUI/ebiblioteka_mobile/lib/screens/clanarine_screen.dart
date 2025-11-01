import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/clanarina.dart';
import 'package:ebiblioteka_mobile/models/tip_clanarine.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/clanarina_provider.dart';
import 'package:ebiblioteka_mobile/providers/tip_clanarine_provider.dart';
import 'package:ebiblioteka_mobile/screens/pay_pal_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';

class ClanarineScreen extends StatefulWidget {
  const ClanarineScreen({Key? key}) : super(key: key);

  @override
  State<ClanarineScreen> createState() => _ClanarineScreenState();
}

class _ClanarineScreenState extends State<ClanarineScreen> {
  final ClanarinaProvider _clanarinaProvider = ClanarinaProvider();
  final TipClanarineProvider _tipClanarineProvider = TipClanarineProvider();

  bool isLoading = true;
  Clanarina? clanarina;
  List<TipClanarine> tipoviClanarine = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var korisnikId = AuthProvider.trenutniKorisnikId;
      if (korisnikId != null) {
        clanarina =
            await _clanarinaProvider.getClanarinaByKorisnikId(korisnikId);
      }

      var tipClanarineResult = await _tipClanarineProvider.get();
      tipoviClanarine = tipClanarineResult.result;

      setState(() {
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

  Future<void> _navigateToPayPalScreen(int tipClanarineId) async {
    final odabraniTipClanarine = tipoviClanarine
        .firstWhere((tip) => tip.tipClanarineId == tipClanarineId);

    final preostaloTrajanje = _izracunajPreostaloTrajanje();

    if (clanarina == null || clanarina!.datumIsteka == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayPalScreen(tipClanarineId: tipClanarineId),
        ),
      );

      if (result == true) {
        _loadData();
      }
      return;
    }

    if (odabraniTipClanarine.vrijemeTrajanja! <= preostaloTrajanje) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Upozorenje"),
          content: Text(
              "Vaša trenutna članarina traje još $preostaloTrajanje mjeseci, što je duže od trajanja odabranog tipa članarine (${odabraniTipClanarine.vrijemeTrajanja} mjeseci). Molimo odaberite duži period članarine."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayPalScreen(tipClanarineId: tipClanarineId),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  int _izracunajPreostaloTrajanje() {
    if (clanarina == null || clanarina!.datumIsteka == null) {
      return 0;
    }

    final danas = DateTime.now();
    final datumIsteka = clanarina!.datumIsteka!;

    if (datumIsteka.isBefore(danas)) {
      return 0;
    }

    final int razlikaUDanima = datumIsteka.difference(danas).inDays;

    final int mjeseci = (razlikaUDanima / 30).ceil() - 1;

    return mjeseci;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Članarina'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Vaša članarina važi do:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    clanarina?.datumIsteka != null
                                        ? formatDateToLocal(
                                            clanarina!.datumIsteka!)
                                        : "Niste uplatili članarinu",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Produžite u trajanju od:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tipoviClanarine.length,
                        itemBuilder: (context, index) {
                          final tipClanarine = tipoviClanarine[index];
                          String trajanje;

                          if (tipClanarine.vrijemeTrajanja == 1) {
                            trajanje = 'Jedan Mjesec';
                          } else if (tipClanarine.vrijemeTrajanja == 3) {
                            trajanje = 'Tri Mjeseca';
                          } else if (tipClanarine.vrijemeTrajanja == 6) {
                            trajanje = 'Šest Mjeseci';
                          } else if (tipClanarine.vrijemeTrajanja == 12) {
                            trajanje = 'Godinu dana';
                          } else {
                            trajanje = 'N/A';
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                trajanje,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Cijena: ${tipClanarine.cijena} KM',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () => _navigateToPayPalScreen(
                                        tipClanarine.tipClanarineId!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
