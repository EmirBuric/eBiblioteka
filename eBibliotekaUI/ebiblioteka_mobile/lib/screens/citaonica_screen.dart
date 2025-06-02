import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/citaonica.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/citaonica_provider.dart';
import 'package:ebiblioteka_mobile/screens/termin_list_screen.dart';
import 'package:flutter/material.dart';

class CitaonicaScreen extends StatefulWidget {
  const CitaonicaScreen({Key? key}) : super(key: key);

  @override
  State<CitaonicaScreen> createState() => _CitaonicaScreenState();
}

class _CitaonicaScreenState extends State<CitaonicaScreen> {
  final CitaonicaProvider _citaonicaProvider = CitaonicaProvider();
  List<Citaonica> _citaonice = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCitaonice();
  }

  Future<void> _loadCitaonice() async {
    try {
      var result = await _citaonicaProvider.get();
      setState(() {
        _citaonice = result.result;
        _isLoading = false;
      });
    } catch (e) {
      print('Greška prilikom učitavanja čitaonica: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 1, // Odabrani indeks za čitaonicu u navigaciji
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Čitaonica'),
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMojiTerminiCard(),
                  ),
                  Expanded(
                    child: _buildCitaoniceList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Citaonica.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
        ),
      ),
      child: const Center(
        child: Text(
          'Dostupni termini',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMojiTerminiCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Provjera da li je korisnik prijavljen
          if (AuthProvider.trenutniKorisnikId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Morate biti prijavljeni da biste vidjeli svoje termine'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // Navigacija na ekran termina korisnika
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TerminListScreen(
                korisnikId: AuthProvider.trenutniKorisnikId!,
                naslov: 'Moji termini',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.calendar_today, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Moji termini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitaoniceList() {
    if (_citaonice.isEmpty) {
      return const Center(
        child: Text('Nema dostupnih čitaonica'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _citaonice.length,
      itemBuilder: (context, index) {
        final citaonica = _citaonice[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.book, color: Colors.grey),
            ),
            title: Text(
              citaonica.naziv ?? 'Nepoznata čitaonica',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              // Navigacija na ekran termina za odabranu čitaonicu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TerminListScreen(
                    citaonicaId: citaonica.citaonicaId ?? 0,
                    citaonicaNaziv: citaonica.naziv ?? 'Čitaonica',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
