import 'dart:async';

import 'package:clock_app/common/types/popup_action.dart';
import 'package:clock_app/common/utils/popup_action.dart';
import 'package:clock_app/common/widgets/card_edit_menu.dart';
import 'package:clock_app/timer/types/time_duration.dart';
import 'package:clock_app/timer/types/timer.dart';
import 'package:clock_app/timer/widgets/timer_progress_bar.dart';
import 'package:flutter/material.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({
    super.key,
    required this.timer,
    required this.onToggleState,
    required this.onPressDelete,
    required this.onPressDuplicate,
    required this.onPressReset,
    required this.onPressAddTime,
  });

  final ClockTimer timer;
  final VoidCallback onToggleState;
  final VoidCallback onPressDelete;
  final VoidCallback onPressDuplicate;
  final VoidCallback onPressReset;
  final VoidCallback onPressAddTime;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  late ValueNotifier<double> valueNotifier;
  late ClockTimer _previousTimer;

  late int remainingSeconds;

  Timer? periodicTimer;

  void updateTimer() {
    setState(() {
      periodicTimer?.cancel();
      if (widget.timer.isRunning) {
        periodicTimer =
            Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          valueNotifier.value = widget.timer.remainingSeconds.toDouble();
        });
      }
      valueNotifier.value = widget.timer.remainingSeconds.toDouble();
    });
  }

  @override
  void initState() {
    super.initState();
    // if (GetStorage().read('first_timer_created') == false) {
    //   GetStorage().write('first_timer_created', true);
    //   showEditTip(context, () => mounted);
    // }
    valueNotifier = ValueNotifier(widget.timer.remainingSeconds.toDouble());
    remainingSeconds = widget.timer.remainingSeconds;
    valueNotifier.addListener(() {
      setState(() {
        remainingSeconds = valueNotifier.value.toInt();
      });
    });
    updateTimer();
    _previousTimer = ClockTimer.from(widget.timer);
  }

  @override
  void dispose() {
    periodicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    if (!_previousTimer.equals(widget.timer)) {
      updateTimer();
      _previousTimer = ClockTimer.from(widget.timer);
    }

    return Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 8.0, top: 16.0, bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimerProgressBar(
                timer: widget.timer,
                size: 50,
                centerWidget: GestureDetector(
                  onTap: () {
                    widget.onToggleState();
                    updateTimer();
                  },
                  child: widget.timer.isRunning
                      ? Icon(
                          Icons.pause_rounded,
                          color: colorScheme.primary,
                          size: 32,
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          size: 32,
                        ),
                )),
            const SizedBox(width: 16),
            Expanded(
              flex: 999,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.timer.label,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  Text(
                    TimeDuration.fromSeconds(remainingSeconds).toTimeString(),
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: remainingSeconds > 3600 ? 28 : 40,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CardEditMenu(actions: [
              if (!widget.timer.isStopped)
                MenuAction(
                  "Reset",
                  (context) => widget.onPressReset(),
                  Icons.replay_rounded,
                ),
              if (!widget.timer.isStopped)
                MenuAction(
                  '+${widget.timer.addLength.floor()}:00',
                  (context) => widget.onPressAddTime(),
                  Icons.add_rounded,
                ),
              getDuplicatePopupAction(context, widget.onPressDuplicate),
              getDeletePopupAction(context, widget.onPressDelete),
            ]),
          ],
        ));
  }
}
