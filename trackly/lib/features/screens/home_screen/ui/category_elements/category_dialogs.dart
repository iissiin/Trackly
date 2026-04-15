import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

Future<String?> showCategoryInputDialog(
  BuildContext context, {
  String title = 'Новая категория',
  String okLabel = 'Создать',
  String initialText = '',
}) async {
  final results = await showTextInputDialog(
    context: context,
    title: title,
    okLabel: okLabel,
    cancelLabel: 'Отмена',
    textFields: [
      DialogTextField(
        hintText: 'Название категории',
        maxLength: 30,
        initialText: initialText,
        validator: (val) =>
            (val == null || val.trim().isEmpty) ? 'Введите название' : null,
      ),
    ],
  );

  final name = results?.first.trim();
  if (name == null || name.isEmpty) return null;
  return name;
}
