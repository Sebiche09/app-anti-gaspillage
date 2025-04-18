import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class MerchantService {
  final ApiService apiService;

  MerchantService({required this.apiService});

  /// Soumet une demande pour devenir marchand
  /// 
  /// Paramètres:
  /// - businessName: nom de l'entreprise
  /// - emailPro: email professionnel
  /// - siren: numéro SIREN (9 chiffres)
  /// - phoneNumber: numéro de téléphone professionnel
  Future<Map<String, dynamic>> submitMerchantApplication({
    required String businessName,
    required String emailPro,
    required String siren,
    required String phoneNumber,
    }) async {
    try {
      final data = {
        'business_name': businessName,
        'email_pro': emailPro,
        'siren': siren,
        'phone_number': phoneNumber,
      };
      final response = await apiService.post('/api/merchants/', data);
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> checkMerchantStatus() async {
  try {
    final response = await apiService.get('/api/merchants/request-status');
    print("Response: $response");
    return response;
  } catch (e) {
    if (e.toString().contains('404')) {
      return {'status': null};
    }
    throw Exception('Erreur lors de la vérification: ${e.toString()}');
  }
}

  Future<bool> validateSiren(String siren) async {
    try {
      if (siren.length != 9 || int.tryParse(siren) == null) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
