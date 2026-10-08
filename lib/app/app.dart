import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:raigon_art/app/app_router.dart';
import 'package:raigon_art/core/theme/theme_controller.dart';
import 'package:raigon_art/features/authentication/providers/auth_provider.dart';

class RaigonartApp extends StatelessWidget {
  const RaigonartApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.publicSans().fontFamily,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.mode,
          builder: (context, mode, _) => MaterialApp(
            title: 'Raigon Art',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            initialRoute: AppRouter.auth,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      ),
    );
  }
}
