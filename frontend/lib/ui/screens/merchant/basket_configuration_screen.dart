import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/basket_configuration_provider.dart';
import '../../../constants/app_colors.dart';
import 'merchant_screen.dart';

class BasketConfigurationScreen extends StatefulWidget {
  final int restaurantId;

  const BasketConfigurationScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<BasketConfigurationScreen> createState() => _BasketConfigurationScreenState();
}

class _BasketConfigurationScreenState extends State<BasketConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, bool> _daysSelected = {}; // 1=lundi, 7=dimanche
  final Map<int, TextEditingController> _basketControllers = {};
  final TextEditingController _priceController = TextEditingController();

  final List<double> _priceOptions = [6.99, 7.99, 10.99];
  double? _selectedPrice;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 7; i++) {
      _daysSelected[i] = false;
      _basketControllers[i] = TextEditingController();
      _basketControllers[i]!.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    for (var controller in _basketControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get totalBaskets {
    double sum = 0;
    _daysSelected.forEach((day, selected) {
      if (selected) {
        final text = _basketControllers[day]!.text;
        final value = int.tryParse(text) ?? 0;
        sum += value;
      }
    });
    return sum;
  }

  double get monthlyGain {
    final price = _selectedPrice ?? 0;
    final commission = 0.3;
    return price * totalBaskets * 4 * (1 - commission);
  }

  Future<void> _submitConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    final price = _selectedPrice;
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prix invalide")),
      );
      return;
    }

    final availabilities = _daysSelected.entries
        .where((e) => e.value)
        .map((e) => {
              "day_of_week": e.key,
              "number_of_baskets": int.tryParse(_basketControllers[e.key]!.text) ?? 0
            })
        .toList();

    if (availabilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez configurer au moins un jour")),
      );
      return;
    }

    final provider = Provider.of<BasketConfigurationProvider>(context, listen: false);

    final success = await provider.submitConfiguration(
      restaurantId: widget.restaurantId,
      price: price,
      dailyAvailabilities: availabilities,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuration envoyée avec succès")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MerchantScreen()),
        (route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final isLoading = context.watch<BasketConfigurationProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration panier"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text("Vidéo explicative (à venir)"),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _daysSelected[day],
                            onChanged: (val) {
                              setState(() {
                                _daysSelected[day] = val!;
                              });
                            },
                          ),
                          Text(dayNames[index]),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: _basketControllers[day],
                          decoration: const InputDecoration(
                            hintText: "Qté",
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          enabled: _daysSelected[day]!,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (_daysSelected[day]! &&
                                (value == null || value.isEmpty || int.tryParse(value) == null)) {
                              return '';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prix du panier moyen (€) :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _priceOptions.map((price) {
                      final isSelected = _selectedPrice == price;
                      return ChoiceChip(
                        label: Text("€${price.toStringAsFixed(2)}"),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        onSelected: (_) {
                          setState(() {
                            _selectedPrice = price;
                            _priceController.text = price.toString();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total paniers / semaine :"),
                  Text(totalBaskets.toStringAsFixed(0)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Gain estimé / mois (€) :"),
                  Text(monthlyGain.toStringAsFixed(2)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submitConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirmer", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
