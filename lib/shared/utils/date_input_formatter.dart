import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Handle backspace properly
    if (oldValue.text.length > text.length) {
      return newValue;
    }

    // Clean input (remove non-digits)
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (int.tryParse(text[i]) != null) {
        buffer.write(text[i]);
      }
    }

    var cleanText = buffer.toString();
    var formattedText = "";

    // DD/MM/YYYY Logic
    for (int i = 0; i < cleanText.length; i++) {
        formattedText += cleanText[i];
        
        // Add slash after DD (2 chars)
        if (i == 1) {
            formattedText += "/";
        }
        // Add slash after MM (4 chars total digits)
        else if (i == 3) {
            formattedText += "/";
        }
    }
    
    // Prevent trailing slash if user is just typing headers
    // Actually, we WANT trailing slash so they know to type next number.
    // But if formatting resulted in "12/", it's good.
    
    // Safety cap
    if (formattedText.length > 10) {
        formattedText = formattedText.substring(0, 10);
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
