import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/basket_provider.dart';
import '../widgets/home/content_section.dart';
import '../widgets/home/home_header.dart';
import '../../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeCategory = 'Tout';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BasketsProvider>(context, listen: false).fetchBaskets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: ContentSection(
                  activeCategory: _activeCategory,
                  onCategorySelected: (category) {
                    setState(() => _activeCategory = category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
