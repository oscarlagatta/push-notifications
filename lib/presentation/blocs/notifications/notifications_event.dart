/// 'notifications_bloc.dart' File Documentation
///
/// This file defines the events in the 'notifications_bloc.dart' for the notifications feature in the application.
/// The [NotificationsEvent] class is an abstract class which serves as the base class for other event classes.
///
/// The [NotificationStatusChanged] and [NotificationReceived] classes inherit from the abstract class
/// [NotificationsEvent] to define specific types of events associated with notifications.

part of 'notifications_bloc.dart';

/// Abstract Event class for notifications.
///
/// Serves as a base class from which the other event classes in the notifications system will inherit.
abstract class NotificationsEvent  {
  const NotificationsEvent();
}

/// Event class for a change in notification status.
///
/// This class is used to emit events when the authorization status of the notification changes.
class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;          /// Variable holding the new authorization status.

  /// Constructor for creating a instance of [NotificationStatusChanged].
  ///
  /// Takes [status], an instance of [AuthorizationStatus], denoting the new status of the notification system.
  const NotificationStatusChanged(this.status);
}

/// Event class for receiving a new notification.
///
/// This class is used to emit events when a new push message causes a notification to be received.
class NotificationReceived extends NotificationsEvent {
  final PushMessage pushMessage;             /// Variable holding the push message which caused this notification.

  /// Constructor for creating a instance of [NotificationReceived].
  ///
  /// Takes [pushMessage], an instance of [PushMessage], as argument. The [pushMessage] is the push message which
  /// caused this notification to be received.
  NotificationReceived(this.pushMessage);
}