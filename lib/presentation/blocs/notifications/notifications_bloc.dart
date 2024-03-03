/// This dart file represents the notification system within the app.
///
/// It uses the FirebaseMessaging system and handles notification states,
/// background and foreground notifications, notification events, and the
/// notification authorization status.

// Import necessary packages and libraries
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// Handles any messages received while the app is in the background.
///
/// A Future returns a value of any type and this future returns void.
///
/// The function awaits to initialize Firebase in the device and prints a message.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

/// A Bloc that handles the notifications within the app.
///
/// Initializes the state, reactively nature setup to listens to notifications and handles events.
///
/// It extends the Bloc class provided by the Flutter package.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    // Listening for any changes to notification status.
    on<NotificationStatusChanged>(_notificationStatusChanged);

    // Listening for any notification received events.
    on<NotificationReceived>(_onPushMessageReceived);

    // Verify state of the notifications.
    _initialStatusCheck();

    // Listener for the Foreground Notifications.
    _onForegroundMessage();
  }

  /// This static function initializes the Firebase cloud Messaging (FCM).
  ///
  /// The options for the currentPlatform is passed as a parameter.
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// This function changes the notification status.
  ///
  /// The changes are done on an event basis.
  /// The state of the notification is copied to the new one.
  void _notificationStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  /// This function adds the received message to the state.
  ///
  /// The new notification is added to the top of the previous notifications in the state.
  void _onPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(state
        .copyWith(notifications: [event.pushMessage, ...state.notifications]));
  }

  /// This function checks the initial status of notifications.
  ///
  /// It checks whether it's authorized or not.
  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  /// This function gets the Firebase Cloud Messaging token.
  ///
  /// It checks whether the authorization status is authorized or not.
  /// If authorized, then it prints the token.
  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print(token);
  }

  /// This function handles remote messages.
  ///
  /// If the message notification is null, then it returns nothing.
  /// If valid, then it creates a notification and adds it.
  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

    add(NotificationReceived(notification));
  }

  /// This function listens for notifications when the app is in the foreground.
  ///
  /// It uses the FirebaseMessaging.onMessage to listen to messages.
  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  /// This function requests for permissions.
  ///
  /// This sends a request to get an alert and plays a sound when a notification arrives.
  /// Also, a badge is shown on the app alias.
  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  /// This function fetches a message from the state using ID.
  ///
  /// If the ID of the message is not in the state, then it returns null.
  /// If it exists, then it returns the first found message.
  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exist) return null;

    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}