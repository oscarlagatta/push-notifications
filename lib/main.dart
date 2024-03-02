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

  // Listener for notifications
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
      builder: (context, child) =>
          HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends StatefulWidget {
  const HandleNotificationInteractions({super.key, required this.child});

  final Widget child;

  @override
  State<HandleNotificationInteractions> createState() =>
      _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState
    extends State<HandleNotificationInteractions> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId =
        message.messageId?.replaceAll(':', '').replaceAll('%', '');
    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
