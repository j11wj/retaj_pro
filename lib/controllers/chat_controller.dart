import 'package:get/get.dart';
import 'package:farah_sys_final/models/message_model.dart';
import 'package:farah_sys_final/services/chat_service.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';

class ChatController extends GetxController {
  final _chatService = ChatService();
  
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  String? otherUserId; // معرف المستخدم الآخر (مريض أو طبيب)
  String? currentUserId;

  @override
  void onClose() {
    _chatService.unsubscribe();
    super.onClose();
  }

  // جلب معرف المستخدم الحالي الصحيح
  String? _getCurrentUserId() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    
    if (currentUser == null) {
      return null;
    }
    
    // إذا كان المستخدم طبيباً، استخدم doctorId
    if (currentUser.userType == 'doctor') {
      return currentUser.doctorId ?? currentUser.id;
    }
    
    // إذا كان المستخدم مريضاً، استخدم patient.id من myProfile
    if (currentUser.userType == 'patient') {
      try {
        final patientController = Get.find<PatientController>();
        final patient = patientController.myProfile.value;
        if (patient != null) {
          return patient.id;
        }
      } catch (e) {
        print('خطأ في جلب معرف المريض: $e');
      }
      // إذا لم نجد patient، استخدم currentUser.id
      return currentUser.id;
    }
    
    return currentUser.id;
  }

  // جلب الرسائل من Firebase
  Future<void> loadMessages({
    required String otherUserId,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;
      
      // إلغاء الاشتراك السابق إذا كان هناك محادثة سابقة
      if (this.otherUserId != null && this.otherUserId != otherUserId) {
        print('إلغاء الاشتراك السابق مع: ${this.otherUserId}'); // للتشخيص
        _chatService.unsubscribe();
        messages.clear();
      }
      
      this.otherUserId = otherUserId;
      
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }
      
      currentUserId = userId;
      
      print('جلب الرسائل: currentUserId=$currentUserId, otherUserId=$otherUserId'); // للتشخيص
      
      final messagesList = await _chatService.getMessages(
        userId1: currentUserId!,
        userId2: otherUserId,
        limit: limit,
      );
      
      messages.value = messagesList;
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      print('تم تحميل ${messagesList.length} رسالة'); // للتشخيص
    } catch (e) {
      print('خطأ في loadMessages: $e'); // للتشخيص
    } finally {
      isLoading.value = false;
    }
  }

  // الاشتراك في الرسائل (للوقت الفعلي)
  Future<void> subscribeToMessages(String otherUserId) async {
    try {
      // التأكد من أن otherUserId يطابق القيمة الحالية
      if (this.otherUserId != otherUserId) {
        print('تحذير: otherUserId غير متطابق. الحالي: ${this.otherUserId}, الجديد: $otherUserId'); // للتشخيص
        this.otherUserId = otherUserId;
      }
      
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }
      
      // التأكد من أن currentUserId محدث
      if (currentUserId != userId) {
        print('تحديث currentUserId من $currentUserId إلى $userId'); // للتشخيص
        currentUserId = userId;
      }
      
      print('الاشتراك في الرسائل: currentUserId=$currentUserId, otherUserId=$otherUserId'); // للتشخيص
      
      // إلغاء الاشتراك السابق قبل الاشتراك الجديد
      _chatService.unsubscribe();
      
      _chatService.subscribeToMessages(
        userId1: currentUserId!,
        userId2: otherUserId,
        onMessages: (newMessages) {
          print('تم استلام ${newMessages.length} رسالة جديدة'); // للتشخيص
          // التأكد من أن الرسائل تخص المحادثة الحالية
          final filteredMessages = newMessages.where((msg) {
            final isFromCurrentUser = msg.senderId == currentUserId && msg.receiverId == otherUserId;
            final isToCurrentUser = msg.senderId == otherUserId && msg.receiverId == currentUserId;
            return isFromCurrentUser || isToCurrentUser;
          }).toList();
          
          if (filteredMessages.length != newMessages.length) {
            print('تحذير: تم تصفية ${newMessages.length - filteredMessages.length} رسالة لا تخص هذه المحادثة'); // للتشخيص
          }
          
          messages.value = filteredMessages;
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        },
        onError: (error) {
          print('خطأ في الاشتراك: $error'); // للتشخيص
          isConnected.value = false;
        },
      );
      
      isConnected.value = true;
      
      // تحديث حالة القراءة
      await _chatService.markMessagesAsRead(
        userId1: currentUserId!,
        userId2: otherUserId,
      );
    } catch (e) {
      print('خطأ في subscribeToMessages: $e'); // للتشخيص
      isConnected.value = false;
    }
  }

  // إرسال رسالة
  Future<void> sendMessage(String content) async {
    try {
      if (currentUserId == null || otherUserId == null) {
        throw Exception('المستخدم أو المستخدم الآخر غير محدد');
      }
      
      await _chatService.sendMessage(
        senderId: currentUserId!,
        receiverId: otherUserId!,
        message: content,
      );
      
      // الرسالة ستظهر تلقائياً من خلال الاشتراك
      print('تم إرسال الرسالة بنجاح'); // للتشخيص
    } catch (e) {
      print('خطأ في sendMessage: $e'); // للتشخيص
    }
  }

  // قطع الاتصال
  void disconnect() {
    _chatService.unsubscribe();
    isConnected.value = false;
  }

  List<MessageModel> getUnreadMessages(String userId) {
    return messages.where((message) {
      return message.receiverId == userId && !message.isRead;
    }).toList();
  }
}
