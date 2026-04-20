import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  AppDialogs._();

  /// Диалог подтверждения удаления. Возвращает true если подтвердили.
  static Future<bool> confirmDelete(
    BuildContext context, {
    String title = 'Удалить?',
    String message = 'Это действие нельзя отменить.',
    String deleteLabel = 'Удалить',
  }) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: title,
      message: message,
      okLabel: deleteLabel,
      cancelLabel: 'Отмена',
      isDestructiveAction: true,
      style: AdaptiveStyle.adaptive,
    );
    return result == OkCancelResult.ok;
  }

  /// Универсальный диалог с одной кнопкой OK.
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? message,
    String okLabel = 'Хорошо',
  }) async {
    await showOkAlertDialog(
      context: context,
      title: title,
      message: message,
      okLabel: okLabel,
      style: AdaptiveStyle.adaptive,
    );
  }

  /// Диалог с произвольными действиями.
  static Future<T?> actions<T>(
    BuildContext context, {
    required String title,
    String? message,
    required List<AlertDialogAction<T>> actions,
  }) async {
    return showAlertDialog<T>(
      context: context,
      title: title,
      message: message,
      actions: actions,
      style: AdaptiveStyle.adaptive,
    );
  }
}
