import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الأدمن',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة إدارة العيادات
              _buildAdminCard(
                context: context,
                title: 'إدارة العيادات',
                icon: Icons.local_hospital,
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.adminClinics),
                description: 'إضافة، تعديل، وحذف العيادات',
              ),
              SizedBox(height: 16.h),
              
              // بطاقة إدارة الأطباء
              _buildAdminCard(
                context: context,
                title: 'إدارة الأطباء',
                icon: Icons.person,
                color: AppColors.secondary,
                onTap: () => Get.toNamed(AppRoutes.adminDoctors),
                description: 'إضافة، تعديل، وحذف الأطباء',
              ),
              SizedBox(height: 16.h),
              
              // بطاقة الحجوزات
              _buildAdminCard(
                context: context,
                title: 'إدارة الحجوزات',
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.adminAppointments),
                description: 'عرض جميع الحجوزات (الحالية، السابقة، القادمة)',
              ),
              SizedBox(height: 16.h),
              
              // بطاقة الإحصائيات
              _buildAdminCard(
                context: context,
                title: 'الإحصائيات',
                icon: Icons.bar_chart,
                color: Colors.green,
                onTap: () => Get.toNamed(AppRoutes.adminStatistics),
                description: 'عرض إحصائيات النظام',
              ),
              SizedBox(height: 16.h),
              
              // زر إضافة بيانات تجريبية
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'إضافة بيانات تجريبية',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'إضافة أطباء ومرضى وحجوزات للاختبار',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          Get.dialog(
                            Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );
                          
                          final firebaseService = FirebaseService();
                          await firebaseService.seedDemoData();
                          
                          Get.back(); // إغلاق dialog التحميل
                          Get.snackbar('نجح', 'تم إضافة البيانات التجريبية بنجاح');
                        } catch (e) {
                          Get.back(); // إغلاق dialog التحميل
                          Get.snackbar('خطأ', 'فشل إضافة البيانات: ${e.toString()}');
                        }
                      },
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('إضافة بيانات تجريبية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String description,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

