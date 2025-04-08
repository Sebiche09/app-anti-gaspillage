import 'package:flutter/material.dart';
import '../widgets/common/header.dart';
import '../screens/map/mapbox_widget.dart';
import '../../constants/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final String containerId = 'mapbox-container';

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.primary,
    body: SafeArea(
      child: Column(
        children: [
          Header(
            title: 'Explore',
            searchString: 'Chercher un lieu...',
            onSearch: (query) {},
            isCentered: true,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MapboxWidget(
                  containerId: containerId,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}
