import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/store.dart';
import '../../../models/merchant_basket.dart'; 
import '../../../providers/store_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../widgets/merchant/store_header.dart';
import '../../../providers/error_notifier.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  bool _basketsLoaded = false;

  void _showAddBasketDialog(BuildContext context, Store store) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final originalPriceController = TextEditingController();
    final discountController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un panier"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nom du panier"),
                    validator: (v) => v == null || v.isEmpty ? "Nom requis" : null,
                  ),
                  TextFormField(
                    controller: originalPriceController,
                    decoration: const InputDecoration(labelText: "Prix d'origine"),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? "Prix requis" : null,
                  ),
                  TextFormField(
                    controller: discountController,
                    decoration: const InputDecoration(labelText: "Pourcentage de réduction"),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? "Réduction requise" : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: "Catégorie"),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Quantité"),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final quantity = int.tryParse(v);
                        if (quantity == null || quantity <= 0) {
                          return "Quantité invalide";
                        }
                      }
                      return null;
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await Provider.of<BasketsProvider>(context, listen: false).addBasket(
                      name: nameController.text,
                      originalPrice: double.tryParse(originalPriceController.text) ?? 0,
                      discountPercentage: double.tryParse(discountController.text) ?? 0,
                      storeId: store.id,
                      quantity:  int.tryParse(quantityController.text) ?? 1,
                      category: categoryController.text,
                      description: descriptionController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Panier ajouté avec succès")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur: $e")),
                    );
                  }
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorNotifier = Provider.of<ErrorNotifier>(context);
    final error = errorNotifier.errorMessage ?? '';

    return Consumer<StoreProvider>(
      builder: (context, storeProvider, _) {
        final stores = storeProvider.stores;
        final selectedStore = storeProvider.selectedStore;

        if (selectedStore != null && !_basketsLoaded) {
          // Charger les paniers pour le magasin sélectionné
          Provider.of<BasketsProvider>(context, listen: false).fetchBasketsForStore(selectedStore.id);
          _basketsLoaded = true;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6EDE3),
          floatingActionButton: selectedStore == null
              ? null
              : FloatingActionButton(
                  onPressed: () => _showAddBasketDialog(context, selectedStore),
                  backgroundColor: Colors.green[900],
                  child: const Icon(Icons.add),
                  tooltip: "Ajouter un panier",
                ),
          body: Column(
            children: [
              StoreHeader(
                stores: stores,
                selected: selectedStore,
                onChanged: (store) {
                  storeProvider.selectStore(store);
                  setState(() {
                    _basketsLoaded = false;
                  });
                },
              ),
              Expanded(
                child: selectedStore == null
                    ? Center(
                        child: Text(
                          "Sélectionne un magasin pour voir ses paniers.",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      )
                    : Selector<BasketsProvider, List<MerchantBasket>>(
                        selector: (_, basketsProvider) => basketsProvider.merchantBaskets,
                        builder: (context, merchantBaskets, child) {
                          final basketsProvider = Provider.of<BasketsProvider>(context, listen: false);

                          if (basketsProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (error.isNotEmpty) {
                            return Center(
                              child: Text(
                                "Erreur: $error",
                                style: TextStyle(color: Colors.red[600], fontSize: 16),
                              ),
                            );
                          }

                          if (merchantBaskets.isEmpty) {
                            return Center(
                              child: Text(
                                "Aucun panier pour ce magasin.",
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: merchantBaskets.length,
                            itemBuilder: (context, index) {
                              final basket = merchantBaskets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(basket.name),
                                  subtitle: Text(
                                    'Prix: ${basket.originalPrice}€ • Réduction: ${basket.discountPercentage}%\n'
                                    'Quantité: ${basket.quantity} • ${basket.description}',
                                  ),
                                  trailing: Text(
                                    basket.category,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}