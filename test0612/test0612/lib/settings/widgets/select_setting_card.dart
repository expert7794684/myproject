import 'package:clock_app/common/types/select_choice.dart';
import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/fields/select_field/select_field.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:flutter/material.dart';

class SelectSettingCard<T> extends StatefulWidget {
  const SelectSettingCard({
    super.key,
    required this.setting,
    this.showAsCard = false,
    this.onChanged,
  });
  final SelectSetting<T> setting;
  final void Function(T)? onChanged;
  final bool showAsCard;

  @override
  State<SelectSettingCard<T>> createState() => _SelectSettingCardState<T>();
}

class _SelectSettingCardState<T> extends State<SelectSettingCard<T>> {
  @override
  Widget build(BuildContext context) {
    SelectField selectWidget = SelectField(
      getSelectedIndices: () => [widget.setting.selectedIndex],
      title: widget.setting.displayName(context),
      actions: widget.setting.actions,
      getChoices: () => widget.setting.options
          .map((option) => SelectChoice(
              name: option.getLocalizedName(context),
              value: option.value,
              description: option.getDescription(context)))
          .toList(),
      onChanged: (value) {
        setState(() {
          widget.setting.setValue(context, value[0]);
        });
        widget.onChanged?.call(widget.setting.value);
      },
    );

    return widget.showAsCard
        ? CardContainer(
            child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: selectWidget,
          ))
        : selectWidget;
  }
}
