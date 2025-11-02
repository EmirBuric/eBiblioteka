import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/rezervacija.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/rezervacija_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:flutter/material.dart';

class HistorijaRezervacijaScreen extends StatefulWidget {
  const HistorijaRezervacijaScreen({Key? key}) : super(key: key);

  @override
  State<HistorijaRezervacijaScreen> createState() =>
      _HistorijaRezervacijaScreenState();
}

class _HistorijaRezervacijaScreenState
    extends State<HistorijaRezervacijaScreen> {
  final RezervacijaProvider _rezervacijaProvider = RezervacijaProvider();
  List<Rezervacija> _rezervacije = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRezervacije();
  }

  Future<void> _loadRezervacije() async {
    if (AuthProvider.trenutniKorisnikId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var filter = {
        'KorisnikId': AuthProvider.trenutniKorisnikId.toString(),
      };
      var result = await _rezervacijaProvider.get(filter: filter);

      setState(() {
        _rezervacije = result.result;
        _isLoading = false;
      });
    } catch (e) {
      print('Greška prilikom učitavanja rezervacija: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(Rezervacija rezervacija) {
    final danas = DateTime.now();

    // Ako je vraćena (ima datum vraćanja)
    if (rezervacija.datumVracanja != null &&
        rezervacija.datumVracanja!.isBefore(danas)) {
      return Colors.green;
    }

    // Ako je odobrena i nije istekla
    if (rezervacija.odobrena == true) {
      return Colors.blue;
    }

    // Neodobrena ili čeka odobrenje
    return Colors.grey;
  }

  String _getStatusText(Rezervacija rezervacija) {
    final danas = DateTime.now();

    // Ako je vraćena (ima datum vraćanja u prošlosti)
    if (rezervacija.datumVracanja != null &&
        rezervacija.datumVracanja!.isBefore(danas)) {
      return 'Vraćeno';
    }

    // Ako je odobrena i datum vraćanja je u budućnosti ili nije vraćena
    if (rezervacija.odobrena == true) {
      if (rezervacija.datumVracanja != null &&
          rezervacija.datumVracanja!.isAfter(danas)) {
        return 'Aktivna';
      }
      return 'Aktivna';
    }

    // Čeka odobrenje
    if (rezervacija.odobrena == false) {
      return 'Čeka odobrenje';
    }

    return 'Neaktivna';
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historija rezervacija'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _rezervacije.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nemate historiju rezervacija',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRezervacije,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rezervacije.length,
                      itemBuilder: (context, index) {
                        final rezervacija = _rezervacije[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rezervacija.knjiga?.naziv ??
                                            'Nepoznata knjiga',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(rezervacija),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getStatusText(rezervacija),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Datum rezervacije',
                                  rezervacija.datumRezervacije != null
                                      ? formatDateToLocal(
                                          rezervacija.datumRezervacije!)
                                      : 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.event_busy,
                                  'Datum vraćanja',
                                  rezervacija.datumVracanja != null
                                      ? formatDateToLocal(
                                          rezervacija.datumVracanja!)
                                      : 'N/A',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
