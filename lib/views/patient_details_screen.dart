import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';
import 'package:farah_sys_final/controllers/appointment_controller.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/core/widgets/empty_state_widget.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/models/medical_record_model.dart';
import 'package:farah_sys_final/models/appointment_model.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final PatientController _patientController = Get.find<PatientController>();
  final AppointmentController _appointmentController = Get.find<AppointmentController>();
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<MedicalRecordModel> _medicalRecords = <MedicalRecordModel>[].obs;
  final RxList<AppointmentModel> _patientAppointments = <AppointmentModel>[].obs;
  String? patientId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // إزالة تبويب المعرض
    
    // Get patientId from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    patientId = args?['patientId'];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (patientId != null) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (patientId == null) return;
    await _loadPatientAppointments();
    await _loadMedicalRecords();
  }

  Future<void> _loadPatientAppointments() async {
    if (patientId == null) return;
    try {
      print('جاري تحميل المواعيد للمريض: $patientId'); // للتشخيص
      final appointments = await _firebaseService.getPatientAppointments(patientId!);
      _patientAppointments.value = appointments;
      print('تم تحميل ${appointments.length} موعد'); // للتشخيص
    } catch (e) {
      print('خطأ في تحميل المواعيد: $e'); // للتشخيص
      Get.snackbar('خطأ', 'فشل تحميل المواعيد: ${e.toString()}');
    }
  }

  Future<void> _loadMedicalRecords() async {
    if (patientId == null) {
      print('patientId is null'); // للتشخيص
      return;
    }
    try {
      print('جاري تحميل السجلات للمريض: $patientId'); // للتشخيص
      final records = await _firebaseService.getPatientMedicalRecords(patientId!);
      _medicalRecords.value = records;
      print('تم تحميل ${records.length} سجل طبي'); // للتشخيص
    } catch (e) {
      print('خطأ في تحميل السجلات: $e'); // للتشخيص
      Get.snackbar('خطأ', 'فشل تحميل السجلات: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (patientId != null) {
                        Get.toNamed(AppRoutes.chat, arguments: {'patientId': patientId});
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ملف المريض',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
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
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: AppColors.primary,
                      size: 40.sp,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Obx(() {
                        final patient = patientId != null
                            ? _patientController.getPatientById(patientId!)
                            : null;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'الاسم : ${patient?.name ?? 'غير محدد'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'العمر : ${patient?.age ?? 0} سنة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'الجنس: ${patient?.gender ?? 'غير محدد'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'رقم الهاتف : ${patient?.phoneNumber ?? 'غير محدد'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'المدينة : ${patient?.city ?? 'غير محدد'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'نوع العلاج : ${patient?.treatmentHistory?.join(', ') ?? 'غير محدد'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  CircleAvatar(
                    radius: 35.r,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 35.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'السجلات'),
                  Tab(text: 'المواعيد'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecordsTab(),
                  _buildAppointmentsTab(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAddAppointmentDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                      child: Text(
                        'إضافة موعد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAddRecordDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                      child: Text(
                        'إضافة سجل',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
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

  Widget _buildRecordsTab() {
    if (patientId == null) {
      return const EmptyStateWidget(
        icon: Icons.medical_services_outlined,
        title: 'لا توجد سجلات',
      );
    }
    
    return Obx(() {
      if (_medicalRecords.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.medical_services_outlined,
          title: 'لا توجد سجلات',
          subtitle: 'لم يتم إضافة أي سجلات بعد',
        );
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: _medicalRecords.length,
        itemBuilder: (context, index) {
          final record = _medicalRecords[index];
          final date = '${record.date.day}/${record.date.month}/${record.date.year}';
          
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        record.treatmentType,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'التشخيص:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  record.diagnosis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'ملاحظات:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    record.notes!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }
  

  Widget _buildAppointmentsTab() {
    if (patientId == null) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'لا يوجد مواعيد',
      );
    }
    
    return Obx(() {
      if (_patientAppointments.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.calendar_today_outlined,
          title: 'لا يوجد مواعيد',
          subtitle: 'لم يتم حجز أي مواعيد بعد',
        );
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: _patientAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _patientAppointments[index];
          final date = '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}';
          
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'موعد في ${date}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'الوقت: ${appointment.time}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (appointment.notes != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    appointment.notes!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }

  void _showAddAppointmentDialog() {
    if (patientId == null) return;
    
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إضافة موعد جديد',
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
                    selectedDate = date;
                    dateController.text = '${date.day}/${date.month}/${date.year}';
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
                    selectedTime = time;
                    timeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                        Get.snackbar('خطأ', 'يرجى اختيار التاريخ والوقت');
                        return;
                      }
                      
                      final scheduledAt = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      
                      final authController = Get.find<AuthController>();
                      final doctor = authController.currentUser.value;
                      final patient = _patientController.getPatientById(patientId!);
                      
                      if (doctor == null || patient == null) {
                        Get.snackbar('خطأ', 'حدث خطأ في البيانات');
                        return;
                      }
                      
                      await _appointmentController.addAppointment(
                        patientId: patientId!,
                        scheduledAt: scheduledAt,
                        note: notesController.text.isEmpty ? null : notesController.text,
                      );
                      
                      Get.back();
                      await _loadPatientAppointments();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text('إضافة'),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    if (patientId == null) return;
    
    final treatmentTypeController = TextEditingController();
    final diagnosisController = TextEditingController();
    final notesController = TextEditingController();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إضافة سجل طبي',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: treatmentTypeController,
                decoration: InputDecoration(
                  labelText: 'نوع العلاج',
                  hintText: 'مثال: دواء، عملية، فحص',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: diagnosisController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'التشخيص',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ملاحظات إضافية (اختياري)',
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
                      if (treatmentTypeController.text.isEmpty || diagnosisController.text.isEmpty) {
                        Get.snackbar('خطأ', 'يرجى ملء نوع العلاج والتشخيص');
                        return;
                      }
                      
                      final authController = Get.find<AuthController>();
                      final doctor = authController.currentUser.value;
                      
                      if (doctor == null || doctor.doctorId == null) {
                        Get.snackbar('خطأ', 'حدث خطأ في بيانات الطبيب');
                        return;
                      }
                      
                      // إضافة السجل الطبي
                      final record = MedicalRecordModel(
                        id: '',
                        patientId: patientId!,
                        doctorId: doctor.doctorId!,
                        date: DateTime.now(),
                        treatmentType: treatmentTypeController.text,
                        diagnosis: diagnosisController.text,
                        notes: notesController.text.isEmpty ? null : notesController.text,
                      );
                      
                      try {
                        final recordId = await _firebaseService.createMedicalRecord(record);
                        print('تم إضافة السجل بنجاح برقم: $recordId'); // للتشخيص
                        Get.back();
                        await _loadMedicalRecords();
                        Get.snackbar('نجح', 'تم إضافة السجل بنجاح');
                      } catch (e) {
                        print('خطأ في إضافة السجل: $e'); // للتشخيص
                        Get.snackbar('خطأ', 'فشل إضافة السجل: ${e.toString()}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: Text('إضافة'),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
