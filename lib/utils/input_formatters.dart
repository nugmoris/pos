import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

//class ThousandsSeparatorInputFormatter extends TextInputFormatter {
class nambahkoma extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      final int selectionIndex =
          newValue.selection.end > 0 ? newValue.selection.end - 1 : 0;
      final String text = newValue.text.replaceAll(',', '');
      final int intValue = int.tryParse(text) ?? 0;

      String formattedValue;
      if (text.length > 3) {
        formattedValue = NumberFormat.decimalPattern().format(intValue);
      } else {
        formattedValue = text;
      }

      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: selectionIndex + 1),
      );
    }
    return newValue;
  }
}
