import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../models/restaurantCategory.dart'; 
import '../../../providers/restaurant_provider.dart';
import 'basket_configuration_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  int? _selectedCategoryId;
  bool _isLoading = false;
  List<RestaurantCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    print("Initialisation de RestaurantScreen");
    // Ne pas appeler Provider dans initState directement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    print("Début du chargement des catégories");
    setState(() => _isLoading = true);
    try {
      final categories = await Provider.of<RestaurantProvider>(context, listen: false).getCategories();
      print("Catégories chargées: ${categories.length}");
      for (var cat in categories) {
        print("Catégorie: ${cat.id} - ${cat.name}");
      }
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des catégories: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des catégories: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final restaurantId = await Provider.of<RestaurantProvider>(context, listen: false).createRestaurant(
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        phoneNumber: _phoneNumberController.text,
        categoryId: _selectedCategoryId!,
      );

      setState(() => _isLoading = false);
      print("✅ Restaurant ID obtenu : $restaurantId");
      if (restaurantId != null) {
        print("✅ Restaurant ID obtenu 2 : $restaurantId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant créé avec succès')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BasketConfigurationScreen(restaurantId: restaurantId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création du restaurant')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    print("Construction du widget RestaurantScreen, isLoading: $_isLoading, catégories: ${_categories.length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un restaurant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                    const SizedBox(height: 16),
                    _buildCityField(),
                    const SizedBox(height: 16),
                    _buildPostalCodeField(),
                    const SizedBox(height: 16),
                    _buildPhoneNumberField(),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(_categories),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du restaurant',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Veuillez remplir les informations ci-dessous pour ajouter votre restaurant.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nom du restaurant',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.restaurant),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le nom du restaurant';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Adresse',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer l\'adresse du restaurant';
        }
        return null;
      },
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'Ville',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.location_city),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer la ville';
        }
        return null;
      },
    );
  }

  Widget _buildPostalCodeField() {
    return TextFormField(
      controller: _postalCodeController,
      decoration: InputDecoration(
        labelText: 'Code postal',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.markunread_mailbox),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le code postal';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phoneNumberController,
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildCategoryDropdown(List<RestaurantCategory> categories) {
    print("Construction du dropdown avec ${categories.length} catégories");
    
    if (categories.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Catégorie',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.category),
          errorText: 'Aucune catégorie disponible',
        ),
        child: const Text('Chargement des catégories...'),
      );
    }
    
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.category),
      ),
      hint: const Text('Sélectionner une catégorie'), 
      items: categories.map((category) {
        print("Création d'un item pour ${category.name}");
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        print("Catégorie sélectionnée: $value");
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _isLoading ? null : _submitForm,
      child: _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
            'Ajouter le restaurant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
    );
  }
}
