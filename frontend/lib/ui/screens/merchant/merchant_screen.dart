import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/store_provider.dart'; // ← AJOUT
import '../../../constants/app_colors.dart';
import 'store_screen.dart';
import 'basket_screen.dart';
import 'stats_screen.dart';
import 'more_screen.dart';

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StoreScreen(),
    BasketScreen(),
    StatsScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      storeProvider.fetchStores();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.border,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Magasin'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Plus'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}