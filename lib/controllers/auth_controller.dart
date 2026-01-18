import 'package:get/get.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/services/auth_service.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/core/network/api_exception.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';

class AuthController extends GetxController {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString otpCode = ''.obs;

  // استخدام Firebase بدلاً من demo mode
  static const bool useFirebase = true;

  Future<void> checkLoggedInUser() async {
    if (useFirebase) return; // Firebase لا يحتاج للتحقق المسبق
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        currentUser.value = user;
        if (user.userType == 'patient') {
          Get.offAllNamed(AppRoutes.patientHome);
        } else if (user.userType == 'doctor') {
          Get.offAllNamed(AppRoutes.doctorPatientsList);
        } else {
          Get.offAllNamed(AppRoutes.userSelection);
        }
      }
    } catch (e) {
      // المستخدم غير مسجل دخول
      currentUser.value = null;
    }
  }

  // طلب إرسال OTP (للاستخدام المستقبلي إذا لزم الأمر)
  Future<void> requestOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _authService.requestOtp(phoneNumber);
      Get.snackbar('نجح', 'تم إرسال رمز التحقق');
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء إرسال رمز التحقق');
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من OTP وتسجيل الدخول (للاستخدام المستقبلي)
  Future<void> verifyOtpAndLogin({
    required String phoneNumber,
    required String code,
    String? name,
    String? gender,
    int? age,
    String? city,
  }) async {
    try {
      isLoading.value = true;
      final user = await _authService.verifyOtp(
        phone: phoneNumber,
        code: code,
        name: name,
        gender: gender,
        age: age,
        city: city,
      );
      
      currentUser.value = user;
      // توجيه المريض إلى اختيار العيادة
      Get.offAllNamed(AppRoutes.clinicSelection);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل التحقق من رمز OTP');
    } finally {
      isLoading.value = false;
    }
  }

  // تسجيل دخول المريض (بدون OTP - فقط رقم الهاتف)
  Future<void> loginPatient(String phoneNumber) async {
    try {
      isLoading.value = true;
      
      // البحث عن المريض في Firebase
      final patient = await _firebaseService.getPatientByPhone(phoneNumber);
      
      if (patient == null) {
        isLoading.value = false;
        Get.snackbar('خطأ', 'لا يوجد حساب بهذا الرقم');
        return;
      }
      
      // إنشاء UserModel من PatientModel
      currentUser.value = UserModel(
        id: patient.id,
        name: patient.name,
        phoneNumber: patient.phoneNumber,
        userType: 'patient',
        gender: patient.gender,
        age: patient.age,
        city: patient.city,
      );
      
      isLoading.value = false;
      // توجيه المريض إلى اختيار العيادة
      Get.offAllNamed(AppRoutes.clinicSelection);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  // تسجيل دخول الطبيب (doctorId/doctorCode)
  Future<void> loginDoctor({
    required String doctorId,
    required String doctorCode,
  }) async {
    try {
      isLoading.value = true;
      
      // البحث عن الطبيب في Firebase
      final doctor = await _firebaseService.getDoctorByIdAndCode(
        doctorId.toUpperCase(),
        doctorCode,
      );
      
      if (doctor == null) {
        isLoading.value = false;
        Get.snackbar('خطأ', 'المعرف أو الرمز غير صحيح');
        return;
      }
      
      currentUser.value = doctor;
      
      // ربط العيادة بالطبيب إذا كان clinicId موجود
      if (doctor.clinicId != null) {
        final clinicController = Get.find<ClinicController>();
        final clinic = await clinicController.getClinicById(doctor.clinicId!);
        if (clinic != null) {
          clinicController.selectClinic(clinic);
        }
      }
      
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.doctorPatientsList);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  // تسجيل مريض جديد (حفظ مباشر في Firebase)
  Future<void> registerPatient({
    required String name,
    required String phoneNumber,
    required String gender,
    required int age,
    required String city,
  }) async {
    try {
      isLoading.value = true;
      
      // التحقق من وجود حساب بنفس الرقم
      final existingPatient = await _firebaseService.getPatientByPhone(phoneNumber);
      if (existingPatient != null) {
        isLoading.value = false;
        Get.snackbar('خطأ', 'يوجد حساب بهذا الرقم بالفعل');
        return;
      }
      
      // إنشاء مريض جديد
      final patient = PatientModel(
        id: 'patient_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        age: age,
        city: city,
      );
      
      // حفظ في Firebase
      await _firebaseService.createPatient(patient);
      
      // تسجيل الدخول تلقائياً
      currentUser.value = UserModel(
        id: patient.id,
        name: patient.name,
        phoneNumber: patient.phoneNumber,
        userType: 'patient',
        gender: patient.gender,
        age: patient.age,
        city: patient.city,
      );
      
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.clinicSelection);
      Get.snackbar('نجح', 'تم إنشاء الحساب وتسجيل الدخول بنجاح');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'حدث خطأ أثناء التسجيل: ${e.toString()}');
    }
  }
  
  // إنشاء حساب طبيب جديد
  Future<void> registerDoctor({
    required String doctorId,
    required String doctorCode,
    required String name,
    required String phoneNumber,
    required String clinicId,
  }) async {
    try {
      isLoading.value = true;
      
      // التحقق من وجود طبيب بنفس المعرف
      final existingDoctor = await _firebaseService.getDoctorByIdAndCode(doctorId, '');
      if (existingDoctor != null) {
        isLoading.value = false;
        Get.snackbar('خطأ', 'يوجد طبيب بهذا المعرف بالفعل');
        return;
      }
      
      // إنشاء طبيب جديد
      final doctor = UserModel(
        id: doctorId.toUpperCase(),
        name: name,
        phoneNumber: phoneNumber,
        userType: 'doctor',
        doctorId: doctorId.toUpperCase(),
        doctorCode: doctorCode,
        clinicId: clinicId,
      );
      
      // حفظ في Firebase
      await _firebaseService.createDoctor(doctor);
      
      isLoading.value = false;
      Get.snackbar('نجح', 'تم إنشاء حساب الطبيب بنجاح');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'حدث خطأ أثناء التسجيل: ${e.toString()}');
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.userSelection);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل الخروج');
    }
  }
}
