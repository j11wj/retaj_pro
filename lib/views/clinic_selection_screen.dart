import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/constants/app_strings.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';

class ClinicSelectionScreen extends StatefulWidget {
  const ClinicSelectionScreen({super.key});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // التأكد من تحميل العيادات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final clinicController = Get.find<ClinicController>();
      await clinicController.initializeClinics();
      // إذا كانت العيادات لا تزال فارغة، أضفها مباشرة
      if (clinicController.clinics.isEmpty) {
        await clinicController.forceAddClinics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicController = Get.find<ClinicController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.welcomeToComplex,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.complexDescription,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.selectClinic,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Clinics List
            Expanded(
              child: Obx(() {
                final isLoading = clinicController.isLoading.value;
                final clinics = clinicController.clinics;
                
                if (isLoading || clinics.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isLoading ? 'جاري تحميل العيادات...' : 'لا توجد عيادات متاحة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await clinicController.initializeClinics();
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      final clinic = clinics[index];
                      return _buildClinicCard(
                        clinic: clinic,
                        onTap: () {
                          clinicController.selectClinic(clinic);
                          // توجيه المريض إلى الصفحة الرئيسية بعد اختيار العيادة
                          Get.offAllNamed(AppRoutes.patientHome);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicCard({
    required ClinicModel clinic,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Clinic Icon
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                _getClinicIcon(clinic.specialty),
                color: AppColors.white,
                size: 35.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Clinic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    clinic.name,
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
                        clinic.specialty,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (clinic.doctorName != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      clinic.doctorName!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (clinic.location != null) ...[
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
                          clinic.location!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getClinicIcon(String specialty) {
    if (specialty.contains('أسنان') || specialty.contains('اسنان')) {
      return Icons.healing;
    } else if (specialty.contains('باطنية')) {
      return Icons.favorite;
    } else if (specialty.contains('جلدية')) {
      return Icons.spa;
    } else if (specialty.contains('عيون')) {
      return Icons.remove_red_eye;
    } else if (specialty.contains('أنف') || specialty.contains('أذن')) {
      return Icons.hearing;
    } else if (specialty.contains('أطفال')) {
      return Icons.child_care;
    } else if (specialty.contains('عظام')) {
      return Icons.healing_outlined;
    } else if (specialty.contains('قلب')) {
      return Icons.favorite_outline;
    } else if (specialty.contains('أعصاب')) {
      return Icons.psychology;
    } else if (specialty.contains('نفسي')) {
      return Icons.self_improvement;
    } else if (specialty.contains('مسالك')) {
      return Icons.medical_services;
    } else {
      return Icons.local_hospital;
    }
  }
}

