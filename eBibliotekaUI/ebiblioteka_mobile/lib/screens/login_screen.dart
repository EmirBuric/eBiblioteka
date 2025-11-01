import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_provider.dart';
import 'package:ebiblioteka_mobile/screens/pocetna_screen.dart';
import 'package:ebiblioteka_mobile/screens/registracija_screen.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> _handleLogin(BuildContext context) async {
    AuthProvider.username = _usernameController.text;
    AuthProvider.password = _passwordController.text;

    try {
      final korisnikProvider = KorisnikProvider();

      await korisnikProvider.getTrenutniKorisnikUloga();

      await korisnikProvider.getTrenutniKorisnikId();

      //KnjigaProvider provider = KnjigaProvider();
      //await provider.get();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PocetnaScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('eBiblioteka'),
        backgroundColor: Color.fromARGB(255, 101, 85, 143),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.blueGrey)),
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 30,
                  width: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'Korisničko ime',
                                  labelText: 'Korisničko ime',
                                  prefixIcon: Icon(Icons.person),
                                ))),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Lozinka',
                              labelText: 'Lozinka',
                              prefixIcon: Icon(
                                Icons.key,
                                color: Color.fromARGB(255, 101, 85, 143),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                            child: ElevatedButton(
                                child: Text(
                                  'Prijavi se',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                onPressed: () {
                                  _handleLogin(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 101, 85, 143),
                                  foregroundColor: Colors.white,
                                )),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Nemate račun?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistracijaScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Registrujte se'),
                              ),
                            ],
                          ),
                        ),
                      ]),
                )),
          ),
        ]),
      ),
    );
  }
}
