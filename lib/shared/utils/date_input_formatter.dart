import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    
    // If we're deleting, just return the new value
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (newText[i] == '/') continue; // Ignore existing slashes
      buffer.write(newText[i]);
      
      final length = buffer.length;
      if ((length == 2 || length == 5) && i != newText.length - 1) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    // Cap at 10 chars (DD/MM/YYYY)
    final finalString = string.length > 10 ? string.substring(0, 10) : string;
    
    return newValue.copyWith(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }
}
