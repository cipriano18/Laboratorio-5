import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/otp_provider.dart';
import '../services/otp_service.dart';
import '../screens/login/login_screen.dart';
import '../screens/otp/otp_screen.dart';
import '../screens/success/success_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpProvider(otpService: OtpService()),
      child: MaterialApp(
        title: 'OTP Verification',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3F51B5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/otp': (_) => const OtpScreen(),
          '/success': (_) => const SuccessScreen(),
        },
      ),
    );
  }
}
