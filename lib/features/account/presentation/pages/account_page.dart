import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';

import 'package:hotel_booking/i18n/strings.g.dart';

@RoutePage()
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('account_scaffold'),
      appBar: AppBar(
        key: const Key('account_app_bar'),
        title: Text(
          t.account.title,
          key: const Key('account_title'),
        ),
      ),
      body: Center(
        child: Icon(
          Icons.account_circle_outlined,
          size: 150,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          key: const Key('account_icon'),
        ),
      ),
    );
  }
}
