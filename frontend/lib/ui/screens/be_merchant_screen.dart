import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'plus_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/merchant_provider.dart';
import 'merchant/merchant_screen.dart';
import 'merchant/add_store_screen.dart';
import '../../models/merchant_application_status.dart';
import '../../providers/error_notifier.dart';


class BeMerchantScreen extends StatefulWidget {
  const BeMerchantScreen({super.key});

  @override
  State<BeMerchantScreen> createState() => _BeMerchantScreenState();
}

class _BeMerchantScreenState extends State<BeMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasExistingApplication = false;
  Map<String, dynamic>? _existingApplicationData;

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailProController = TextEditingController();
  final TextEditingController _sirenController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    
    try {
      await merchantProvider.checkApplicationStatus();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExistingApplication = merchantProvider.status != MerchantApplicationStatus.notApplied;
          _existingApplicationData = merchantProvider.merchantData;
          
          if (_hasExistingApplication && _existingApplicationData != null) {
            _businessNameController.text = _existingApplicationData!['business_name'] ?? '';
            _emailProController.text = _existingApplicationData!['email_pro'] ?? '';
            _sirenController.text = _existingApplicationData!['siren'] ?? '';
            _phoneNumberController.text = _existingApplicationData!['phone_number'] ?? '';
          }
        });
      }
    } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailProController.dispose();
    _sirenController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      final success = await merchantProvider.submitApplication(
        businessName: _businessNameController.text,
        emailPro: _emailProController.text,
        siren: _sirenController.text,
        phoneNumber: _phoneNumberController.text,
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée avec succès')),
        );
        _checkExistingApplication();
      } else {
        final errorNotifier = Provider.of<ErrorNotifier>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorNotifier.errorMessage ?? 'Erreur lors de l\'envoi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir marchand'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: _hasExistingApplication 
                ? _buildExistingApplicationView()
                : _buildApplicationForm(), // <-- le bouton n'est plus ici
            ),
      ),
      bottomNavigationBar: !_hasExistingApplication
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text('Envoyer la demande'),
              ),
            )
          : null,
    );
  }

  Widget _buildExistingApplicationView() {
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final status = merchantProvider.status;
    final statusMessage = _getStatusMessage(status);
    final statusColor = _getStatusColor(status);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status == MerchantApplicationStatus.approved 
            ? 'Votre demande a été approuvée'
            : 'Votre demande est en cours de traitement',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusMessage,
                  style: TextStyle(color: statusColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Détails de votre demande:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Entreprise', merchantProvider.merchantData?['business_name'] ?? ''),
        _buildInfoCard('Email professionnel', merchantProvider.merchantData?['email_pro'] ?? ''),
        _buildInfoCard('SIREN', merchantProvider.merchantData?['siren'] ?? ''),
        _buildInfoCard('Téléphone', merchantProvider.merchantData?['phone_number'] ?? ''),
        const SizedBox(height: 30),
        
        if (status == MerchantApplicationStatus.rejected) 
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50), // Bouton pleine largeur
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _hasExistingApplication = false;
                });
              }
            },
            child: const Text('Soumettre une nouvelle demande'),
          ),
        
        if (status == MerchantApplicationStatus.approved)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50), 
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStoreScreen()),
              );
            },
            child: const Text('Créer mon magasin'),
          ),
      ],
    );
  }



  Widget _buildInfoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  String _getStatusMessage(MerchantApplicationStatus status) {
    switch (status) {
      case MerchantApplicationStatus.pending:
        return 'Votre demande est en cours d\'examen. Nous vous contacterons prochainement.';
      case MerchantApplicationStatus.approved:
        return 'Félicitations! Votre demande a été approuvée. Vous pouvez maintenant créer votre magasin.';
      case MerchantApplicationStatus.rejected:
        return 'Votre demande a été refusée. Veuillez vérifier les informations fournies ou nous contacter pour plus de détails.';
      default:
        return 'Statut de la demande inconnu.';
    }
  }

  Color _getStatusColor(MerchantApplicationStatus status) {
    switch (status) {
      case MerchantApplicationStatus.pending:
        return Colors.orange;
      case MerchantApplicationStatus.approved:
        return Colors.green;
      case MerchantApplicationStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  Widget _buildApplicationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Demande pour devenir marchand',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Veuillez remplir les informations ci-dessous pour soumettre votre demande de compte marchand.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: "Nom de l'entreprise",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Ce champ est requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailProController,
            decoration: InputDecoration(
              labelText: 'Email professionnel',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty
                ? 'Ce champ est requis'
                : (!value.contains('@')
                    ? 'Email invalide'
                    : null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _sirenController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Numéro de SIREN',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.length != 9
                ? 'Le numéro SIREN doit contenir 9 chiffres'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone professionnel',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty
                ? 'Ce champ est requis'
                : (value.length < 10
                    ? 'Numéro invalide'
                    : null),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
