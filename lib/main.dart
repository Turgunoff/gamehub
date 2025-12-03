import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gamehub/core/services/device_service.dart';
import 'package:gamehub/core/services/onesignal_service.dart';
import 'package:gamehub/core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/network_service.dart';
import 'core/services/api_service.dart';
import 'core/widgets/network_overlay.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Firebase (OneSignal FCM uchun kerak)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DeviceService.instance.init();

  // Initialize services
  await NetworkService().initialize();
  await ApiService().initialize();

  // OneSignal Push Notifications
  await OneSignalService().initialize();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('uz'),
      startLocale: const Locale('uz'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc()..add(ProfileLoadRequested()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc()..add(const HomeLoadRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: context.locale.toString() == 'uz' ? 'CyberPitch' : 'CyberPitch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (context, child) {
          return NetworkOverlay(child: child!);
        },
      ),
    );
  }
}
