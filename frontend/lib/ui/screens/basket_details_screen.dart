import 'package:flutter/material.dart';
import '../../models/basket.dart';


class BasketDetailsScreen extends StatefulWidget {
  final Basket basket;

  const BasketDetailsScreen({Key? key, required this.basket}) : super(key: key);

  @override
  _BasketDetailsScreenState createState() => _BasketDetailsScreenState();
}

class _BasketDetailsScreenState extends State<BasketDetailsScreen> {
  String _activeTab = 'Ingredients';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Image du panier
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/bakery1.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              // Boutons de navigation, partage et favoris
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Boutons partage et favoris
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Logo circulaire du magasin
              Positioned(
                left: 20,
                bottom: -30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1D100),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "DB",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Informations du magasin et du panier
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 30.0,
                  ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Nom du magasin et adresse
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.basket.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.basket.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Prix
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${widget.basket.originalPrice.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${widget.basket.discountPrice.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8D23),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        height: 1,  
                        width: double.infinity,
                        color: Colors.grey.withOpacity(0.3),  
                      ),

                      const SizedBox(height: 16),
                      // Titre et description du panier

                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.shopping_basket,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Basket Title',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ),


                      const SizedBox(height: 20),

                      // Onglets d'informations
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabButton('Ingredients'),
                            const SizedBox(width: 10),
                            _buildTabButton('Allergies'),
                            const SizedBox(width: 10),
                            _buildTabButton('Images'),
                            const SizedBox(width: 10),
                            _buildTabButton('Timeline'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contenu basé sur l'onglet sélectionné
                      if (_activeTab == 'Ingredients')
                        _buildIngredientsSection(),
                      if (_activeTab == 'Allergies')
                        _buildAllergiesSection(),
                      if (_activeTab == 'Images')
                        _buildImagesSection(),
                      if (_activeTab == 'Timeline')
                        _buildTimelineSection(),

                      const SizedBox(height: 20),

                      // Carte de localisation
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF8D23),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '500m away',
                                style: TextStyle(
                                  color: Color(0xFFFF8D23),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton d'achat
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Action d'achat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4929),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Buy Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    bool isActive = _activeTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8D23) : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: List.generate(
          5,
              (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(

                  'Ingredient Name',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
                const Text(
                  '5',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return const Center(
      child: Text('Allergies Information will be shown here'),
    );
  }

  Widget _buildImagesSection() {
    return const Center(
      child: Text('Images will be shown here'),
    );
  }

  Widget _buildTimelineSection() {
    return const Center(
      child: Text('Timeline information will be shown here'),
    );
  }
}
