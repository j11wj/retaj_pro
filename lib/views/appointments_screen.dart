import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/constants/app_strings.dart';
import 'package:farah_sys_final/controllers/appointment_controller.dart';
import 'package:farah_sys_final/core/widgets/loading_widget.dart';
import 'package:farah_sys_final/core/widgets/empty_state_widget.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentController = Get.find<AppointmentController>();
    
    // Load appointments on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentController.loadPatientAppointments();
    });
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                        AppStrings.appointments,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'مواعيدك مع الطبيب سجاد الساعاتي الدودة',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Obx(() {
                if (appointmentController.isLoading.value) {
                  return const LoadingWidget(message: 'جاري تحميل المواعيد...');
                }
                
                final upcoming = appointmentController.getUpcomingAppointments();
                final past = appointmentController.getPastAppointments();
                final allAppointments = [...upcoming, ...past];
                
                if (allAppointments.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.calendar_today_outlined,
                    title: 'لا توجد مواعيد',
                    subtitle: 'لم يتم حجز أي مواعيد بعد',
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: allAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = allAppointments[index];
                    final isPast = appointment.date.isBefore(DateTime.now()) ||
                        appointment.status == 'completed' ||
                        appointment.status == 'cancelled';
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildAppointmentCard(
                        status: isPast ? 'سابق' : 'القادم',
                        date: '${appointment.date.day}-${appointment.date.month}-${appointment.date.year}',
                        time: appointment.time,
                        isPast: isPast,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String status,
    required String date,
    required String time,
    required bool isPast,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isPast ? AppColors.divider : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'موعدك ${isPast ? 'السابق' : 'القادم'} مع الدكتور سجاد الساعاتي',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isPast ? AppColors.textSecondary : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$time ${AppStrings.afternoon}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'في تمام الساعة',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.calendar_today,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'يوم الثلاثاء المصادف',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (!isPast) ...[
            SizedBox(height: 12.h),
            Text(
              AppStrings.arriveBeforeTime,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
