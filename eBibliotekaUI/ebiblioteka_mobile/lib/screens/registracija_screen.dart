import 'package:ebiblioteka_mobile/models/uloga.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_provider.dart';
import 'package:ebiblioteka_mobile/providers/uloga_provider.dart';
import 'package:ebiblioteka_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegistracijaScreen extends StatefulWidget {
  const RegistracijaScreen({super.key});

  @override
  State<RegistracijaScreen> createState() => _RegistracijaScreenState();
}

class _RegistracijaScreenState extends State<RegistracijaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _korisnickoImeController =
      TextEditingController();
  final TextEditingController _lozinkaController = TextEditingController();
  final TextEditingController _lozinkaPotvrda = TextEditingController();

  bool _isLoading = false;
  List<Uloga> _uloge = [];
  final KorisnikProvider _korisnikProvider = KorisnikProvider();
  final UlogaProvider _ulogaProvider = UlogaProvider();

  @override
  void initState() {
    super.initState();
    _loadUloge();
  }

  Future<void> _loadUloge() async {
    try {
      var result = await _ulogaProvider.get(filter: {'nazivGTE': 'Korisnik'});
      setState(() {
        _uloge = result.result;
      });
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

  Future<void> _handleRegistracija() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<int> ulogeIds = _uloge
            .where((uloga) => uloga.naziv?.contains('Korisnik') ?? false)
            .map((uloga) => uloga.ulogaId!)
            .toList();

        var request = {
          'ime': _imeController.text,
          'prezime': _prezimeController.text,
          'email': _emailController.text,
          'telefon': _telefonController.text,
          'korisnickoIme': _korisnickoImeController.text,
          'lozinka': _lozinkaController.text,
          'lozinkaPotvrda': _lozinkaPotvrda.text,
          'uloge': ulogeIds,
        };

        await _korisnikProvider.insert(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uspješno ste se registrovali')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eBiblioteka'),
        backgroundColor: const Color.fromARGB(255, 101, 85, 143),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      height: 30,
                      width: 20,
                    ),
                  ),
                ),
              ),
              const Text(
                'Registracija',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 101, 85, 143),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _imeController,
                      decoration: const InputDecoration(
                        labelText: 'Ime',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        if (value.length < 2) {
                          return 'Ime korisnika ne može biti kraće od 2 karaktera';
                        }
                        if (value.length > 50) {
                          return 'Ime korisnika ne može biti duže od 50 karaktera';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _prezimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prezime',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        if (value.length < 2) {
                          return 'Prezime korisnika ne može biti kraće od 2 karaktera';
                        }
                        if (value.length > 50) {
                          return 'Prezime korisnika ne može biti duže od 50 karaktera';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Email mora biti u validnom formatu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '+387 6X XXX XXX',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        final phoneRegex = RegExp(
                            r'^(?:\+387)[\s-]?[6][0-9][\s-]?[0-9]{3}[\s-]?[0-9]{3}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Telefon mora biti u formatu +3876XXXXXXXX';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _korisnickoImeController,
                      decoration: const InputDecoration(
                        labelText: 'Korisničko ime',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        if (value.length < 2) {
                          return 'Korisničko ime ne može biti kraće od 2 karaktera';
                        }
                        if (value.length > 50) {
                          return 'Korisničko ime ne može biti duže od 50 karaktera';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lozinkaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Lozinka',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lozinkaPotvrda,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Potvrda lozinke',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ovo polje ne može biti prazno';
                        }
                        if (value != _lozinkaController.text) {
                          return 'Lozinke nisu iste';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegistracija,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 101, 85, 143),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Registruj se',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: const Text('Već imate račun? Prijavite se'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
