import 'package:flutter/material.dart';
import '../widgets/common/header.dart';
import '../../constants/app_colors.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Header(
              title: 'Plus',
              searchString: 'test',
              onSearch: (query) {},
              isCentered: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
