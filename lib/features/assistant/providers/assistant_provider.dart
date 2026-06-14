import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ── Message model ─────────────────────────────────────────

enum MessageRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage copyWith({String? content, bool? isLoading}) {
    return ChatMessage(
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Chat state ────────────────────────────────────────────

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


class AssistantNotifier extends StateNotifier<ChatState> {
  AssistantNotifier() : super(const ChatState());

  static const _apiKey =
      'AQ.Ab8RN6KlZGuLVEor1kIKizIt7xlnD8KfpwI6plri4x4HpBdJNw';
  static const _model = 'gemini-2.0-flash';
  static String get _apiUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  static const _systemPrompt =
      'You are an expert AI assistant with comprehensive knowledge about everything '
      'related to vehicles, driving, roads, and automotive topics. You can answer '
      'any question about: \n\n'
      '🚗 VEHICLES & MECHANICS\n'
      '- All car brands, models, specifications, years\n'
      '- Engine types (petrol, diesel, hybrid, electric, LPG)\n'
      '- Mechanical repairs, diagnostics, spare parts\n'
      '- Dashboard warning lights and error codes (OBD)\n'
      '- Tires, brakes, suspension, transmission\n'
      '- Car buying/selling advice, price estimates\n'
      '- Vehicle modifications and tuning\n\n'
      '📋 ROMANIAN DOCUMENTS & LEGAL\n'
      '- ITP (Inspectie Tehnica Periodica) — validity, procedure, costs\n'
      '- RCA (Responsabilitate Civila Auto) — mandatory insurance\n'
      '- CASCO insurance — optional, full coverage\n'
      '- Rovinieta — highway vignette, categories, purchase methods\n'
      '- Carte de identitate a vehiculului / Talon\n'
      '- Permis de conducere — categories (A, B, C, D, E), renewal\n'
      '- RAR (Registrul Auto Roman) — homologation, checks\n'
      '- Transcrierea / Radierea vehiculului\n'
      '- Taxes: impozit auto, taxa de poluare, timbru de mediu\n\n'
      '🛣️ ROADS & TRAFFIC\n'
      '- Romanian traffic laws (Codul Rutier)\n'
      '- Speed limits, road signs, priority rules\n'
      '- Fines and penalties (amenzi rutiere)\n'
      '- Highway rules (autostrada), toll roads\n'
      '- Drunk driving limits (alcoolemia)\n'
      '- Accident procedures — what to do, FNUASS, BAAR\n'
      '- Parking rules, towing (ridicare masina)\n'
      '- Points system (puncte de penalizare)\n\n'
      '⛽ FUEL & COSTS\n'
      '- Fuel types and quality (Euro 5, Euro 6)\n'
      '- Fuel efficiency tips\n'
      '- Running costs, insurance costs\n'
      '- Electric vehicle charging in Romania\n\n'
      '🌍 INTERNATIONAL\n'
      '- Driving in EU countries\n'
      '- Green card (Carte Verde)\n'
      '- International driving permit\n'
      '- Vignettes for Austria, Hungary, Slovenia, etc.\n\n'
      'You are integrated into "Smart Driver Assistant", a Romanian mobile app. '
      'Always be concise, accurate, and practical. '
      'Use correct Romanian terminology when applicable. '
      'Answer in the same language the user writes in — Romanian or English. '
      'If you do not know something specific, say so honestly rather than guessing.';

  Future<void> sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: MessageRole.user,
      content: userInput.trim(),
      timestamp: DateTime.now(),
    );
    final loadingMessage = ChatMessage(
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, loadingMessage],
      isLoading: true,
      error: null,
    );

    try {
      final contents = <Map<String, dynamic>>[];
      contents.add({
        'role': 'user',
        'parts': [
          {'text': _systemPrompt}
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Înțeles! Sunt gata să ajut cu orice întrebare despre vehicule, documente, drumuri și legislație rutieră.'
          }
        ],
      });

      for (final msg in state.messages) {
        if (msg.isLoading) continue;
        if (msg == userMessage) continue; // skip ultimul msg, adăugat mai jos
        contents.add({
          'role': msg.role == MessageRole.user ? 'user' : 'model',
          'parts': [
            {'text': msg.content}
          ],
        });
      }

      // Adaugă mesajul curent
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userInput.trim()}
        ],
      });

      // ✅ Headers Gemini — doar Content-Type, fără x-api-key
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantText =
            data['candidates'][0]['content']['parts'][0]['text'] as String? ??
                'No response';

        final assistantMessage = ChatMessage(
          role: MessageRole.assistant,
          content: assistantText,
          timestamp: DateTime.now(),
        );

        final updatedMessages = [...state.messages];
        updatedMessages.removeLast(); // scoate loading bubble
        updatedMessages.add(assistantMessage);

        state = state.copyWith(
          messages: updatedMessages,
          isLoading: false,
        );
      } else {
        // Afișează eroarea exactă din răspuns pentru debugging
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ??
            'API Error ${response.statusCode}';
        _handleError(errorMsg);
      }
    } catch (e) {
      _handleError('Connection error: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    final updatedMessages = [...state.messages];
    if (updatedMessages.isNotEmpty && updatedMessages.last.isLoading) {
      updatedMessages.removeLast();
    }

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: false,
      error: message,
    );
  }

  void clearChat() {
    state = const ChatState();
  }
}

final assistantProvider = StateNotifierProvider<AssistantNotifier, ChatState>(
  (ref) => AssistantNotifier(),
);
