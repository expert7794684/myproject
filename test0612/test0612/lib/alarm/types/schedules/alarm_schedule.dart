import 'package:clock_app/alarm/types/alarm_runner.dart';
import 'package:clock_app/common/types/json.dart';
import 'package:clock_app/common/types/time.dart';

abstract class AlarmSchedule extends JsonSerializable {
  DateTime? get currentScheduleDateTime;
  int get currentAlarmRunnerId;
  bool get isDisabled;
  bool get isFinished;

  AlarmSchedule();

  List<AlarmRunner> get alarmRunners;
  Future<void> schedule(
    Time time,
    String description, [
    bool alarmClock = false,
  ]);
  Future<void> cancel();
  bool hasId(int id);
}
