import 'package:flutter/material.dart';
import '../../../models/store.dart';
import '../../../constants/app_colors.dart';

class StoreHeader extends StatelessWidget {
  final List<Store> stores;
  final Store? selected;
  final ValueChanged<Store?> onChanged;

  const StoreHeader({
    Key? key,
    required this.stores,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Container(
    height: 56, 
    color: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Center(
        child: Container(
        height: 40, 
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
        ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
            children: [
            Icon(Icons.store),
            const SizedBox(width: 12),
            Expanded(
                child: DropdownButtonHideUnderline(
                child: DropdownButton<Store>(
                    value: selected,
                    isExpanded: true,
                    hint: const Text("Sélectionner un magasin"),
                    items: stores.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    )).toList(),
                    onChanged: onChanged,
                ),
                ),
              ),
            ],
        ),
      ),
    ),
  );
}
}