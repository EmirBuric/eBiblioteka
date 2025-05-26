import 'package:ebiblioteka_mobile/screens/pocetna_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({Key? key}) : super(key: key);

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  // Define your screens
  final List<Widget> _screens = [const PocetnaScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PocetnaScreen()),
        );
        break;
      case 1:
        //Navigator.of(context).pushReplacement(
        //  MaterialPageRoute(builder: (context) => const KnjigeListScreen()),
        //);
        break;
      case 2:
        //Navigator.of(context).pushReplacement(
        // MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        //);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Početna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Čitaonica',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'Članarine',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            _onItemTapped(index);
            _navigateToScreen(index);
          },
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}
