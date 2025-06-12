import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/fields/date_picker_bottom_sheet.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField<T> extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.title,
    this.description,
    required this.onChanged,
    required this.value,
    this.rangeOnly = false,
  });

  final List<DateTime> value;
  final String title;
  final String? description;
  final bool rangeOnly;
  final void Function(List<DateTime>) onChanged;

  @override
  State<DatePickerField<T>> createState() => _DatePickerFieldState<T>();
}

enum SelectType { color, text }

class _DatePickerFieldState<T> extends State<DatePickerField<T>> {
  late String dateFormat;
  late Setting dateFormatSetting;

  void setDateFormat(dynamic newDateFormat) {
    setState(() {
      dateFormat = newDateFormat;
    });
  }

  @override
  void initState() {
    super.initState();
    dateFormatSetting = appSettings
        .getGroup("General")
        .getGroup("Display")
        .getSetting("Date Format");
    dateFormatSetting.addListener(setDateFormat);
    setDateFormat(dateFormatSetting.value);
  }

  @override
  void dispose() {
    dateFormatSetting.removeListener(setDateFormat);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showSelect() async {
      List<DateTime>? selectedDates =
          await showModalBottomSheet<List<DateTime>>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DatePickerBottomSheet(
                title: widget.title,
                initialDates: widget.value,
                rangeOnly: widget.rangeOnly,
                onChanged: (value) {
                  setState(() {
                    widget.onChanged(value);
                  });
                },
              );
            },
          );
        },
      );

      if (selectedDates != null) {
        setState(() {
          widget.onChanged(selectedDates);
        });
      }
    }

    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.access_time_rounded,
                      color: colorScheme.onBackground.withOpacity(0.6))
                ],
              ),
              const SizedBox(height: 4.0),
              SizedBox(
                width: MediaQuery.of(context).size.width - 64,
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    for (var i = 0; i < widget.value.length; i++)
                      DateChip(date: widget.value[i], dateFormat: dateFormat),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.dateFormat,
  });

  final DateTime date;
  final String dateFormat;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return CardContainer(
      key: const Key("DateChip"),
      color: colorScheme.primary,
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          DateFormat(dateFormat).format(date),
          style: const TextStyle(fontSize: 10)
              .copyWith(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
