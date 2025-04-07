import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:async';

class MapboxWidget extends StatefulWidget {
  final String containerId;
  final double height;
  final double width;

  const MapboxWidget({
    Key? key,
    required this.containerId,
    this.height = double.infinity,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  _MapboxWidgetState createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<MapboxWidget> with WidgetsBindingObserver {
  bool isMapInitialized = false;
  Timer? _resizeTimer;
  final GlobalKey _mapContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeMetrics() {
    if (isMapInitialized) {
      _resizeTimer?.cancel();
      _resizeTimer = Timer(const Duration(milliseconds: 300), () {
        _resizeMap();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resizeTimer?.cancel();
    if (isMapInitialized) {
      js.context.callMethod('cleanupMapbox', [widget.containerId]);
      isMapInitialized = false;
    }
    super.dispose();
  }

  void _initializeMap() {
    final container = html.document.getElementById(widget.containerId);
    if (container != null) {
      container.style.width = '100%';
      container.style.height = '100%';
      
      Timer(const Duration(milliseconds: 100), () {
        js.context.callMethod('initializeMapbox', [
          widget.containerId, 
          4.913740644542706, 
          -52.29583978721069, 
          12
        ]);
        isMapInitialized = true;
        
        Timer(const Duration(milliseconds: 500), _resizeMap);
      });
    }
  }

  void _resizeMap() {
    if (isMapInitialized) {
      js.context.callMethod('resizeMap', []);
      print("Map resized at ${DateTime.now()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isMapInitialized) {
            _initializeMap();
          } else {
            _resizeMap();
          }
        });

        return Container(
          key: _mapContainerKey,
          width: widget.width,
          height: widget.height,
          child: HtmlElementView(viewType: widget.containerId),
        );
      },
    );
  }
}
