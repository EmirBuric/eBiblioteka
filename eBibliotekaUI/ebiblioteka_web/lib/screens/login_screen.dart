import 'package:ebiblioteka_web/providers/auth_provider.dart';
import 'package:ebiblioteka_web/providers/korisnik_provider.dart';
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

      if (!KorisnikProvider.isAdmin()) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Pristup zabranjen"),
            content: const Text(
                "Samo administratori imaju pristup ovoj aplikaciji."),
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

      if (context.mounted) {}
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
        title: const Text('eBiblioteka'),
        backgroundColor: const Color.fromARGB(255, 101, 85, 143),
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
                  'assets/Logo.png',
                  height: 30,
                  width: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.2,
                              vertical: 25.0,
                            ),
                            child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    hintText: 'Korisničko ime',
                                    labelText: 'Korisničko ime',
                                    prefixIcon: Icon(
                                      Icons.person,
                                    ),
                                    errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(9.0)))))),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.2,
                            vertical: 12.0,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Lozinka',
                              labelText: 'Lozinka',
                              prefixIcon: Icon(
                                Icons.key,
                                color: Color.fromARGB(255, 101, 85, 143),
                              ),
                              errorStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9.0))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.2,
                            vertical: 25.0,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () => _handleLogin(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 101, 85, 143),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Prijavi se',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                )),
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
