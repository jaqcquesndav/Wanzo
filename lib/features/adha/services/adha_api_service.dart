import 'package:wanzo/core/services/api_client.dart';
import '../models/adha_message.dart';
import '../models/adha_context_info.dart';

class AdhaApiService {
  final ApiClient _apiClient;

  AdhaApiService(this._apiClient);

  Future<Map<String, dynamic>> sendMessage({
    required String messageText,
    String? conversationId,
    required AdhaContextInfo contextInfo,
  }) async {
    final body = {
      'text': messageText,
      'conversationId': conversationId,
      'timestamp': DateTime.now().toIso8601String(),
      'contextInfo': contextInfo.toJson(),
    };
    // try/catch is handled by ApiClient
    final response = await _apiClient.post('adha/message', body: body); // Pass body as named parameter
    return response as Map<String, dynamic>; // ApiClient returns decoded JSON
  }

  Future<List<Map<String, dynamic>>> getConversations({
    int page = 1,
    int limit = 10,
    String sortBy = 'lastMessageTimestamp',
    String sortOrder = 'desc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    // try/catch is handled by ApiClient
    final response = await _apiClient.get('adha/conversations', queryParameters: queryParams);
    // ApiClient returns decoded JSON, which should be a List<dynamic> here
    // Cast to List<Map<String, dynamic>> assuming the API returns a list of conversation objects
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  Future<List<AdhaMessage>> getConversationHistory(
    String conversationId,
    {int page = 1, int limit = 20}
  ) async {
     final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    // try/catch is handled by ApiClient
    final response = await _apiClient.get('adha/conversations/$conversationId/messages', queryParameters: queryParams);
    // ApiClient returns decoded JSON, which should be a List<dynamic> here
    return (response as List)
        .map((item) => AdhaMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
