import 'package:clock_app/timer/types/time_duration.dart';
import 'package:clock_app/timer/types/timer_preset.dart';

List<TimerPreset> defaultTimerPresets = [
  TimerPreset("1 min", const TimeDuration(minutes: 1)),
  TimerPreset("5 min", const TimeDuration(minutes: 5)),
  TimerPreset("10 min", const TimeDuration(minutes: 10)),
  TimerPreset("Workout", const TimeDuration(minutes: 10)),
  TimerPreset("Meditation", const TimeDuration(minutes: 15)),
  TimerPreset("Sleep", const TimeDuration(hours: 5)),
];
