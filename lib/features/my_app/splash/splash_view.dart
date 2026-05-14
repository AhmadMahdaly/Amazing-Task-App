import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/../core/responsive/responsive_config.dart';
import '/../core/routing/app_routes.dart';
import '../../../core/resources/app_images.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _hasRedirected = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _redirect();
    });
  }

  Future<void> _redirect() async {
    if (_hasRedirected || !mounted) return;
    _hasRedirected = true;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go(AppRoutes.mainTasksScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              AppImages.appLogo,
              fit: BoxFit.cover,
              width: SizeConfig.screenWidth * 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
