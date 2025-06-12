import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


ActionPane getDeleteActionPane(VoidCallback onDelete, BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  return ActionPane(
    motion: const ScrollMotion(),
    // extentRatio: Platform == 0.25,
    children: [
      CustomSlidableAction(
        onPressed: (context) => onDelete(),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onPrimary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: colorScheme.onError),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.deleteButton,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onError,
                )),
          ],
        ),
      ),
    ],
  );
}

ActionPane getDuplicateActionPane(
    VoidCallback onDuplicate, BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return ActionPane(
    motion: const ScrollMotion(),

    // extentRatio: Platform == 0.25,
    children: [
      CustomSlidableAction(
        onPressed: (context) => onDuplicate(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copy_rounded, color: colorScheme.onPrimary),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.duplicateButton,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                )),
          ],
        ),
      ),
    ],
  );
}
