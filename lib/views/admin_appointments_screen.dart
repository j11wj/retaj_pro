import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/models/appointment_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final RxList<AppointmentModel> _allAppointments = <AppointmentModel>[].obs;
  final RxBool _isLoading = true.obs;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      _isLoading.value = true;
      final appointments = await _firebaseService.getAllAppointments();
      _allAppointments.value = appointments;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الحجوزات: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  List<AppointmentModel> get _upcomingAppointments {
    final now = DateTime.now();
    return _allAppointments
        .where((apt) => apt.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<AppointmentModel> get _pastAppointments {
    final now = DateTime.now();
    return _allAppointments
        .where((apt) => apt.date.isBefore(now))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AppointmentModel> get _todayAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    return _allAppointments
        .where((apt) =>
            apt.date.isAfter(today) && apt.date.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
     
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isPast = appointment.date.isBefore(DateTime.now());
    final isToday = appointment.date.day == DateTime.now().day &&
        appointment.date.month == DateTime.now().month &&
        appointment.date.year == DateTime.now().year;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPast
              ? Colors.grey.withValues(alpha: 0.1)
              : isToday
                  ? Colors.orange.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            isPast ? Icons.history : isToday ? Icons.today : Icons.calendar_today,
            color: isPast
                ? Colors.grey
                : isToday
                    ? Colors.orange
                    : AppColors.primary,
          ),
        ),
        title: Text(
          'مريض: ${appointment.patientName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الطبيب: ${appointment.doctorName}'),
            Text('التاريخ والوقت: ${dateFormat.format(appointment.date)}',),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Text('ملاحظة: ${appointment.notes}'),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isPast
                ? Colors.grey
                : isToday
                    ? Colors.orange
                    : AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            isPast ? 'سابقة' : isToday ? 'اليوم' : 'قادمة',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              'لا توجد حجوزات',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الحجوزات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: [
            Tab(text: 'اليوم '),
            Tab(text: 'القادمة '),
            Tab(text: 'السابقة '),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentsList(_todayAppointments),
            _buildAppointmentsList(_upcomingAppointments),
            _buildAppointmentsList(_pastAppointments),
          ],
        );
      }),
    );
  }
}

