import 'package:ebiblioteka_web/screens/autor_list_screen.dart';
import 'package:ebiblioteka_web/screens/knjige_list_screen.dart';
import 'package:ebiblioteka_web/screens/pocetna_screen.dart';
import 'package:ebiblioteka_web/screens/recenzija_list_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  final String title;
  final Widget child;

  MasterScreen(this.title, this.child, {super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 101, 85, 143),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildNavButton(
                "eBiblioteka", PocetnaScreen(), widget.title == "Početna",
                isLogo: true),
            const SizedBox(width: 30),
            _buildNavButton(
                "Knjige", KnjigeListScreen(), widget.title == "Knjige"),
            _buildNavButton(
                "Autori", AutorListScreen(), widget.title == "Autori"),
            _buildNavButton("Recenzije", RecenzijaListScreen(),
                widget.title == "Recenzije"),
            _buildNavButton("Korisnici", null, widget.title == "Korisnici"),
            _buildNavButton("Rezervacije", null, widget.title == "Rezervacije"),
            _buildNavButton("Izvještaj", null, widget.title == "Izvještaj"),
          ],
        ),
      ),
      body: widget.child,
    );
  }

  Widget _buildNavButton(String title, Widget? destination, bool isActive,
      {bool isLogo = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.black.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextButton(
        onPressed: () {
          if (!isActive) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => destination!),
            );
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontWeight:
                isLogo || isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
