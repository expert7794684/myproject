import 'package:clock_app/clock/types/time.dart';
import 'package:clock_app/common/utils/time_format.dart';
import 'package:clock_app/common/widgets/clock/time_display.dart';
import 'package:clock_app/navigation/types/alignment.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:flutter/material.dart';

class DigitalClockDisplay extends StatefulWidget {
  const DigitalClockDisplay({
    super.key,
    this.scale = 1,
    this.color,
    this.shouldShowTime = true,
    this.shouldShowDate = false,
    this.shouldShowSeconds = false,
    required this.dateTime,
    this.horizontalAlignment = ElementAlignment.start,
  });

  final bool shouldShowTime;
  final double scale;
  final bool shouldShowDate;
  final Color? color;
  final DateTime dateTime;
  final bool shouldShowSeconds;
  final ElementAlignment horizontalAlignment;

  @override
  State<DigitalClockDisplay> createState() => _DigitalClockDisplayState();
}

class _DigitalClockDisplayState extends State<DigitalClockDisplay> {
  late Setting timeFormatSetting = appSettings
      .getGroup("General")
      .getGroup("Display")
      .getSetting("Time Format");

  late Setting longDateFormatSetting = appSettings
      .getGroup("General")
      .getGroup("Display")
      .getSetting("Long Date Format");

  TimeFormat getTimeFormat() {
    TimeFormat timeFormat = timeFormatSetting.value;
    if (timeFormat == TimeFormat.device) {
      if (MediaQuery.of(context).alwaysUse24HourFormat) {
        timeFormat = TimeFormat.h24;
      } else {
        timeFormat = TimeFormat.h12;
      }
    }
    return timeFormat;
  }

  void update(dynamic value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    timeFormatSetting.addListener(update);
    longDateFormatSetting.addListener(update);
  }

  @override
  void dispose() {
    timeFormatSetting.removeListener(update);
    longDateFormatSetting.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TimeFormat timeFormat = getTimeFormat();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.values[widget.horizontalAlignment.index],
      children: <Widget>[
        if (widget.shouldShowTime)
          Row(
              mainAxisAlignment:
                  MainAxisAlignment.values[widget.horizontalAlignment.index],
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                TimeDisplay(
                  format: getTimeFormatString(context, timeFormat,
                      showMeridiem: false),
                  fontSize: 72 * widget.scale,
                  height: widget.shouldShowDate ? 0.75 : null,
                  color: widget.color,
                  dateTime: widget.dateTime,
                ),
                SizedBox(width: 4 * widget.scale),
                Column(
                  verticalDirection: VerticalDirection.up,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.shouldShowSeconds)
                      TimeDisplay(
                        format: 'ss',
                        fontSize: 36 * widget.scale,
                        height: 1,
                        color: widget.color,
                        dateTime: widget.dateTime,
                      ),
                    Row(
                      children: timeFormat == TimeFormat.h12
                          ? [
                              TimeDisplay(
                                format: 'a',
                                fontSize: (widget.shouldShowSeconds ? 24 : 32) *
                                    widget.scale,
                                height: 1,
                                color: widget.color,
                                dateTime: widget.dateTime,
                              ),
                              if (widget.shouldShowSeconds)
                                SizedBox(width: 16 * widget.scale),
                            ]
                          : [
                              if (widget.shouldShowSeconds)
                                SizedBox(width: 56 * widget.scale),
                            ],
                    ),
                  ],
                ),
              ]),
        if (widget.shouldShowDate) SizedBox(height: 4 * widget.scale),
        if (widget.shouldShowDate)
          TimeDisplay(
            format: longDateFormatSetting.value,
            fontSize: 16 * widget.scale,
            height: 1,
            dateTime: widget.dateTime,
            color: widget.color ??
                Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
          ),
      ],
    );
  }
}
