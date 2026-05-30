import 'package:intl/intl.dart';

class ArabicFormatters {
  const ArabicFormatters._();

  static const _western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String toArabicDigits(Object value) {
    var result = value.toString();
    for (var i = 0; i < _western.length; i++) {
      result = result.replaceAll(_western[i], _arabic[i]);
    }
    return result;
  }

  static String toWesternDigits(Object value) {
    var result = value.toString();
    for (var i = 0; i < _arabic.length; i++) {
      result = result.replaceAll(_arabic[i], _western[i]);
    }
    return result;
  }

  static String formatDate(DateTime date) {
    return toArabicDigits(DateFormat('yyyy/MM/dd').format(date));
  }

  static String formatTime(DateTime date) {
    return toArabicDigits(DateFormat('hh:mm:ss a').format(date));
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  static String formatAmount(num amount, {String currency = 'سعودي'}) {
    final formatter = NumberFormat('#,##0.00', 'en');
    return '${toArabicDigits(formatter.format(amount))} $currency';
  }

  static String formatPlainAmount(num amount) {
    return toArabicDigits(NumberFormat('#,##0.00', 'en').format(amount));
  }

  static String compactNumber(num value) {
    if (value >= 1000000) {
      return '${toArabicDigits((value / 1000000).toStringAsFixed(1))}م';
    } else if (value >= 1000) {
      return '${toArabicDigits((value / 1000).toStringAsFixed(1))}ألف';
    }
    return toArabicDigits(value.toStringAsFixed(0));
  }

  static String amountToArabicWords(num value, String currency) {
    final whole = value.floor();
    final fraction = ((value - whole) * 100).round();
    final words = _numberToWords(whole);
    if (fraction == 0) {
      return '$words $currency لا غير';
    }
    return '$words $currency و ${_numberToWords(fraction)} هللة لا غير';
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'صفر';
    if (number < 0) return 'سالب ${_numberToWords(number.abs())}';

    final parts = <String>[];
    final millions = number ~/ 1000000;
    final thousands = (number % 1000000) ~/ 1000;
    final rest = number % 1000;

    if (millions > 0) {
      parts.add('${_underThousand(millions)} مليون');
    }
    if (thousands > 0) {
      parts.add('${_underThousand(thousands)} ألف');
    }
    if (rest > 0) {
      parts.add(_underThousand(rest));
    }

    return parts.join(' و ');
  }

  static String _underThousand(int number) {
    const ones = [
      '',
      'واحد',
      'اثنان',
      'ثلاثة',
      'أربعة',
      'خمسة',
      'ستة',
      'سبعة',
      'ثمانية',
      'تسعة',
      'عشرة',
      'أحد عشر',
      'اثنا عشر',
      'ثلاثة عشر',
      'أربعة عشر',
      'خمسة عشر',
      'ستة عشر',
      'سبعة عشر',
      'ثمانية عشر',
      'تسعة عشر',
    ];
    const tens = [
      '',
      '',
      'عشرون',
      'ثلاثون',
      'أربعون',
      'خمسون',
      'ستون',
      'سبعون',
      'ثمانون',
      'تسعون',
    ];
    const hundreds = [
      '',
      'مائة',
      'مائتان',
      'ثلاثمائة',
      'أربعمائة',
      'خمسمائة',
      'ستمائة',
      'سبعمائة',
      'ثمانمائة',
      'تسعمائة',
    ];

    final parts = <String>[];
    final hundred = number ~/ 100;
    final remainder = number % 100;

    if (hundred > 0) {
      parts.add(hundreds[hundred]);
    }
    if (remainder > 0) {
      if (remainder < 20) {
        parts.add(ones[remainder]);
      } else {
        final unit = remainder % 10;
        final ten = remainder ~/ 10;
        parts.add(unit == 0 ? tens[ten] : '${ones[unit]} و ${tens[ten]}');
      }
    }

    return parts.join(' و ');
  }
}
