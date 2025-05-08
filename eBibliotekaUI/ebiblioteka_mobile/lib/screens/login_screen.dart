import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Stateful widget for the Login screen.
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

// State class for the Login widget.
class _LoginState extends State<Login> {
  // Map to store user data (if needed in the future).
  Map userData = {};

  // Key to manage the form state.
  final _formkey = GlobalKey<FormState>();

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
                        // Email input field.
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                                validator: MultiValidator([
                                  RequiredValidator(

                                      // Validation for required field.
                                      errorText: 'Unesite email adresu'),
                                  EmailValidator(

                                      // Validation for email format.
                                      errorText: 'Pogrešan format email-a'),
                                ]),
                                decoration: InputDecoration(

                                    // Placeholder text.
                                    hintText: 'Email',

                                    // Label for the field.
                                    labelText: 'Email',
                                    prefixIcon: Icon(
                                      // Email icon.
                                      Icons.email,
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
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            validator: MultiValidator([
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
                            ]),
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
                                  if (_formkey.currentState!.validate()) {
                                    // Prints a message if the form is valid.
                                    print('form submitted');
                                  }
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
