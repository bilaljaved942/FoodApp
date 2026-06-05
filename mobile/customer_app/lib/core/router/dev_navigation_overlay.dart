import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

class DevNavigationOverlay extends StatefulWidget {
  const DevNavigationOverlay({
    super.key,
    required this.routes,
  });

  final List<String> routes;

  @override
  State<DevNavigationOverlay> createState() => _DevNavigationOverlayState();
}

class _DevNavigationOverlayState extends State<DevNavigationOverlay> {
  late final List<String> _routes;
  
  @override
  void initState() {
    super.initState();
    _routes = widget.routes;
    
    // Add listener to router delegate to rebuild when location changes
    AppRouter.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentLocation = '/';
    try {
      currentLocation = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    } catch (e) {
      currentLocation = '/';
    }

    // Find index of current route in list
    int currentIndex = _routes.indexWhere((r) {
      final baseR = r.split('/:').first;
      if (baseR == '/') return currentLocation == '/';
      return currentLocation.startsWith(baseR);
    });
    if (currentIndex == -1) currentIndex = 0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 76, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    final prevIndex = (currentIndex - 1 + _routes.length) % _routes.length;
                    AppRouter.router.go(_routes[prevIndex]);
                  },
                ),
                const SizedBox(width: 8),

                // Dropdown of routes
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.grey[900],
                  ),
                  child: DropdownButton<String>(
                    value: _routes[currentIndex],
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 16),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    items: _routes.map((String path) {
                      final name = path.replaceAll('/', ' ').trim();
                      final displayName = name.isEmpty ? 'SPLASH' : name.toUpperCase();
                      return DropdownMenuItem<String>(
                        value: path,
                        child: Text(
                          displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newPath) {
                      if (newPath != null) {
                        AppRouter.router.go(newPath);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Next button
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    final nextIndex = (currentIndex + 1) % _routes.length;
                    AppRouter.router.go(_routes[nextIndex]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
