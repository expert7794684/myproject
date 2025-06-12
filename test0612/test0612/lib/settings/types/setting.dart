import 'package:clock_app/common/types/json.dart';
import 'package:clock_app/common/types/list_item.dart';
import 'package:clock_app/common/types/popup_action.dart';
import 'package:clock_app/common/utils/json_serialize.dart';
import 'package:clock_app/common/utils/list.dart';
import 'package:clock_app/common/utils/list_item.dart';
import 'package:clock_app/settings/types/setting_enable_condition.dart';
import 'package:clock_app/settings/types/setting_item.dart';
import 'package:clock_app/settings/utils/description.dart';
import 'package:clock_app/timer/types/time_duration.dart';
import 'package:flutter/material.dart';

abstract class Setting<T> extends SettingItem {
  T _value;
  final T _defaultValue;

  // Whether another setting depends on the value of this setting
  bool changesEnableCondition;
  void Function(BuildContext context, T)? onChange;
  // Whether to show this setting in settings screen
  final bool isVisual;

  final T Function(T)? _valueCopyGetter;

  Setting(
    String name,
    String Function(BuildContext) getLocalizedName,
    String Function(BuildContext) description,
    T defaultValue,
    this.onChange,
    List<EnableConditionParameter> enableConditions,
    List<String> searchTags,
    this.isVisual, {
    T Function(T)? valueCopyGetter,
  })  : _value = valueCopyGetter?.call(defaultValue) ?? defaultValue,
        _defaultValue = valueCopyGetter?.call(defaultValue) ?? defaultValue,
        changesEnableCondition = false,
        _valueCopyGetter = valueCopyGetter,
        super(
            name, getLocalizedName, description, searchTags, enableConditions);

  void setValue(BuildContext context, T value) {
    _value = _valueCopyGetter?.call(value) ?? value;
    callListeners(this);
    onChange?.call(context, value);
  }

  void restoreDefault(BuildContext context) {
    setValue(context, _defaultValue);
  }

  void setValueWithoutNotify(T value) {
    _value = _valueCopyGetter?.call(value) ?? value;
  }

  dynamic get value => _value;
  dynamic get defaultValue => _defaultValue;

  @override
  dynamic valueToJson() {
    return _value;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null || value is! T) return;
    _value = value;
  }
}

class CustomizableListSetting<T extends CustomizableListItem>
    extends Setting<List<T>> {
  List<T> possibleItems;
  Widget Function(T item, [VoidCallback?, VoidCallback?]) cardBuilder;
  Widget Function(T item) addCardBuilder;
  Widget Function(T item)? itemPreviewBuilder;
  // The widget that will be used to display the value of this setting.
  Widget Function(BuildContext context, CustomizableListSetting<T> setting)
      valueDisplayBuilder;

  CustomizableListSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    List<T> defaultValue,
    this.possibleItems, {
    required this.cardBuilder,
    required this.valueDisplayBuilder,
    required this.addCardBuilder,
    this.itemPreviewBuilder,
    String Function(BuildContext) getDescription = defaultDescription,
    void Function(BuildContext, List<T>)? onChange,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(
          name,
          getLocalizedName,
          getDescription,
          copyItemList(defaultValue),
          onChange,
          enableConditions,
          searchTags,
          isVisual,
          valueCopyGetter: copyItemList,
        );

  @override
  CustomizableListSetting<T> copy() {
    return CustomizableListSetting<T>(
      name,
      getLocalizedName,
      _value,
      possibleItems,
      valueDisplayBuilder: valueDisplayBuilder,
      cardBuilder: cardBuilder,
      addCardBuilder: addCardBuilder,
      getDescription: getDescription,
      onChange: onChange,
      enableConditions: enableConditions,
      isVisual: isVisual,
      itemPreviewBuilder: itemPreviewBuilder,
      searchTags: searchTags,
    );
  }

  Widget getValueDisplayWidget(BuildContext context) {
    return valueDisplayBuilder(context, this);
  }

  Widget getItemAddCard(T item) {
    return addCardBuilder(item);
  }

  Widget getItemCard(T item,
      {VoidCallback? onDelete, VoidCallback? onDuplicate}) {
    return cardBuilder(item, onDelete, onDuplicate);
  }

  Widget? getPreviewCard(T item) {
    return itemPreviewBuilder?.call(item);
  }

  @override
  dynamic valueToJson() {
    return _value.map((e) => e.toJson()).toList();
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    _value = (value as List).map((e) => fromJsonFactories[T]!(e) as T).toList();
  }
}

class ListSetting<T extends ListItem> extends Setting<List<T>> {
  List<T> possibleItems;
  Widget Function(T item, [VoidCallback?, VoidCallback?]) cardBuilder;
  Widget Function(T item) addCardBuilder;
  // The widget that will be used to display the value of this setting.

  ListSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    List<T> defaultValue,
    this.possibleItems, {
    required this.cardBuilder,
    required this.addCardBuilder,
    String Function(BuildContext) getDescription = defaultDescription,
    void Function(BuildContext, List<T>)? onChange,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(
          name,
          getLocalizedName,
          getDescription,
          copyItemList(defaultValue),
          onChange,
          enableConditions,
          searchTags,
          isVisual,
          valueCopyGetter: copyItemList,
        );

  @override
  ListSetting<T> copy() {
    return ListSetting<T>(
      name,
      getLocalizedName,
      _value,
      possibleItems,
      cardBuilder: cardBuilder,
      addCardBuilder: addCardBuilder,
      getDescription: getDescription,
      onChange: onChange,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }

  Widget getItemAddCard(T item) {
    return addCardBuilder(item);
  }

  Widget getItemCard(T item,
      {VoidCallback? onDelete, VoidCallback? onDuplicate}) {
    return cardBuilder(item, onDelete, onDuplicate);
  }

  @override
  dynamic valueToJson() {
    return _value.map((e) => e.toJson()).toList();
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    _value = (value as List).map((e) => fromJsonFactories[T]!(e) as T).toList();
  }
}

class CustomSetting<T extends JsonSerializable> extends Setting<T> {
  // The screen that will be navigated to when this setting is tapped.
  Widget Function(BuildContext, CustomSetting<T>) screenBuilder;
  // The widget that will be used to display the value of this setting.
  Widget Function(BuildContext, CustomSetting<T>) valueDisplayBuilder;
  T Function(T)? copyValue;

  CustomSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    T defaultValue,
    this.screenBuilder,
    this.valueDisplayBuilder, {
    String Function(BuildContext) getDescription = defaultDescription,
    void Function(BuildContext, T)? onChange,
    this.copyValue,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual) {
    copyValue ??= (T value) => value;
  }

  Widget getScreenBuilder(BuildContext context) {
    return screenBuilder(context, this);
  }

  Widget getValueDisplayWidget(BuildContext context) {
    return valueDisplayBuilder(context, this);
  }

  @override
  CustomSetting<T> copy() {
    return CustomSetting<T>(
      name,
      getLocalizedName,
      copyValue?.call(_value) ?? _value,
      screenBuilder,
      valueDisplayBuilder,
      getDescription: getDescription,
      onChange: onChange,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      copyValue: copyValue,
    );
  }

  @override
  dynamic valueToJson() {
    return _value.toJson();
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null || value is! Json) return;
    _value = fromJsonFactories[T]!(value);
  }
}

class SwitchSetting extends Setting<bool> {
  SwitchSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    bool defaultValue, {
    void Function(BuildContext, bool)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  SwitchSetting copy() {
    return SwitchSetting(
      name,
      getLocalizedName,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }
}

class NumberSetting extends Setting<double> {
  NumberSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    double defaultValue, {
    void Function(BuildContext, double)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  NumberSetting copy() {
    return NumberSetting(
      name,
      getLocalizedName,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }
}

class ColorSetting extends Setting<Color> {
  final bool enableOpacity;

  ColorSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    Color defaultValue, {
    void Function(BuildContext, Color)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    this.enableOpacity = false,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  dynamic valueToJson() {
    return _value.value;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null || value is! int) return;
    _value = Color(value);
  }

  @override
  ColorSetting copy() {
    return ColorSetting(
      name,
      getLocalizedName,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      enableOpacity: enableOpacity,
    );
  }
}

class StringSetting extends Setting<String> {
  StringSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    String defaultValue, {
    void Function(BuildContext, String)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  StringSetting copy() {
    return StringSetting(
      name,
      getLocalizedName,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }
}

class SliderSetting extends Setting<double> {
  final double min;
  final double max;
  final bool maxIsInfinity;
  final double? snapLength;
  final String unit;

  SliderSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this.min,
    this.max,
    double defaultValue, {
    void Function(BuildContext context, double)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    this.maxIsInfinity = false,
    this.snapLength,
    this.unit = "",
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  // @override
  // dynamic get value =>
  //     (maxIsInfinity && _value >= max - 0.0001) ? double.infinity : _value;

  @override
  SliderSetting copy() {
    return SliderSetting(
      name,
      getLocalizedName,
      min,
      max,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      snapLength: snapLength,
      maxIsInfinity: maxIsInfinity,
      enableConditions: enableConditions,
      unit: unit,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }
}

class SelectSetting<T> extends Setting<int> {
  final List<SelectSettingOption<T>> _options;
  final List<MenuAction> actions;

  List<SelectSettingOption<T>> get options => _options;
  int get selectedIndex => _value;
  @override
  dynamic get value => options[selectedIndex].value;
  // bool get isColor => T == Color;

  int getIndexOfValue(T value) {
    int index = options.indexWhere((element) => element.value == value);
    return index == -1 ? 0 : index;
  }

  T getValueOfIndex(int index) {
    if (index < 0 || index >= options.length) index = 0;
    return options[index].value;
  }

  @override
  void restoreDefault(BuildContext context) {
    setValue(context, _defaultValue);
  }

  SelectSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this._options, {
    void Function(BuildContext, int)? onChange,
    int defaultValue = 0,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
    this.actions = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  SelectSetting<T> copy() {
    return SelectSetting(
      name,
      getLocalizedName,
      _options,
      defaultValue: _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      actions: actions,
    );
  }
}

// DynamicSelectSetting uses item id as its _value, instead of the index.
// This is so that if the options changes, the value remains the same;
class DynamicSelectSetting<T extends ListItem> extends Setting<int> {
  List<SelectSettingOption<T>> Function() optionsGetter;
  final List<MenuAction> actions;
  List<SelectSettingOption<T>> get options => optionsGetter();
  @override
  dynamic get value => options[selectedIndex].value;
  int get selectedIndex => getIndexOfId(_value);

  DynamicSelectSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this.optionsGetter, {
    void Function(BuildContext, int)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    int defaultValue = -1,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
    this.actions = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual) {
    if (defaultValue != -1) {
      _value = defaultValue;
    }
  }

  @override
  DynamicSelectSetting<T> copy() {
    return DynamicSelectSetting(
      name,
      getLocalizedName,
      optionsGetter,
      onChange: onChange,
      defaultValue: _value,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      actions: actions,
    );
  }

  void setIndex(BuildContext context, int index) {
    setValue(context, getIdAtIndex(index));
  }

  @override
  void restoreDefault(BuildContext context) {
    setIndex(context, 0);
  }

  int getIndexOfValue(T value) {
    return getIndexOfId(value.id);
  }

  int getIndexOfId(int id) {
    int index = options.indexWhere((element) => element.value.id == id);
    return index == -1 ? 0 : index;
  }

  int getIdAtIndex(int index) {
    final settingsOptions = optionsGetter();
    if (settingsOptions.isEmpty) return -1;
    if (index < 0 || index >= settingsOptions.length) index = 0;
    return settingsOptions[index].value.id;
  }

  @override
  dynamic valueToJson() {
    return _value;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null || value is! int) return;
    // If the value is no longer in the options, return the first option
    // If options is empty, set id to -1
    if (getIndexOfId(value) == -1) value = getIdAtIndex(0);
    _value = value;
  }
}

class MultiSelectSetting<T> extends Setting<List<int>> {
  final List<SelectSettingOption<T>> _options;
  final List<MenuAction> actions;

  List<SelectSettingOption<T>> get options => _options;
  List<int> get selectedIndices => _value;
  @override
  dynamic get value => options
      .where((option) => _value.contains(options.indexOf(option)))
      .map((option) => option.value)
      .toList();
  // bool get isColor => T == Color;

  int getIndexOfValue(T value) {
    int index = options.indexWhere((element) => element.value == value);
    return index == -1 ? 0 : index;
  }

  T getValueOfIndex(int index) {
    if (index < 0 || index >= options.length) index = 0;
    return options[index].value;
  }

  @override
  void restoreDefault(BuildContext context) {
    setValue(context, _defaultValue);
  }

  MultiSelectSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this._options, {
    void Function(BuildContext, List<int>)? onChange,
    List<int> defaultValue = const [0],
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
    this.actions = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  MultiSelectSetting<T> copy() {
    return MultiSelectSetting(
      name,
      getLocalizedName,
      _options,
      defaultValue: _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      actions: actions,
    );
  }

  @override
  dynamic valueToJson() {
    return _value;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    _value = (value as List).map((index) => index as int).toList();
  }
}

// DynamicSelectSetting uses item id as its _value, instead of the index.
// This is so that if the options changes, the value remains the same;
class DynamicMultiSelectSetting<T extends ListItem> extends Setting<List<int>> {
  List<SelectSettingOption<T>> Function() optionsGetter;
  final List<MenuAction> actions;

  List<SelectSettingOption<T>> get options => optionsGetter();
  @override
  dynamic get value {
    return selectedIndices.map((index) => options[index].value).toList();
  }

  List<int> get selectedIndices => _value
      .map((id) => getIndexOfId(id))
      .where((index) => index >= 0)
      .toList();

  DynamicMultiSelectSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this.optionsGetter, {
    void Function(BuildContext, List<int>)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    List<int> defaultValue = const [-1],
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
    this.actions = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual) {
    if (!defaultValue.contains(-1)) {
      _value = defaultValue;
    }
  }

  @override
  DynamicMultiSelectSetting<T> copy() {
    return DynamicMultiSelectSetting(
      name,
      getLocalizedName,
      optionsGetter,
      onChange: onChange,
      defaultValue: _value,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
      actions: actions,
    );
  }

  void setIndex(BuildContext context, List<int> indices) {
    setValue(context, indices.map((index) => getIdAtIndex(index)).toList());
  }

  @override
  void restoreDefault(BuildContext context) {
    setIndex(context, []);
  }

  int getIndexOfValue(T value) {
    return getIndexOfId(value.id);
  }

  int getIndexOfId(int id) {
    int index = options.indexWhere((element) => element.value.id == id);
    return index;
  }

  int getIdAtIndex(int index) {
    final settingsOptions = optionsGetter();
    if (settingsOptions.isEmpty) return -1;
    if (index < 0 || index >= settingsOptions.length) index = 0;
    return settingsOptions[index].value.id;
  }

  @override
  dynamic valueToJson() {
    return _value;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    // If the value is no longer in the options, return the first option
    // If options is empty, set id to -1
    (value as List).removeWhere((id) => getIndexOfId(id) == -1);
    _value = value.map((id) => id as int).toList();
  }
}

class DynamicToggleSetting<T extends ListItem>
    extends DynamicMultiSelectSetting<T> {
  List<bool> get selectedIndicesBool {
    final _selectedIndices = selectedIndices;
    return List.generate(
        options.length, (index) => _selectedIndices.contains(index));
  }

  List<T> get selected => value;

  List<int> get selectedIds => _value;

  DynamicToggleSetting(
    super.name,
    super.getLocalizedName,
    super.optionsGetter, {
    super.onChange,
    super.getDescription,
    super.defaultValue,
    super.isVisual,
    super.enableConditions,
    super.searchTags,
  }) {
    if (defaultValue.contains(-1) || defaultValue.isEmpty) {
      final _options = optionsGetter();
      _value = [_options[0].value.id];
    }
  }

  @override
  DynamicToggleSetting<T> copy() {
    return DynamicToggleSetting(
      name,
      getLocalizedName,
      optionsGetter,
      onChange: onChange,
      defaultValue: _value,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }

  void toggle(BuildContext context, int index) {
    int id = getIdAtIndex(index);
    // We want atleast 1 item selected
    if (_value.length == 1 && _value.contains(id)) {
      return;
    }
    if (_value.contains(id)) {
      _value.remove(id);
    } else {
      _value.add(id);
    }
    setValue(context, _value);
  }

  @override
  int getIndexOfId(int id) {
    int index = options.indexWhere((element) => element.value.id == id);
    return index == -1 ? 0 : index;
  }
}

class ToggleSetting<T> extends Setting<List<bool>> {
  final List<ToggleSettingOption<T>> _options;
  int Function()? getOffset;

  @override
  dynamic get value {
    int offset = getOffset?.call() ?? 0;
    return _value.rotate(offset);
  }

  List<T> get selected {
    List<T> values = [];
    for (int i = 0; i < _value.length; i++) {
      if (_value[i]) {
        values.add(_options[i].value);
      }
    }
    return values;
  }

  List<ToggleSettingOption<T>> get options {
    int offset = getOffset?.call() ?? 0;
    return _options.rotate(offset);
  }

  ToggleSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    this._options, {
    void Function(BuildContext, List<bool>)? onChange,
    List<bool> defaultValue = const [],
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    this.getOffset,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(
          name,
          getLocalizedName,
          getDescription,
          defaultValue.length == _options.length
              ? List.from(defaultValue)
              : List.generate(_options.length, (index) => index == 0),
          onChange,
          enableConditions,
          searchTags,
          isVisual,
          valueCopyGetter: List.from,
        );

  @override
  ToggleSetting<T> copy() {
    return ToggleSetting(
      name,
      getLocalizedName,
      _options,
      defaultValue: _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      getOffset: getOffset,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }

  void toggle(BuildContext context, int index) {
    int offset = getOffset?.call() ?? 0;

    // Add offset to index, if overflow, wrap around
    index = (index + offset) % _options.length;

    if (_value.where((option) => option == true).length == 1 && _value[index]) {
      return;
    }
    _value[index] = !_value[index];
    setValue(context, _value);
  }

  @override
  dynamic valueToJson() {
    return _value.map((e) => e ? "1" : "0").toList();
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    _value = (value as List).map((e) => e == "1").toList();
  }
}

class DateTimeSetting extends Setting<List<DateTime>> {
  final bool rangeOnly;

  DateTimeSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    List<DateTime> defaultValue, {
    this.rangeOnly = false,
    void Function(BuildContext, List<DateTime>)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(
          name,
          getLocalizedName,
          getDescription,
          defaultValue,
          onChange,
          enableConditions,
          searchTags,
          isVisual,
          valueCopyGetter: List.from,
        );

  @override
  DateTimeSetting copy() {
    return DateTimeSetting(
      name,
      getLocalizedName,
      _value,
      rangeOnly: rangeOnly,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }

  @override
  dynamic valueToJson() {
    return _value.map((e) => e.millisecondsSinceEpoch).toList();
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null) return;
    _value = (value as List)
        .map((e) => DateTime.fromMillisecondsSinceEpoch(e))
        .toList();
  }

  void addDateTime(BuildContext context, DateTime dateTime) {
    _value.add(dateTime);
    onChange?.call(context, _value);
  }

  void removeDateTime(BuildContext context, DateTime dateTime) {
    _value.remove(dateTime);
    onChange?.call(context, _value);
  }
}

class DurationSetting extends Setting<TimeDuration> {
  DurationSetting(
    String name,
    String Function(BuildContext) getLocalizedName,
    TimeDuration defaultValue, {
    void Function(BuildContext, TimeDuration)? onChange,
    String Function(BuildContext) getDescription = defaultDescription,
    bool isVisual = true,
    List<EnableConditionParameter> enableConditions = const [],
    List<String> searchTags = const [],
  }) : super(name, getLocalizedName, getDescription, defaultValue, onChange,
            enableConditions, searchTags, isVisual);

  @override
  DurationSetting copy() {
    return DurationSetting(
      name,
      getLocalizedName,
      _value,
      onChange: onChange,
      getDescription: getDescription,
      enableConditions: enableConditions,
      isVisual: isVisual,
      searchTags: searchTags,
    );
  }

  @override
  dynamic valueToJson() {
    return _value.inMilliseconds;
  }

  @override
  void loadValueFromJson(dynamic value) {
    if (value == null || value is! int) return;
    _value = TimeDuration.fromMilliseconds(value);
  }
}

class ToggleSettingOption<T> {
  String Function(BuildContext) getLocalizedName;
  T value;

  ToggleSettingOption(this.getLocalizedName, this.value);
}

class SelectSettingOption<T> {
  String Function(BuildContext) getDescription;
  String Function(BuildContext) getLocalizedName;
  T value;

  SelectSettingOption(this.getLocalizedName, this.value,
      {this.getDescription = defaultDescription});
}
