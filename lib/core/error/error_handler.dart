import 'package:flutter/material.dart';

import '../../data/remote/api_client.dart';

String friendlyErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  if (error.toString().contains('SocketException')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (error.toString().contains('TimeoutException')) {
    return 'The server took too long to respond. Try again.';
  }
  return 'Something went wrong. Please try again.';
}

void showErrorSnackBar(BuildContext context, Object error) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(friendlyErrorMessage(error)),
      backgroundColor: const Color(0xFFD64545),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
