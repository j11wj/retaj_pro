import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/models/message_model.dart';
import 'dart:async';

class ChatService {
  final _firebaseService = FirebaseService();
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  /// جلب الرسائل من Firebase
  Future<List<MessageModel>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      return await _firebaseService.getMessages(
        userId1: userId1,
        userId2: userId2,
        limit: limit,
      );
    } catch (e) {
      throw Exception('فشل جلب الرسائل: ${e.toString()}');
    }
  }

  /// الاشتراك في الرسائل (للوقت الفعلي)
  void subscribeToMessages({
    required String userId1,
    required String userId2,
    required Function(List<MessageModel>) onMessages,
    Function(dynamic)? onError,
  }) {
    try {
      // إلغاء الاشتراك السابق إن وجد
      unsubscribe();
      
      _messagesSubscription = _firebaseService
          .getMessagesStream(userId1: userId1, userId2: userId2)
          .listen(
            (messages) {
              onMessages(messages);
            },
            onError: (error) {
              if (onError != null) onError(error);
            },
          );
    } catch (e) {
      if (onError != null) onError(e);
      throw Exception('فشل الاشتراك في الرسائل: ${e.toString()}');
    }
  }

  /// إرسال رسالة عبر Firebase
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      await _firebaseService.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        message: message,
      );
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: ${e.toString()}');
    }
  }

  /// تحديث حالة القراءة
  Future<void> markMessagesAsRead({
    required String userId1,
    required String userId2,
  }) async {
    try {
      await _firebaseService.markMessagesAsRead(
        userId1: userId1,
        userId2: userId2,
      );
    } catch (e) {
      // لا نرمي خطأ هنا لأنها عملية ثانوية
      print('فشل تحديث حالة القراءة: $e');
    }
  }

  /// إلغاء الاشتراك
  void unsubscribe() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  /// التحقق من حالة الاتصال
  bool get isConnected => _messagesSubscription != null;
}
