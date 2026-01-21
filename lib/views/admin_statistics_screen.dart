import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  final _firebaseService = FirebaseService();
  final RxBool _isLoading = true.obs;
  final RxInt _totalPatients = 0.obs;
  final RxInt _totalDoctors = 0.obs;
  final RxInt _totalClinics = 0.obs;
  final RxInt _totalAppointments = 0.obs;
  final RxInt _todayAppointments = 0.obs;
  final RxInt _upcomingAppointments = 0.obs;
  final RxInt _pastAppointments = 0.obs;
  final RxInt _totalMedicalRecords = 0.obs;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      _isLoading.value = true;

      // جلب جميع البيانات
      final patients = await _firebaseService.getAllPatients();
      final doctors = await _firebaseService.getAllDoctors();
      final clinics = await _firebaseService.getAllClinics();
      final appointments = await _firebaseService.getAllAppointments();

      // حساب الإحصائيات
      _totalPatients.value = patients.length;
      _totalDoctors.value = doctors.length;
      _totalClinics.value = clinics.length;
      _totalAppointments.value = appointments.length;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      _todayAppointments.value = appointments
          .where((apt) =>
              apt.date.isAfter(today) && apt.date.isBefore(tomorrow))
          .length;

      _upcomingAppointments.value =
          appointments.where((apt) => apt.date.isAfter(now)).length;

      _pastAppointments.value =
          appointments.where((apt) => apt.date.isBefore(now)).length;

      // جلب السجلات الطبية
      // Note: نحتاج إضافة getAllMedicalRecords في FirebaseService
      _totalMedicalRecords.value = 0; // سيتم تحديثه لاحقاً
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الإحصائيات: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإحصائيات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.white),
            onPressed: () => _loadStatistics(),
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _loadStatistics,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // إحصائيات عامة
                Text(
                  'إحصائيات عامة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.1,
                  children: [
                    _buildStatCard(
                      title: 'المرضى',
                      value: _totalPatients.value,
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                    _buildStatCard(
                      title: 'الأطباء',
                      value: _totalDoctors.value,
                      icon: Icons.person,
                      color: AppColors.secondary,
                    ),
                    _buildStatCard(
                      title: 'العيادات',
                      value: _totalClinics.value,
                      icon: Icons.local_hospital,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'الحجوزات',
                      value: _totalAppointments.value,
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // إحصائيات الحجوزات
                Text(
                  'إحصائيات الحجوزات',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.7,
                  children: [
                    _buildStatCard(
                      title: 'اليوم',
                      value: _todayAppointments.value,
                      icon: Icons.today,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'القادمة',
                      value: _upcomingAppointments.value,
                      icon: Icons.upcoming,
                      color: AppColors.primary,
                    ),
                    _buildStatCard(
                      title: 'السابقة',
                      value: _pastAppointments.value,
                      icon: Icons.history,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

