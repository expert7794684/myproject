import 'package:clock_app/common/widgets/clock/digital_clock_display.dart';
import 'package:clock_app/navigation/types/alignment.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:timezone/timezone.dart' as timezone;

enum ClockType {
  digital,
  analog,
}

class DigitalClock extends StatelessWidget {
  const DigitalClock({
    super.key,
    this.scale = 1,
    this.shouldShowDate = false,
    this.shouldShowSeconds = false,
    this.color,
    this.timezoneLocation,
    this.horizontalAlignment = ElementAlignment.start,
  });

  final ElementAlignment horizontalAlignment;
  final double scale;
  final bool shouldShowDate;
  final bool shouldShowSeconds;
  final Color? color;
  final timezone.Location? timezoneLocation;

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1),
        builder: (context) {
      DateTime dateTime;
      if (timezoneLocation != null) {
        dateTime = timezone.TZDateTime.now(timezoneLocation!);
      } else {
        dateTime = DateTime.now();
      }
      return DigitalClockDisplay(
        scale: scale,
        shouldShowDate: shouldShowDate,
        color: color,
        shouldShowSeconds: shouldShowSeconds,
        dateTime: dateTime,
        horizontalAlignment: horizontalAlignment,
      );
    });
  }
}
