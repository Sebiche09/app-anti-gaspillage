import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CategorySelector extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final String initialCategory;
  final List<String> categories;

  const CategorySelector({
    Key? key,
    required this.onCategorySelected,
    this.initialCategory = 'Tout',
    required this.categories,
  }) : super(key: key);

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: widget.categories.map((category) =>
                _buildCategoryChip(
                    category,
                    category == _selectedCategory,
                        () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      if (widget.onCategorySelected != null) {
                        widget.onCategorySelected!(category);
                      }
                    }
                )
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8D23) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8D23) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}