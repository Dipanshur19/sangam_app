import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/sms_entry.dart';

class ClaudeService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-20250514';

  final String apiKey;
  ClaudeService(this.apiKey);

  Future<List<ParsedKhataEntry>> parseKhataImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';

    const prompt = '''You are reading a photo of a handwritten Indian kirana store khata (account book / ledger).
Extract every transaction entry you can read.
For each entry identify:
- name: customer name (may be in Hindi or English, transliterate if needed)
- amount: numeric rupee amount as integer
- isCredit: true if udhar/credit given to customer, false if payment received from customer
- note: brief item description if visible (optional)

Return ONLY a valid JSON array:
[{"name":"Ramesh","amount":350,"isCredit":true,"note":"Atta, Dal"},{"name":"Kavita","amount":200,"isCredit":false}]

If you cannot read clearly, return an empty array [].
Return ONLY the JSON array, no explanation or markdown.''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mimeType,
                    'data': base64Image,
                  },
                },
                {'type': 'text', 'text': prompt},
              ],
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (data['content'] as List).first['text'] as String;
      final cleaned = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final entries = jsonDecode(cleaned) as List;

      return entries.map((e) => ParsedKhataEntry(
        name: e['name'] as String,
        amount: (e['amount'] as num).toDouble(),
        isCredit: e['isCredit'] as bool,
        note: e['note'] as String?,
      )).toList();
    } catch (e) {
      throw Exception('Failed to parse image: $e');
    }
  }
}
