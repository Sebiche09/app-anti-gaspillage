import 'package:flutter/material.dart';
import '../widgets/common/header.dart';
import '../screens/map/mapbox_widget.dart'; 

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final String containerId = 'mapbox-container';
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(
              title: 'Explore',
              searchString: 'Chercher un lieu...',
              onSearch: (query) {
              },
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

      // Navigation du bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF8D23),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Plus'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          else if (index == 1) {
            setState(() {
            });
          }
        },
      ),
    );
  }
}
