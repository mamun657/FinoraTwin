import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

class AiChatMessage {
  AiChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiChatResponse {
  AiChatResponse({required this.message, required this.createdAt});

  final String message;
  final DateTime createdAt;

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      message: (json['message'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class AiRepository {
  AiRepository(this._api);
  final ApiClient _api;

  Future<AiChatResponse> chat({required List<AiChatMessage> messages}) async {
    final response = await _api.post(
      '/api/v1/ai/chat',
      body: {'messages': messages.map((m) => m.toJson()).toList()},
    );
    return AiChatResponse.fromJson(response as Map<String, dynamic>);
  }
}

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepository(ref.watch(apiClientProvider)),
);
