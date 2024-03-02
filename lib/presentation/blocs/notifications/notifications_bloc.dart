import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';

part 'notifications_state.dart';

/// Token: ct8z-v7ERKS2VndNKkOVdL:APA91bE_Vl0xMkUNEfrQRLqDnlfbmDDW-CBEJdfDHjaz1bozaX9kaXTLtq92wMSczbeoGVGnL7c0Wz1NXk-LqxaNLdQuw1xRs4giGCT6WkLq2qjHOF8Y_3eeBV4JgdsqAuTMeWl643MY

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

/// `NotificationsBloc`
///
/// This Class deals with notifications events and states related to Firebase Messaging.
/// It initializes the Firebase Messaging and requests for user permissions for notifications.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  /// Creating an instance of Firebase Messaging.
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Constructor for NotificationsBloc.
  /// Super constructor for NotificationsState is called.
  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_onNotificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);

    /// TODO 3: Create listener # _onPushMessageReceived
    ///

    // Verify the state of the notifications
    _initialStatusCheck();

    // Listener for Foreground Notifications
    _onForegroundMessage();
  }

  /// Initialize Firebase
  ///
  /// This function initialises the Firebase with default current options.
  ///
  /// This function is a static method and can be called directly from the Class.
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Callback for when notification status changes
  ///
  /// This method updates the current state when the notification status changes.
  /// It uses the `Emitter#emit` method from the bloc library to achieve this.
  void _onNotificationStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(
      state.copyWith(status: event.status),
    );

    _getFCMToken();
  }

   void _onPushMessageReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    try {
      emit(
        state.copyWith(
          notifications: [
            ...state.notifications,
            event.pushMessage,
          ],
        ),
      );
      print('notifications ${state.notifications}');

    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add( NotificationStatusChanged(settings.authorizationStatus) );
  }

  void _getFCMToken() async {

    if ( state.status != AuthorizationStatus.authorized ) return;

    final token = await messaging.getToken();
    print(token);
  }

  void handleRemoteMessage(RemoteMessage message) {
    // print('Got a message whilst in the foreground!');
    // print('Message data::: ${message.data}');

    if (message.notification == null) return;

    final notification = PushMessage(
        messageId: message.messageId
            ?.replaceAll(':', '').replaceAll('%', '')
            ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl
    );

    add( NotificationReceived(notification) );

    // print('Message also contained a notification: ${notification}');
  }

  void _onForegroundMessage() {
    // Stream
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  /// Requests User Permission for Showing Notification
  ///
  /// This function will prompt the user for allowing notifications from the app.
  ///
  /// Notification settings includes options like alert, announcement, badge, carPlay, criticalAlert, provisional, and sound.
  /// The function uses Firebase Messaging to request these permissions.
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

    // Updating the current state with the new authorization status
    add(
      NotificationStatusChanged(settings.authorizationStatus),
    );
    _getFCMToken();
  }
}
