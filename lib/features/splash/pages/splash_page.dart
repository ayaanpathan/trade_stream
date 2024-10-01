import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';
import 'package:trade_stream/core/widgets/connection_wrapper.dart';
import 'package:trade_stream/features/trading_home/presentation/pages/trading_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const ConnectionWrapper(child: TradingHomePage())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo
            Icon(
              Icons.show_chart,
              size: 200,
              color: AppColors.accentColorLight,
            ),
            SizedBox(height: 24),
            Text(
              'Trade Stream',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
