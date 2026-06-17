import '../entities/transaction.dart';

class ParsedSms {
  final double? amount;
  final TransactionType? source;
  final bool isIncoming;

  const ParsedSms({this.amount, this.source, this.isIncoming = true});
}

class SmsParser {
  static ParsedSms parse(String smsText) {
    final text = smsText.toLowerCase();

    // Extract amount
    double? amount;
    final amountPatterns = [
      RegExp(r'(?:rs\.?|₹|inr)\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false),
      RegExp(r'([0-9,]+(?:\.[0-9]{1,2})?)\s*(?:rs\.?|₹|inr)', caseSensitive: false),
      RegExp(r'amount[:\s]+([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false),
    ];
    for (final p in amountPatterns) {
      final m = p.firstMatch(smsText);
      if (m != null) {
        amount = double.tryParse(m.group(1)!.replaceAll(',', ''));
        break;
      }
    }

    // Detect source
    TransactionType? source;
    if (text.contains('paytm')) {
      source = TransactionType.upiPaytm;
    } else if (text.contains('google pay') || text.contains('gpay') || text.contains('tez')) {
      source = TransactionType.upiGpay;
    } else if (text.contains('phonepe') || text.contains('phone pe')) {
      source = TransactionType.upiPhonePe;
    } else if (text.contains('upi')) {
      source = TransactionType.upiPaytm; // default to paytm for generic UPI
    }

    // Determine direction
    final incomingKeywords = ['received', 'credited', 'credit', 'deposited', 'added'];
    final isIncoming = incomingKeywords.any((k) => text.contains(k));

    return ParsedSms(amount: amount, source: source, isIncoming: isIncoming);
  }

  static bool isUpiSms(String smsText) {
    final text = smsText.toLowerCase();
    return text.contains('paytm') ||
        text.contains('google pay') ||
        text.contains('phonepe') ||
        text.contains('upi') ||
        text.contains('bhim');
  }
}
