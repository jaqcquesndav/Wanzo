import 'package:wanzo/core/services/api_client.dart';
import 'package:wanzo/features/notifications/models/notification_model.dart';

abstract class NotificationApiService {
  Future<List<NotificationModel>> getNotifications({
    int? page,
    int? limit,
    String? status, // 'read', 'unread'
  });

  Future<NotificationModel> markNotificationAsRead(String notificationId);

  Future<void> markAllNotificationsAsRead();

  Future<void> deleteNotification(String notificationId);
}

class NotificationApiServiceImpl implements NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiServiceImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParameters = <String, String>{
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (status != null) 'status': status,
    };
    final response = await _apiClient.get('notifications', queryParameters: queryParameters, requiresAuth: true);
    final List<dynamic> data = response as List<dynamic>; // Assuming API returns a list
    return data.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String notificationId) async {
    final response = await _apiClient.post('notifications/$notificationId/mark-read', requiresAuth: true);
    return NotificationModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await _apiClient.post('notifications/mark-all-read', requiresAuth: true);
    // This endpoint might return a summary or just a success status.
    // If it returns data (e.g., count of messages marked read), adjust accordingly.
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete('notifications/$notificationId', requiresAuth: true);
  }
}
