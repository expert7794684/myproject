import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:clock_app/alarm/logic/alarm_isolate.dart';
import 'package:clock_app/alarm/logic/alarm_reminder_notifications.dart';
import 'package:clock_app/alarm/types/alarm_event.dart';
import 'package:clock_app/common/types/notification_type.dart';
import 'package:clock_app/common/types/schedule_id.dart';
import 'package:clock_app/common/utils/date_time.dart';
import 'package:clock_app/common/utils/list_storage.dart';
import 'package:clock_app/common/utils/time_of_day.dart';
import 'package:clock_app/developer/logic/logger.dart';
import 'package:clock_app/settings/data/settings_schema.dart';

Future<void> scheduleAlarm(
  int scheduleId,
  DateTime startDate,
  String description, {
  ScheduledNotificationType type = ScheduledNotificationType.alarm,
  bool alarmClock = true,
  bool snooze = false,
}) async {
  DateTime now = DateTime.now();
  if (startDate.isBefore(now)) {
    throw Exception(
        'Attempted to schedule alarm in the past. Schedule time: $startDate, current time: $now');
  }

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    // await cancelAlarm(scheduleId, type);
    List<AlarmEvent> alarmEvents = await loadList<AlarmEvent>('alarm_events');
    for (var event in alarmEvents) {
      if (event.scheduleId == scheduleId) {
        event.isActive = false;
      }
    }

    String name = type == ScheduledNotificationType.alarm
        ? 'alarm_schedule_ids'
        : 'timer_schedule_ids';
    List<ScheduleId> scheduleIds = await loadList<ScheduleId>(name);
    scheduleIds.removeWhere((id) => id.id == scheduleId);
    //
    // if (type == ScheduledNotificationType.alarm) {
    //   await cancelAlarmReminderNotification(scheduleId);
    // }

    AndroidAlarmManager.cancel(scheduleId);

    // This is for logging purposes
    alarmEvents.insert(
        0,
        AlarmEvent(
          scheduleId: scheduleId,
          description: description,
          startDate: startDate,
          eventTime: DateTime.now(),
          notificationType: type,
          isActive: true,
        ));
    int maxLogs = appSettings
        .getGroup('Developer Options')
        .getSetting('Max logs')
        .value
        .floor();
    while (alarmEvents.length > maxLogs) {
      alarmEvents.removeLast();
    }
    await saveList<AlarmEvent>('alarm_events', alarmEvents);

    // We store all scheduled ids so we can cancel them all if needed
    scheduleIds.add(ScheduleId(id: scheduleId));
    await saveList<ScheduleId>(name, scheduleIds);

    //
    // if (type == ScheduledNotificationType.alarm && !snooze) {
    // }
    //
    // Scheduling the actual alarm
    AndroidAlarmManager.oneShotAt(
      startDate,
      scheduleId,
      triggerScheduledNotification,
      allowWhileIdle: true,
      alarmClock: alarmClock,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: <String, String>{
        'scheduleId': scheduleId.toString(),
        'timeOfDay': startDate.toTimeOfDay().encode(),
        'type': type.name,
      },
    );

    logger.t(
        'Scheduled alarm $scheduleId for $startDate of type ${type.name}: $description');
  }
}

Future<void> cancelAlarm(int scheduleId, ScheduledNotificationType type) async {
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    List<AlarmEvent> alarmEvents = await loadList<AlarmEvent>('alarm_events');
    for (var event in alarmEvents) {
      if (event.scheduleId == scheduleId) {
        event.isActive = false;
      }
    }
    await saveList<AlarmEvent>('alarm_events', alarmEvents);

    String name = type == ScheduledNotificationType.alarm
        ? 'alarm_schedule_ids'
        : 'timer_schedule_ids';
    List<ScheduleId> scheduleIds = await loadList<ScheduleId>(name);
    scheduleIds.removeWhere((id) => id.id == scheduleId);
    await saveList<ScheduleId>(name, scheduleIds);

    if (type == ScheduledNotificationType.alarm) {
      await cancelAlarmReminderNotification(scheduleId);
    }

    AndroidAlarmManager.cancel(scheduleId);

    logger.i('Canceled alarm $scheduleId of type ${type.name}');
  }
}

enum AlarmStopAction {
  dismiss,
  snooze,
}

Future<void> scheduleSnoozeAlarm(int scheduleId, Duration delay,
    ScheduledNotificationType type, String description) async {
  await scheduleAlarm(scheduleId, DateTime.now().add(delay), description,
      type: type, snooze: true);
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    await createSnoozeNotification(scheduleId, DateTime.now().add(delay));
  }

  logger.t(
      'Scheduled snooze alarm $scheduleId for ${DateTime.now().add(delay)} with type ${type.name}: $description');
}
