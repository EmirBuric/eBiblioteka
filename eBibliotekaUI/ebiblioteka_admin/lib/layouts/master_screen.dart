import 'package:flutter/material.dart';
import '../screens/knjige_list_screen.dart';

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
      // AppBar with inline navigation items
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 101, 85, 143),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("eBiblioteka",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 30),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => KnjigeListScreen()));
              },
              child:
                  const Text("Knjige", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Recenzije
              },
              child: const Text("Recenzije",
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Korisnici
              },
              child: const Text("Korisnici",
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Rezervacije
              },
              child: const Text("Rezervacije",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
