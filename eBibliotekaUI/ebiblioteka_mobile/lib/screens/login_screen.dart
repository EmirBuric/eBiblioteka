import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
//import 'package:form_field_validator/form_field_validator.dart';

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
          MaterialPageRoute(builder: (context) => const MasterScreen()),
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
        // Title of the AppBar.
        title: Text('eBiblioteka'),

        // Background color of the AppBar.
        backgroundColor: Color.fromARGB(255, 101, 85, 143),

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
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  // Associates the form with the key.
                  key: _formkey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                                controller: _usernameController,
                                /*validator: MultiValidator([
                                  RequiredValidator(

                                      // Validation for required field.
                                      errorText: 'Unesite email adresu'),
                                  EmailValidator(

                                      // Validation for email format.
                                      errorText: 'Pogrešan format email-a'),
                                ]),*/
                                decoration: InputDecoration(
                                  // Placeholder text.
                                  hintText: 'Korisničko ime',

                                  // Label for the field.
                                  labelText: 'Korisničko ime',
                                  prefixIcon: Icon(Icons.person),

                                  // Error message styling.
                                  /*errorStyle: TextStyle(fontSize: 18.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.all(

                                            // Rounded border.
                                            Radius.circular(9.0)))*/
                                ))),

                        // Password input field.
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            controller: _passwordController,
                            /*validator: MultiValidator([
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
                            ]),*/
                            decoration: InputDecoration(
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
                              /*errorStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),

                                  // Rounded border.
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9.0))),*/
                            ),
                          ),
                        ),

                        // Login button.
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                            child: ElevatedButton(
                                child: Text(
                                  'Prijavi se',
                                  style: TextStyle(

                                      // Button text styling.
                                      color: Colors.white,
                                      fontSize: 22),
                                ),
                                onPressed: () {
                                  /*if (_formkey.currentState!.validate()) {
                                    // Prints a message if the form is valid.
                                    print('form submitted');
                                  }*/
                                  _handleLogin(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  // Button background color.
                                  backgroundColor:
                                      Color.fromARGB(255, 101, 85, 143),

                                  // Button text color.
                                  foregroundColor: Colors.white,
                                )),

                            // Button width.
                            width: MediaQuery.of(context).size.width,

                            // Button height.
                            height: 50,
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
