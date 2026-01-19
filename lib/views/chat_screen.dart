import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/constants/app_strings.dart';
import 'package:farah_sys_final/controllers/chat_controller.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/core/widgets/loading_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? otherUserId; // معرف المستخدم الآخر (مريض أو طبيب)
  String? otherUserName; // اسم المستخدم الآخر

  @override
  void initState() {
    super.initState();
    // Get otherUserId from arguments (patientId or doctorId)
    final args = Get.arguments as Map<String, dynamic>?;
    otherUserId = args?['patientId'] ?? args?['doctorId'];
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (otherUserId != null && otherUserId!.isNotEmpty) {
        print('بدء تحميل المحادثة مع: $otherUserId'); // للتشخيص
        try {
          await _loadOtherUserName();
          await _chatController.loadMessages(otherUserId: otherUserId!);
          await _chatController.subscribeToMessages(otherUserId!);
        } catch (e) {
          print('خطأ في تحميل المحادثة: $e'); // للتشخيص
          Get.snackbar('خطأ', 'فشل تحميل المحادثة: ${e.toString()}');
        }
      } else {
        Get.snackbar('خطأ', 'لم يتم تحديد المستخدم للدردشة');
        Get.back();
      }
    });
  }

  Future<void> _loadOtherUserName() async {
    if (otherUserId == null || otherUserId!.isEmpty) {
      setState(() {
        otherUserName = 'المحادثة';
      });
      return;
    }
    
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        setState(() {
          otherUserName = 'المحادثة';
        });
        return;
      }
      
      // إذا كان المستخدم الحالي مريضاً، المستخدم الآخر هو طبيب
      if (currentUser.userType == 'patient') {
        try {
          // محاولة جلب الطبيب باستخدام doctorId
          final doctor = await _firebaseService.getDoctorByIdAndCode(otherUserId!.toUpperCase(), '');
          if (doctor != null) {
            setState(() {
              otherUserName = doctor.name;
            });
            return;
          }
        } catch (e) {
          print('خطأ في جلب الطبيب بالمعرف: $e');
        }
        
        // محاولة جلب جميع الأطباء والبحث
        try {
          final doctors = await _firebaseService.getAllDoctors();
          if (doctors.isNotEmpty) {
            UserModel? foundDoctor;
            for (var doctor in doctors) {
              if ((doctor.doctorId != null && doctor.doctorId!.toUpperCase() == otherUserId!.toUpperCase()) || 
                  doctor.id == otherUserId) {
                foundDoctor = doctor;
                break;
              }
            }
            
            if (foundDoctor != null) {
              setState(() {
                otherUserName = foundDoctor!.name;
              });
            } else if (doctors.isNotEmpty) {
              setState(() {
                otherUserName = doctors.first.name;
              });
            } else {
              setState(() {
                otherUserName = 'الطبيب';
              });
            }
          } else {
            setState(() {
              otherUserName = 'الطبيب';
            });
          }
        } catch (e) {
          print('خطأ في البحث عن الطبيب: $e');
          setState(() {
            otherUserName = 'الطبيب';
          });
        }
      } 
      // إذا كان المستخدم الحالي طبيباً، المستخدم الآخر هو مريض
      else if (currentUser.userType == 'doctor') {
        try {
          final patient = await _firebaseService.getPatientById(otherUserId!);
          if (patient != null) {
            setState(() {
              otherUserName = patient.name;
            });
          } else {
            setState(() {
              otherUserName = 'المريض';
            });
          }
        } catch (e) {
          print('خطأ في جلب بيانات المريض: $e');
          setState(() {
            otherUserName = 'المريض';
          });
        }
      } else {
        setState(() {
          otherUserName = 'المحادثة';
        });
      }
    } catch (e) {
      print('خطأ في جلب اسم المستخدم الآخر: $e');
      setState(() {
        otherUserName = 'المحادثة';
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatController.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        otherUserName ?? 'المحادثة',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Divider(height: 1.h, color: AppColors.divider),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'اليوم , 6:36 مساءً',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_chatController.isLoading.value && _chatController.messages.isEmpty) {
                  return const LoadingWidget(message: 'جاري تحميل الرسائل...');
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  reverse: true,
                  itemCount: _chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = _chatController.messages[_chatController.messages.length - 1 - index];
                    final currentUserId = _authController.currentUser.value?.id ?? '';
                    final isSent = message.senderId == currentUserId;
                    // Format time without locale
                    final hour = message.timestamp.hour;
                    final minute = message.timestamp.minute.toString().padLeft(2, '0');
                    final period = hour >= 12 ? 'مساءً' : 'صباحاً';
                    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                    final time = '$displayHour:$minute $period';
                    
                    return _buildMessageBubble(
                      message: message.message,
                      isSent: isSent,
                      time: time,
                    );
                  },
                );
              }),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_messageController.text.trim().isNotEmpty && otherUserId != null) {
                        await _chatController.sendMessage(_messageController.text.trim());
                        _messageController.clear();
                        // Scroll to bottom
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.writeMessage,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSent,
    required String time,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSent ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSent ? AppColors.white : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
