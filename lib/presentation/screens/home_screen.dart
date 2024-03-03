import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

/// The [HomeScreen] class. It's a [StatelessWidget] that represents the Home Screen.
///
/// This widget returns a [Scaffold] with the structure of your home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Builds the [HomeScreen] widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Defines the [AppBar] of [HomeScreen].
      /// Displays the current status of [NotificationsBloc] as its title.
      /// Also houses a settings [IconButton] that requests permissions.
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${bloc.state.status}'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationsBloc>().requestPermission();
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),

      /// Constructs the body of [HomeScreen], using [_HomeView] widget.
      body: const _HomeView(),
    );
  }
}

/// [_HomeView] class. It's a [StatelessWidget] that represents the view of [HomeScreen].
///
/// Contains the structure and behavior for notifications' display.
class _HomeView extends StatelessWidget {
  const _HomeView();

  /// Builds the [_HomeView] widget.
  /// It reads notifications from [NotificationsBloc] and displays them in a [ListView].
  @override
  Widget build(BuildContext context) {
    final notifications = context.read<NotificationsBloc>().state.notifications;

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return ListTile(
          onTap: () {
            context.push('/push-details/${notification.messageId}');
          },
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: notification.imageUrl != null
              ? Image.network(notification.imageUrl!)
              : null, // if it's coming
        );
      },
    );
  }
}
