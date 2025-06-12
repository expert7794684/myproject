import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/fields/toggle_field.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:flutter/material.dart';

class ToggleSettingCard<T> extends StatefulWidget {
  const ToggleSettingCard(
      {super.key,
      required this.setting,
      this.showAsCard = false,
      this.onChanged});

  final ToggleSetting setting;
  final bool showAsCard;
  final void Function(T)? onChanged;


  @override
  State<ToggleSettingCard<T>> createState() => _ToggleSettingCardState<T>();
}

class _ToggleSettingCardState<T> extends State<ToggleSettingCard<T>> {
  final offset = 1;
  @override
  Widget build(BuildContext context) {
    ToggleField<T> toggleCard = ToggleField<T>(
      name: widget.setting.displayName(context),
      description: widget.setting.displayDescription(context),
      selectedItems: widget.setting.value,
      options: widget.setting.options
          .map((option) =>
              ToggleOption<T>(option.getLocalizedName(context), option.value))
          .toList(),
      onChange: (value) {
        setState(() {
          widget.setting.toggle(context, value);
        });

        widget.onChanged?.call(widget.setting.value);
      },
      // padding: widget.showAsCard ? 16 : 0,
    );

    return widget.showAsCard ? CardContainer(child: toggleCard) : toggleCard;
  }
}
