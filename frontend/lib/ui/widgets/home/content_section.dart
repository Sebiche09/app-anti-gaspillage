import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/basket.dart';
import '../../../providers/basket_provider.dart';
import '../common/empty_state_view.dart';
import '../common/category_selector.dart';
import '../common/error_view.dart';
import '../basket/basket_card.dart';

class ContentSection extends StatelessWidget {
  final String activeCategory;
  final Function(String) onCategorySelected;
  final BasketListConfig config;

  const ContentSection({
    Key? key,
    required this.activeCategory,
    required this.onCategorySelected,
    this.config = const BasketListConfig(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          CategorySelector(
            initialCategory: activeCategory,
            categories: config.categories,
            onCategorySelected: onCategorySelected,
          ),
          Expanded(
            child: _buildBasketsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketsList() {
    return Consumer<BasketsProvider>(
      builder: (context, basketProvider, _) {
        if (basketProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (basketProvider.error.isNotEmpty) {
          return ErrorView(
            error: basketProvider.error,
            onRetry: () => basketProvider.fetchBaskets(),
          );
        }

        final filteredBaskets = basketProvider.getBasketsByCategory(activeCategory);

        if (filteredBaskets.isEmpty) {
          return const EmptyStateView(message: 'Aucun magasin trouvé');
        }

        return BasketListView(
          baskets: filteredBaskets,
          padding: config.padding,
        );
      },
    );
  }
}

// Classe de configuration pour personnaliser la liste des paniers
class BasketListConfig {
  final List<String> categories;
  final EdgeInsets padding;

  const BasketListConfig({
    this.categories = const ['Tout', 'Boulangerie', 'Epicerie', 'végétarien', 'Sushi', 'Favoris'],
    this.padding = const EdgeInsets.all(16),
  });
}
class BasketListView extends StatelessWidget {
  final List<Basket> baskets;
  final EdgeInsets padding;

  const BasketListView({
    Key? key, 
    required this.baskets, 
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: baskets.length,
      itemBuilder: (context, index) {
        final basket = baskets[index];
        return BasketCard(
          basket: basket,
          onTap: () {
            Navigator.pushNamed(context, '/basket_detail', arguments: basket);
          },
        );
      },
    );
  }
}


