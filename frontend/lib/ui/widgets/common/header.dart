import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class Header extends StatefulWidget {
  final String title;
  final String searchString;
  final Function(String)? onSearch;
  final bool isCentered;

  const Header({
    Key? key,
    required this.title,
    required this.searchString,
    this.onSearch,
    this.isCentered = false,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              Expanded(
                child: Container(
                  alignment: widget.isCentered ? Alignment.center : Alignment.centerLeft,
                  margin: widget.isCentered ? EdgeInsets.zero : const EdgeInsets.only(left: 16),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barre de recherche
          Row(
            children: [
              // Champ de recherche
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: widget.searchString,
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onSubmitted: widget.onSearch,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton de filtre
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.tune,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),


          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
