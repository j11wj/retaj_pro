import 'package:get/get.dart';
import 'package:farah_sys_final/models/appointment_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';

class AppointmentController extends GetxController {
  final _firebaseService = FirebaseService();
  
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> primaryAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> secondaryAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = false.obs;


  // جلب مواعيد المريض
  Future<void> loadPatientAppointments() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null || currentUser.userType != 'patient') {
        isLoading.value = false;
        return;
      }
      
      final appointmentsList = await _firebaseService.getPatientAppointments(currentUser.id);
      appointments.value = appointmentsList;
    } catch (e) {
      print('خطأ: حدث خطأ أثناء تحميل المواعيد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب مواعيد الطبيب
  Future<void> loadDoctorAppointments({
    String? day,
    String? dateFrom,
    String? dateTo,
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null || currentUser.userType != 'doctor' || currentUser.doctorId == null) {
        isLoading.value = false;
        return;
      }
      
      final appointmentsList = await _firebaseService.getDoctorAppointments(currentUser.doctorId!);
      
      // تطبيق الفلاتر إذا كانت موجودة
      var filteredAppointments = appointmentsList;
      if (status != null) {
        filteredAppointments = filteredAppointments.where((apt) => apt.status == status).toList();
      }
      if (dateFrom != null) {
        final fromDate = DateTime.parse(dateFrom);
        filteredAppointments = filteredAppointments.where((apt) => apt.date.isAfter(fromDate) || apt.date.isAtSameMomentAs(fromDate)).toList();
      }
      if (dateTo != null) {
        final toDate = DateTime.parse(dateTo);
        filteredAppointments = filteredAppointments.where((apt) => apt.date.isBefore(toDate) || apt.date.isAtSameMomentAs(toDate)).toList();
      }
      
      appointments.value = filteredAppointments;
    } catch (e) {
      print('خطأ: حدث خطأ أثناء تحميل المواعيد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة موعد جديد (للطبيب)
  Future<void> addAppointment({
    required String patientId,
    required DateTime scheduledAt,
    String? note,
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      final patientController = Get.find<PatientController>();
      final currentUser = authController.currentUser.value;
      final patient = patientController.getPatientById(patientId);
      
      if (currentUser == null || currentUser.userType != 'doctor' || currentUser.doctorId == null) {
        throw Exception('الطبيب غير مسجل دخول');
      }
      
      if (patient == null) {
        throw Exception('المريض غير موجود');
      }
      
      final appointment = AppointmentModel(
        id: '',
        patientId: patientId,
        patientName: patient.name,
        doctorId: currentUser.doctorId!,
        doctorName: currentUser.name,
        date: scheduledAt,
        time: '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
        status: 'scheduled',
        notes: note,
      );
      
      await _firebaseService.createAppointment(appointment);
      appointments.add(appointment);
      print('نجح: تم إضافة الموعد بنجاح');
    } catch (e) {
      print('خطأ: حدث خطأ أثناء إضافة الموعد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  List<AppointmentModel> getUpcomingAppointments() {
    final now = DateTime.now();
    return appointments.where((appointment) {
      return appointment.date.isAfter(now) && 
             (appointment.status == 'pending' || appointment.status == 'scheduled');
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // حجز موعد جديد (للمريض)
  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required DateTime scheduledAt,
    String? note,
  }) async {
    try {
      isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      final patientController = Get.find<PatientController>();
      final currentUser = authController.currentUser.value;
      final profile = patientController.myProfile.value;
      
      if (currentUser == null || currentUser.userType != 'patient') {
        throw Exception('المريض غير مسجل دخول');
      }
      
      if (profile == null) {
        throw Exception('بيانات المريض غير موجودة');
      }
      
      final appointment = AppointmentModel(
        id: '',
        patientId: currentUser.id,
        patientName: profile.name,
        doctorId: doctorId,
        doctorName: doctorName,
        date: scheduledAt,
        time: '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
        status: 'pending',
        notes: note,
      );
      
      await _firebaseService.createAppointment(appointment);
      appointments.add(appointment);
      print('نجح: تم حجز الموعد بنجاح');
    } catch (e) {
      print('خطأ: حدث خطأ أثناء حجز الموعد: ${e.toString()}');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  List<AppointmentModel> getPastAppointments() {
    final now = DateTime.now();
    return appointments.where((appointment) {
      return appointment.date.isBefore(now) || 
             appointment.status == 'completed' ||
             appointment.status == 'cancelled';
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
