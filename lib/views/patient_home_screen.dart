import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/constants/app_strings.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';
import 'package:farah_sys_final/controllers/appointment_controller.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/models/user_model.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  void _showBookAppointmentDialog(BuildContext context) {
    final appointmentController = Get.find<AppointmentController>();
    final clinicController = Get.find<ClinicController>();
    final patientController = Get.find<PatientController>();
    
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(24.w),
          child: StatefulBuilder(
            builder: (context, setState) {
              
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'حجز موعد جديد',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            dateController.text = '${date.day}/${date.month}/${date.year}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'التاريخ',
                            hintText: 'اختر التاريخ',
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            selectedTime = time;
                            timeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: timeController,
                          decoration: InputDecoration(
                            labelText: 'الوقت',
                            hintText: 'اختر الوقت',
                            suffixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('إلغاء'),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedDate == null || selectedTime == null) {
                              print('خطأ: يرجى اختيار التاريخ والوقت');
                              return;
                            }
                            
                            try {
                              // التأكد من تحميل بيانات المريض
                              if (patientController.myProfile.value == null) {
                                await patientController.loadMyProfile();
                              }
                              
                              final profile = patientController.myProfile.value;
                              final clinic = clinicController.selectedClinic.value;
                              
                              if (profile == null) {
                                print('خطأ: لم يتم تحميل بيانات المريض');
                                return;
                              }
                              
                              // البحث عن الطبيب المرتبط بالعيادة
                              String? doctorId;
                              String? doctorName;
                              
                              if (clinic != null) {
                                try {
                                  final firebaseService = FirebaseService();
                                  final doctors = await firebaseService.getAllDoctors();
                                  
                                  UserModel? foundDoctor;
                                  for (var doctor in doctors) {
                                    if (doctor.clinicId == clinic.id && doctor.doctorId != null) {
                                      foundDoctor = doctor;
                                      break;
                                    }
                                  }
                                  
                                  if (foundDoctor != null && foundDoctor.doctorId != null) {
                                    doctorId = foundDoctor.doctorId;
                                    doctorName = foundDoctor.name;
                                  } else if (clinic.doctorName != null) {
                                    for (var doctor in doctors) {
                                      if (doctor.name == clinic.doctorName && doctor.doctorId != null) {
                                        doctorId = doctor.doctorId;
                                        doctorName = doctor.name;
                                        break;
                                      }
                                    }
                                  }
                                } catch (e) {
                                  print('خطأ في جلب الأطباء: $e');
                                }
                              }
                              
                              if (doctorId == null || doctorName == null) {
                                print('خطأ: لم يتم العثور على طبيب مرتبط بهذه العيادة');
                                return;
                              }
                              
                              final scheduledAt = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              );
                              
                              await appointmentController.bookAppointment(
                                doctorId: doctorId,
                                doctorName: doctorName,
                                scheduledAt: scheduledAt,
                                note: notesController.text.isEmpty ? null : notesController.text,
                              );
                              
                              Get.back();
                              await appointmentController.loadPatientAppointments();
                            } catch (e) {
                              print('خطأ في حجز الموعد: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text('حجز'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final patientController = Get.find<PatientController>();
    final appointmentController = Get.find<AppointmentController>();
    final clinicController = Get.find<ClinicController>();
    
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      patientController.loadMyProfile();
      appointmentController.loadPatientAppointments();
    });
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // العودة لاختيار العيادات
                      Get.offAllNamed(AppRoutes.clinicSelection);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.homePage,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.patientProfile);
                    },
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Welcome Card with gradient
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.welcome,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() {
                      final user = authController.currentUser.value;
                      final profile = patientController.myProfile.value;
                      return Text(
                        user?.name ?? profile?.name ?? 'مريض',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    Obx(() {
                      final clinic = clinicController.selectedClinic.value;
                      return Text(
                        clinic != null 
                            ? 'في ${clinic.name}'
                            : AppStrings.welcomeToClinic,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                AppStrings.yourDoctor,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              // Doctor Card with enhanced design
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.divider,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                  
                        try {
                          // التأكد من تحميل بيانات المريض أولاً
                          if (patientController.myProfile.value == null) {
                            await patientController.loadMyProfile();
                          }
                          
                          final profile = patientController.myProfile.value;
                          final clinic = clinicController.selectedClinic.value;
                          
                          if (profile == null) {
                            print('خطأ: لم يتم تحميل بيانات المريض. يرجى المحاولة مرة أخرى');
                            return;
                          }
                          
                          print('بيانات المريض: ${profile.name}, doctorId: ${profile.doctorId}'); // للتشخيص
                          
                          // البحث عن الطبيب المرتبط بالعيادة
                          String? doctorId;
                          
                          // أولاً: البحث عن الطبيب المرتبط بالعيادة المختارة (الأولوية للعيادة)
                          if (clinic != null) {
                            try {
                              print('البحث عن الطبيب المرتبط بالعيادة: ${clinic.id}'); // للتشخيص
                              final firebaseService = FirebaseService();
                              final doctors = await firebaseService.getAllDoctors();
                              print('تم جلب ${doctors.length} طبيب'); // للتشخيص
                              
                              // البحث عن الطبيب المرتبط بالعيادة
                              UserModel? foundDoctor;
                              for (var doctor in doctors) {
                                print('فحص طبيب: ${doctor.name}, clinicId: ${doctor.clinicId}, doctorId: ${doctor.doctorId}'); // للتشخيص
                                if (doctor.clinicId == clinic.id && doctor.doctorId != null) {
                                  foundDoctor = doctor;
                                  break;
                                }
                              }
                              
                              if (foundDoctor != null && foundDoctor.doctorId != null) {
                                doctorId = foundDoctor.doctorId;
                                print('تم العثور على الطبيب من العيادة: $doctorId'); // للتشخيص
                              } else {
                                print('لم يتم العثور على طبيب مرتبط بالعيادة'); // للتشخيص
                              }
                            } catch (e) {
                              print('خطأ في جلب الأطباء: $e'); // للتشخيص
                              // نتابع المحاولة بطريقة أخرى
                            }
                          }
                          
                          // ثانياً: إذا لم نجد طبيباً من العيادة، نبحث بالاسم
                          if (doctorId == null || doctorId.isEmpty) {
                            if (clinic != null && clinic.doctorName != null) {
                              print('البحث عن الطبيب بالاسم: ${clinic.doctorName}'); // للتشخيص
                              try {
                                final firebaseService = FirebaseService();
                                final doctors = await firebaseService.getAllDoctors();
                                for (var doctor in doctors) {
                                  if (doctor.name == clinic.doctorName && doctor.doctorId != null) {
                                    doctorId = doctor.doctorId;
                                    print('تم العثور على الطبيب بالاسم: $doctorId'); // للتشخيص
                                    break;
                                  }
                                }
                              } catch (e) {
                                print('خطأ في البحث عن الطبيب بالاسم: $e'); // للتشخيص
                              }
                            }
                          }
                          
                          // ثالثاً: إذا لم نجد طبيباً، نستخدم doctorId من بيانات المريض (كحل أخير)
                          if (doctorId == null || doctorId.isEmpty) {
                            if (profile.doctorId != null && profile.doctorId!.isNotEmpty) {
                              doctorId = profile.doctorId;
                              print('استخدام doctorId من بيانات المريض: $doctorId'); // للتشخيص
                            }
                          }
                          
                          if (doctorId == null || doctorId.isEmpty) {
                            print('خطأ: لم يتم العثور على طبيب مرتبط بهذه العيادة');
                            return;
                          }
                          
                          print('فتح المحادثة مع الطبيب: $doctorId'); // للتشخيص
                          Get.toNamed(AppRoutes.chat, arguments: {'doctorId': doctorId});
                        } catch (e) {
                          print('خطأ كامل في فتح المحادثة: $e');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => _showBookAppointmentDialog(context),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: AppColors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(() {
                        final clinic = clinicController.selectedClinic.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              clinic?.doctorName ?? 'د. سجاد الساعاتي',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  clinic?.specialty ?? AppStrings.specialist,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (clinic?.location != null) ...[
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    clinic!.location!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 30.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.appointments);
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.appointments,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final upcoming = appointmentController.getUpcomingAppointments();
                final past = appointmentController.getPastAppointments();
                final selectedClinic = clinicController.selectedClinic.value;
                
                if (upcoming.isEmpty && past.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(24.w),
                    child: Center(
                      child: Text(
                        'لا توجد مواعيد',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    if (upcoming.isNotEmpty)
                      ...upcoming.take(2).map((appointment) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildAppointmentCard(
                              status: AppStrings.nextAppointment,
                              date: '${appointment.date.day}-${appointment.date.month}-${appointment.date.year}',
                              time: appointment.time,
                              isPast: false,
                              doctorName: selectedClinic?.doctorName,
                            ),
                          )),
                    if (past.isNotEmpty)
                      ...past.take(1).map((appointment) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildAppointmentCard(
                              status: AppStrings.previousAppointment,
                              date: '${appointment.date.day}-${appointment.date.month}-${appointment.date.year}',
                              time: appointment.time,
                              isPast: true,
                              doctorName: selectedClinic?.doctorName,
                            ),
                          )),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String status,
    required String date,
    required String time,
    required bool isPast,
    String? doctorName,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isPast ? AppColors.divider : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isPast ? AppColors.divider : AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: isPast
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPast
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isPast ? 'منتهي' : 'قادم',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isPast ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isPast ? Icons.check_circle_outline : Icons.access_time,
                size: 20.sp,
                color: isPast ? AppColors.textSecondary : AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'موعدك ${isPast ? 'السابق' : 'القادم'} مع الدكتور',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            doctorName ?? 'د. سجاد الساعاتي',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPast
                          ? [AppColors.textSecondary, AppColors.textSecondary]
                          : [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isPast) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    AppStrings.arriveBeforeTime,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

