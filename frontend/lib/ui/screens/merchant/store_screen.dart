import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/store.dart';
import '../../../providers/store_provider.dart';
import 'add_store_screen.dart';
  import '../../widgets/merchant/store_header.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  void _showEditDialog(BuildContext context, StoreProvider provider, Store store) {
    final nameController = TextEditingController(text: store.name);
    final addressController = TextEditingController(text: store.address);
    final cityController = TextEditingController(text: store.city);
    final postalCodeController = TextEditingController(text: store.postalCode); 
    final phoneController = TextEditingController(text: store.phoneNumber);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le magasin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Adresse")),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: "Ville")),
            TextField(controller: postalCodeController, decoration: const InputDecoration(labelText: "Code postal")), 
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Téléphone")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStore(
                Store(
                  id: store.id,
                  name: nameController.text,
                  address: addressController.text,
                  city: cityController.text,
                  postalCode: postalCodeController.text, 
                  phoneNumber: phoneController.text,
                  categoryId: store.categoryId, 
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Consumer<StoreProvider>(
    builder: (context, provider, _) {
      final stores = provider.stores;
      final selected = provider.selectedStore;

      return Scaffold(
        backgroundColor: const Color(0xFFF6EDE3),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStoreScreen()),
            );
          },
          backgroundColor: Colors.grey[900],
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: "Ajouter un magasin",
        ),
        body: Column(
          children: [
            // Le header vert avec le dropdown
            StoreHeader(
              stores: stores,
              selected: selected,
              onChanged: provider.selectStore,
            ),
            // Le reste du contenu (expand pour scroller si besoin)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    if (selected != null) ...[
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selected.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(selected.address, style: TextStyle(color: Colors.grey[800]))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_city, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text(selected.city, style: TextStyle(color: Colors.grey[800])),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.markunread_mailbox, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text(selected.postalCode, style: TextStyle(color: Colors.grey[800])),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text(selected.phoneNumber, style: TextStyle(color: Colors.grey[800])),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        backgroundColor: Colors.grey[900],
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () => _showEditDialog(context, provider, selected),
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Modifier"),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        backgroundColor: Colors.red[400],
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () {
                                        provider.deleteStore(selected.id);
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text("Supprimer"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          "Aucun magasin sélectionné.",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}