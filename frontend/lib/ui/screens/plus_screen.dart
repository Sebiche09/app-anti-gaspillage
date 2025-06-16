import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/header.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/be_merchant_screen.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({Key? key}) : super(key: key);

  Widget buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Plus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: const AssetImage('assets/profile.png') as ImageProvider
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.email ?? 'Utilisateur',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildOption(Icons.favorite, 'Favoris', () {}),
                      buildOption(Icons.notifications, 'Notifications', () {}),
                      buildOption(Icons.credit_card, 'Cartes de paiement', () {}),
                      buildOption(Icons.card_giftcard, 'Vouchers', () {}),
                      buildOption(Icons.settings, 'Paramètres', () {}),
                      buildOption(Icons.privacy_tip, 'Politique de confidentialité', () {}),
                      buildOption(Icons.description, 'Mentions légales', () {}),
                      buildOption(Icons.account_box_rounded, 'Devenir marchand', () {
                        Navigator.of(context).push(  // Changez pushReplacement par push
                          MaterialPageRoute(builder: (context) => const BeMerchantScreen()),
                        );
                      }),
                      buildOption(Icons.logout, 'Déconnexion', () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}