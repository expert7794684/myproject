import 'package:clock_app/common/types/select_choice.dart';
import 'package:clock_app/common/widgets/fields/select_field/option_cards/text_option_card.dart';
import 'package:clock_app/common/widgets/fields/select_field/select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const title = 'Test';
final choices = [
  const SelectChoice(
      name: "Test1", value: "Test1", description: "Test1Description"),
  const SelectChoice(
      name: "Test2", value: "Test2", description: "Test2Description"),
  const SelectChoice(
      name: "Test3", value: "Test3", description: "Test3Description"),
];

void main() {
  group('SelectField', () {
    group('shows select field', () {
      testWidgets('title correctly', (tester) async {
        await _renderWidget(tester);
        final nameFinder = find.text(title);
        expect(nameFinder, findsOneWidget);
      });
      group('value correctly', () {
        testWidgets('before value changed', (tester) async {
          const selectedIndex = 0;
          await _renderWidget(tester, selectedIndex: selectedIndex);
          final valueFinder = find.text(choices[selectedIndex].name);
          expect(valueFinder, findsOneWidget);
        });
        testWidgets('after value changed', (tester) async {
          int selectedIndex = 1;
          await _renderWidget(tester,
              selectedIndex: selectedIndex,
              onChanged: (indices) => selectedIndex = indices[0]);
          await tester.tap(find.byType(SelectField));
          await tester.pumpAndSettle();
          final valueFinder = find.byType(SelectTextOptionCard);
          expect(valueFinder, findsNWidgets(choices.length));
          await tester.tap(valueFinder.at(2));
          await tester.pumpAndSettle();
          await _renderWidget(tester,
              selectedIndex: selectedIndex,
              onChanged: (indices) => selectedIndex = indices[0]);
          final newValueFinder = find.text(choices[2].name);
          expect(newValueFinder, findsOneWidget);
        });
      });
    });
    group('shows bottom sheet', () {
      testWidgets("when tapped", (tester) async {
        await _renderWidget(tester);
        await tester.tap(find.byType(SelectField));
        await tester.pumpAndSettle();
        final bottomSheetFinder = find.byType(BottomSheet);
        expect(bottomSheetFinder, findsOneWidget);
      });
      testWidgets('title correctly', (tester) async {
        await _renderWidget(tester);
        await tester.tap(find.byType(SelectField));
        await tester.pumpAndSettle();
        final titleFinder = find.descendant(
            of: find.byType(BottomSheet), matching: find.text(title));
        expect(titleFinder, findsOneWidget);
      });
      group('choices', () {
        testWidgets('title correctly', (tester) async {
          await _renderWidget(tester);
          await tester.tap(find.byType(SelectField));
          await tester.pumpAndSettle();
          for (var i = 0; i < choices.length; i++) {
            final valueFinder = find.descendant(
                of: find.byType(BottomSheet),
                matching: find.text(choices[i].value));
            expect(valueFinder, findsOneWidget);
          }
        });
        testWidgets('description correctly', (tester) async {
          await _renderWidget(
            tester,
          );
          await tester.tap(find.byType(SelectField));
          await tester.pumpAndSettle();
          for (var i = 0; i < choices.length; i++) {
            final valueFinder = find.descendant(
                of: find.byType(BottomSheet),
                matching: find.text(choices[i].description));
            expect(valueFinder, findsOneWidget);
          }
        });
        group('radio selection correctly', () {
          testWidgets('with default value', (tester) async {
            int selectedIndex = 1;
            await _renderWidget(tester, selectedIndex: selectedIndex);
            await tester.tap(find.byType(SelectField));
            await tester.pumpAndSettle();
            final valueFinder = find.descendant(
                of: find.byType(BottomSheet),
                matching: find.byType(SelectTextOptionCard));
            expect(valueFinder, findsNWidgets(choices.length));
            for (var i = 0; i < choices.length; i++) {
              final radioFinder = find.descendant(
                  of: valueFinder.at(i), matching: find.byType(Radio<int>));
              expect(radioFinder, findsOneWidget);
              final radio = tester.widget<Radio>(radioFinder);
              expect(radio.groupValue, 1);
              expect(radio.value, i);
            }
          });
          // testWidgets('after value changes', (tester) async {
          //   int selectedIndex = 1;
          //   await _renderWidget(tester, selectedIndex: selectedIndex, onChanged: (value) {
          //     selectedIndex = value;
          //   });
          //   await tester.tap(find.byType(SelectField));
          //   await tester.pumpAndSettle();
          //   final valueFinder = find.descendant(
          //       of: find.byType(BottomSheet),
          //       matching: find.byType(SelectTextOptionCard));
          //   expect(valueFinder, findsNWidgets(choices.length));
          //   await tester.tap(valueFinder.at(2));
          //   await tester.pumpAndSettle();
          //   for (var i = 0; i < choices.length; i++) {
          //     final radioFinder = find.descendant(
          //         of: valueFinder.at(i), matching: find.byType(Radio<int>));
          //     expect(radioFinder, findsOneWidget);
          //     final radio = tester.widget<Radio>(radioFinder);
          //     expect(radio.groupValue, 2);
          //     expect(radio.value, i);
          //   }
          // });
        });
      });
    });
  });
}

Future<void> _renderWidget(WidgetTester tester,
    {int selectedIndex = 0, void Function(List<int>)? onChanged}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SelectField(
          getSelectedIndices: () => [selectedIndex],
          title: title,
          getChoices: () => choices,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
}
