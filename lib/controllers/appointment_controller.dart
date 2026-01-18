import 'package:get/get.dart';
import 'package:farah_sys_final/models/appointment_model.dart';
import 'package:farah_sys_final/services/patient_service.dart';
import 'package:farah_sys_final/services/doctor_service.dart';
import 'package:farah_sys_final/core/network/api_exception.dart';

class AppointmentController extends GetxController {
  final _patientService = PatientService();
  final _doctorService = DoctorService();
  
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> primaryAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> secondaryAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = false.obs;


  // جلب مواعيد المريض
  Future<void> loadPatientAppointments() async {
    try {
      isLoading.value = true;
      final result = await _patientService.getMyAppointments();
      primaryAppointments.value = result['primary'] ?? [];
      secondaryAppointments.value = result['secondary'] ?? [];
      
      // دمج المواعيد
      appointments.value = [
        ...primaryAppointments,
        ...secondaryAppointments,
      ];
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل المواعيد');
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
      final appointmentsList = await _doctorService.getMyAppointments(
        day: day,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
        skip: skip,
        limit: limit,
      );
      appointments.value = appointmentsList;
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل المواعيد');
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
      final appointment = await _doctorService.addAppointment(
        patientId: patientId,
        scheduledAt: scheduledAt,
        note: note,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      
      appointments.add(appointment);
      Get.snackbar('نجح', 'تم إضافة الموعد بنجاح');
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إضافة الموعد');
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
