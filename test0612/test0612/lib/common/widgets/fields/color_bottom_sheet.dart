// import 'package:clock_app/common/widgets/color_picker/color_picker.dart';
import 'package:clock_app/common/widgets/color_picker/picker_selector.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorBottomSheet extends StatefulWidget {
  const ColorBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.value,
    required this.onChange,
    this.enableOpacity = false,      
  });

  final String title;
  final String? description;
  final Color value;
  final void Function(Color)? onChange;
  final bool enableOpacity;

  @override
  State<ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<ColorBottomSheet> {
  late Color _color = widget.value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    BorderRadiusGeometry borderRadius = theme.cardTheme.shape != null
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
        : BorderRadius.circular(8.0);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius,
        ),
        child: Wrap(
          children: [
            Column(
              children: [
                const SizedBox(height: 12.0),
                SizedBox(
                  height: 4.0,
                  width: 48,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(64),
                        color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      if (widget.description != null)
                        const SizedBox(height: 8.0),
                      if (widget.description != null)
                        Text(
                          widget.description!,
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                    ],
                  ),
                ),
                // const SizedBox(height: 16.0),
                ColorPicker(
                    wheelDiameter: MediaQuery.of(context).size.width - (widget.enableOpacity ? 64 : 32),
                    color: _color,
                    onColorChanged: (Color color) => setState(() {
                          _color = color;
                        }),
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    width: 44,
                    height: 44,
                    borderRadius:
                        theme.toggleButtonsTheme.borderRadius?.bottomLeft.x,
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: false,
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: false,
                      ColorPickerType.bw: false,
                      ColorPickerType.custom: false,
                      ColorPickerType.wheel: true,
                    },
                    enableShadesSelection: true,
                    subheading: Text('Shade',
                        style: textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurface)),
                    showColorCode: true,
                    enableOpacity: widget.enableOpacity,
                    opacityTrackHeight: 20,
                    opacityThumbRadius: 14,
                    copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                        copyFormat: ColorPickerCopyFormat.hexRRGGBB),
                    customPickerSelectBuilder:
                        (pickers, pickerLabels, activePicker, onPickerChanged) {
                      return PickerSelector(
                          pickers: pickers,
                          picker: activePicker,
                          onPickerChanged: onPickerChanged);
                    }

                    // subheading: Text(
                    //   'Select color shade',
                    //   style: Theme.of(context).textTheme.titleSmall,
                    // ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onChange?.call(_color);
                        },
                        child: Text(
                          'Save',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
