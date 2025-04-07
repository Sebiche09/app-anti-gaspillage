import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/basket_provider.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF8D23),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Commandes'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Plus'),
      ],
      onTap: (index) => _handleNavTap(context, index),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/explore');
    } else if (index == 0) {
      Provider.of<BasketsProvider>(context, listen: false).fetchBaskets();
    }
  }
}