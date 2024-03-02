import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

/// Main function of the application
void main() async {
  // This line is required when calling `initializeFCM` method inside `NotificationsBloc`
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  // Initialize Firestore Cloud Messaging service
  await NotificationsBloc.initializeFCM();

  // Running the application
  runApp(
    // Providing the `NotificationsBloc` to the application
    MultiBlocProvider(
      providers: [
        // Creating an instance of `NotificationsBloc`
        BlocProvider(
          create: (_) => NotificationsBloc(),
        ),
      ],
      child: const PushNotificationsApp(),
    ),
  );
}

/// This is the main widget of the application
class PushNotificationsApp extends StatelessWidget {
  const PushNotificationsApp({super.key});

  // It describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Returning a MaterialApp widget configured with the application router, title and theme.
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: AppTheme().getTheme(),
    );
  }
}