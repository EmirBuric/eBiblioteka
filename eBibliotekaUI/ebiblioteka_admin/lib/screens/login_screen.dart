import 'package:ebiblioteka_admin/screens/pocetna_screen.dart';
import 'package:flutter/material.dart';
//import 'package:form_field_validator/form_field_validator.dart';
import '../providers/knjiga_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/korisnik_provider.dart';
import 'knjige_list_screen.dart';

// Stateful widget for the Login screen.
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

      KnjigaProvider provider = KnjigaProvider();
      await provider.get();

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PocetnaScreen()),
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
        // Title of the AppBar.
        title: const Text('eBiblioteka'),

        // Background color of the AppBar.
        backgroundColor: const Color.fromARGB(255, 101, 85, 143),

        // Text color of the AppBar.
        foregroundColor: Colors.white,

        // Centers the title in the AppBar.
        centerTitle: true,
      ),

      // Allows scrolling for smaller screens.
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          // Logo section at the top.
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(

                    // Rounded corners.
                    borderRadius: BorderRadius.circular(40),

                    // Border styling.
                    border: Border.all(color: Colors.blueGrey)),
                child: Image.asset(
                  // Path to the logo image.
                  'assets/Logo.png',
                  height: 30,
                  width: 20,
                ),
              ),
            ),
          ),

          // Form section for user input.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  // Associates the form with the key.
                  key: _formkey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Email input field.
                        Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.2,
                              vertical: 25.0,
                            ),
                            child: TextFormField(
                                controller: _usernameController,
                                /*validator: MultiValidator([
                                  RequiredValidator(

                                      // Validation for required field.
                                      errorText: 'Unesite email adresu'),
                                  EmailValidator(

                                      // Validation for email format.
                                      errorText: 'Pogrešan format email-a'),
                                ]).call,*/
                                decoration: const InputDecoration(

                                    // Placeholder text.
                                    hintText: 'Username',

                                    // Label for the field.
                                    labelText: 'Username',
                                    prefixIcon: Icon(
                                      Icons.person,
                                    ),

                                    // Error message styling.
                                    errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.all(

                                            // Rounded border.
                                            Radius.circular(9.0)))))),

                        // Password input field.
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.2,
                            vertical: 12.0,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            /* validator: MultiValidator([
                              RequiredValidator(

                                  // Validation for required field.
                                  errorText: 'Unesite lozinku'),
                              MinLengthValidator(8,

                                  // Minimum length validation.
                                  errorText:
                                      'Lozinka mora imati barem 8 karaktera'),
                              PatternValidator(r'(?=.*?[#!@$%^&*-])',

                                  // Special character validation.
                                  errorText:
                                      'Lozinka mora imati barem jedan poseban karakter')
                            ]).call,*/
                            decoration: const InputDecoration(
                              // Placeholder text.
                              hintText: 'Lozinka',

                              // Label for the field.
                              labelText: 'Lozinka',
                              prefixIcon: Icon(
                                // Key icon for password.
                                Icons.key,
                                color: Color.fromARGB(255, 101, 85, 143),
                              ),

                              // Error message styling.
                              errorStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),

                                  // Rounded border.
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9.0))),
                            ),
                          ),
                        ),

                        // Login button.
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.2,
                            vertical: 25.0,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,

                            // Button height.
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () => _handleLogin(context),
                                style: ElevatedButton.styleFrom(
                                  // Button background color.
                                  backgroundColor:
                                      const Color.fromARGB(255, 101, 85, 143),

                                  // Button text color.
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Prijavi se',
                                  style: TextStyle(

                                      // Button text styling.
                                      color: Colors.white,
                                      fontSize: 22),
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
