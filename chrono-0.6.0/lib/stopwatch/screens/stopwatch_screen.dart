import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clock_app/common/types/list_controller.dart';
import 'package:clock_app/common/utils/list_storage.dart';
import 'package:clock_app/common/widgets/card_container.dart';
import 'package:clock_app/common/widgets/list/custom_list_view.dart';
import 'package:clock_app/common/widgets/fab.dart';
import 'package:clock_app/notifications/data/notification_channel.dart';
import 'package:clock_app/notifications/data/update_notification_intervals.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/settings/types/listener_manager.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:clock_app/stopwatch/logic/stopwatch_notification.dart';
import 'package:clock_app/stopwatch/types/lap.dart';
import 'package:clock_app/stopwatch/types/stopwatch.dart';
import 'package:clock_app/stopwatch/widgets/lap_card.dart';
import 'package:clock_app/stopwatch/widgets/stopwatch_ticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final _listController = ListController<Lap>();

  late Setting _showNotificationSetting;

  late final ClockStopwatch _stopwatch;

  void update(dynamic value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final stopwatches = loadListSync<ClockStopwatch>('stopwatches');
    if (stopwatches.isEmpty) {
      _stopwatch = ClockStopwatch();
      saveList('stopwatches', [_stopwatch]);
    } else {
      _stopwatch = stopwatches.first;
    }

    _showNotificationSetting =
        appSettings.getGroup("Stopwatch").getSetting("Show Notification");

    ListenerManager.addOnChangeListener('stopwatch', _handleStopwatchChange);

    if (_stopwatch.isRunning) {
      showProgressNotification();
    }
  }

  void _handleStopwatchChange() {
    final newList = loadListSync<ClockStopwatch>('stopwatches');
    _stopwatch.copyFrom(newList.first);

    if (mounted) {
      // // If there are any new laps, tell the listcontroller to update the ui with them
      // newList.first.laps
      //     .where((lap) =>
      //         !_stopwatch.laps.map((l) => l.number).contains(lap.number))
      //     .forEach((lap) => _listController.addItem(lap));

      _listController.reload(_stopwatch.laps);
      setState(() {});
    }
    showProgressNotification();
  }

  @override
  void dispose() {
    // updateNotificationInterval?.cancel();
    // updateNotificationInterval = null;

    super.dispose();
  }

  void _handleReset() {
    setState(() {
      _stopwatch.pause();
      _stopwatch.reset();
    });
    _listController.clearItems();
    saveList('stopwatches', [_stopwatch]);

    showProgressNotification();
  }

  void _handleAddLap() {
    if (_stopwatch.currentLapTime.inMilliseconds == 0) return;
    _stopwatch.finishLap(_stopwatch.laps.first);
    _listController.changeItems((laps) => {});
    _listController.addItem(_stopwatch.getLap());
    saveList('stopwatches', [_stopwatch]);
    showProgressNotification();
  }

  void _handleToggleState() {
    if (_stopwatch.isStopped) {
      _listController.addItem(_stopwatch.getLap());
    }
    setState(() {
      _stopwatch.toggleState();
    });

    saveList('stopwatches', [_stopwatch]);
    if (_stopwatch.isRunning) {
      showProgressNotification();
    } else {
      stopwatchNotificationInterval?.cancel();
      showProgressNotification();
    }
  }

  Future<void> showProgressNotification() async {
    if (!_showNotificationSetting.value) {
      AwesomeNotifications()
          .cancelNotificationsByChannelKey(stopwatchNotificationChannelKey);
      stopwatchNotificationInterval?.cancel();
      return;
    }
    updateStopwatchNotification(_stopwatch);
    stopwatchNotificationInterval?.cancel();
    if (!_stopwatch.isStarted) {
      AwesomeNotifications()
          .cancelNotificationsByChannelKey(stopwatchNotificationChannelKey);
    } else {
      stopwatchNotificationInterval =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        updateStopwatchNotification(_stopwatch);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 0.5;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StopwatchTicker(stopwatch: _stopwatch),
            const SizedBox(height: 8),
            Expanded(
              child: CustomListView<Lap>(
                items: _stopwatch.laps,
                listController: _listController,
                itemBuilder: (lap) => lap.isActive
                    ? ActiveLapCard(stopwatch: _stopwatch)
                    : LapCard(
                        key: ValueKey(lap),
                        lap: lap,
                      ),
                placeholderText: AppLocalizations.of(context)!.noLapsMessage,
                isDeleteEnabled: false,
                isDuplicateEnabled: false,
                isReorderable: false,
                onAddItem: (lap) => _stopwatch.updateFastestAndSlowestLap(),
              ),
            ),
          ],
        ),
        FAB(
          onPressed: _handleToggleState,
          icon: _stopwatch.isRunning
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          size: 2,
        ),
        if (_stopwatch.isStarted)
          FAB(
            index: 1,
            onPressed: _handleAddLap,
            icon: Icons.flag_rounded,
            size: 2,
          ),
        if (_stopwatch.isStarted)
          FAB(
            index: 0,
            position: FabPosition.bottomLeft,
            onPressed: _handleReset,
            icon: Icons.refresh_rounded,
            size: 1,
          ),
      ],
    );
  }
}
