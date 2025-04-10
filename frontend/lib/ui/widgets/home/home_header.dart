import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../common/header.dart';
import '../../../providers/basket_provider.dart';

class HomeHeader extends StatefulWidget {
  static String? _currentAddress;
  static bool _isLocationLoaded = false;

  const HomeHeader({Key? key}) : super(key: key);

  @override
  _HomeHeaderState createState() => _HomeHeaderState();

  static Future<void> loadLocation() async {
    if (!_isLocationLoaded) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationLoaded = true;
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocationLoaded = true;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocationLoaded = true;
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}');
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark place = placemarks[0];
        _currentAddress = '${place.street}, ${place.locality}';
      } catch (e) {
        print(e);
      }
      _isLocationLoaded = true;
    }
  }
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  void initState() {
    super.initState();
    if (!HomeHeader._isLocationLoaded) {
      HomeHeader.loadLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Header(
      title: HomeHeader._currentAddress ?? 'Chargement...',
      searchString: 'Chercher ici...',
      onSearch: (query) {
        Provider.of<BasketsProvider>(context, listen: false).searchBaskets(query);
      },
      isCentered: false,
    );
  }
}
