import 'package:flutter/material.dart';

import 'package:hotel_booking/i18n/strings.g.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      key: const Key('search_text_field'),
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        prefixIcon: SizedBox(
          width: 48,
          child: Icon(
            Icons.search,
            key: const Key('search_prefix_icon'),
          ),
        ),
        suffixIcon: IconButton(
          key: const Key('search_clear_button'),
          onPressed: controller.clear,
          icon: Icon(
            Icons.cancel_outlined,
            key: const Key('search_suffix_icon'),
          ),
        ),
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        hintText: t.hotels.search,
      ),
      style: textTheme.titleLarge,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => focusNode?.unfocus(),
    );
  }
}
