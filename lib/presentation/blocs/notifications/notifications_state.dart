part of 'notifications_bloc.dart';

// This class encapsulates the state of notifications in the application.
class NotificationsState extends Equatable {
  // In the constructor, we assign the initial states for the authorization status
  // and notifications. If no initial states are provided, the status will be set to
  // 'notDetermined', and notifications will be an empty list.
  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
  });

  // This field represents the current authorization status.
  final AuthorizationStatus status;

  // This field represents a list of the push notifications.
  final List<PushMessage> notifications;

  // This method creates a new NotificationsState by replacing the current status
  // and notifications with the new ones provided as parameters (if provided).
  // If no new status or notifications are provided, the current ones will be preserved.
  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
      );

  // This method provides the properties that will be used by Equatable to determine equality.
  @override
  List<Object> get props => [status, notifications];
}