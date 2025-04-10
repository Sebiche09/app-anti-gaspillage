import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/common/header.dart';
import '../../constants/app_colors.dart';
import '../../providers/basket_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Consumer<BasketsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Header(
                  title: 'Explore',
                  searchString: 'Chercher un lieu...',
                  onSearch: (query) {
                    provider.searchBaskets(query);
                  },
                  isCentered: true,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
