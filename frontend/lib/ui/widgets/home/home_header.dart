import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/header.dart';
import '../../../providers/basket_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Header(
      title: 'Home',
      searchString: 'Chercher ici...',
      onSearch: (query) {
        Provider.of<BasketsProvider>(context, listen: false).searchBaskets(query);
      },
    );
  }
}