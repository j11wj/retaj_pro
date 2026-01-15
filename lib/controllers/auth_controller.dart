import 'package:get/get.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/services/auth_service.dart';
import 'package:farah_sys_final/core/network/api_exception.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';

class AuthController extends GetxController {
  final _authService = AuthService();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString otpCode = ''.obs;

  // وضع العرض فقط (بدون Backend)
  static const bool demoMode = true;

  @override
  void onInit() {
    super.onInit();
    // تعطيل التحقق من تسجيل الدخول في وضع العرض
    // checkLoggedInUser();
  }

  Future<void> checkLoggedInUser() async {
    if (demoMode) return;
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

  // طلب إرسال OTP
  Future<void> requestOtp(String phoneNumber) async {
    if (demoMode) {
      // في وضع العرض، فقط ننتظر قليلاً ثم ننتقل
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
      Get.snackbar('نجح', 'تم إرسال رمز التحقق (وضع العرض)');
      return;
    }
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

  // التحقق من OTP وتسجيل الدخول
  Future<void> verifyOtpAndLogin({
    required String phoneNumber,
    required String code,
    String? name,
    String? gender,
    int? age,
    String? city,
  }) async {
    if (demoMode) {
      // في وضع العرض، ننشئ مستخدم تجريبي
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      currentUser.value = UserModel(
        id: 'demo_patient_1',
        name: name ?? 'مريض تجريبي',
        phoneNumber: phoneNumber,
        userType: 'patient',
        gender: gender,
        age: age,
        city: city,
      );
      
      isLoading.value = false;
      // توجيه المريض إلى اختيار العيادة
      Get.offAllNamed(AppRoutes.clinicSelection);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
      return;
    }
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

  // تسجيل دخول المريض (مع OTP)
  Future<void> loginPatient(String phoneNumber) async {
    await requestOtp(phoneNumber);
  }

  // تسجيل دخول الطبيب (doctorId/doctorCode)
  Future<void> loginDoctor({
    required String doctorId,
    required String doctorCode,
  }) async {
    if (demoMode) {
      // في وضع العرض، نتحقق من الرمز ونربط الطبيب بالعيادة
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      // بيانات الأطباء التجريبية مع معرفاتهم ورموزهم
      final doctors = {
        'DR001': {'code': '1234', 'name': 'د. سجاد الساعاتي', 'clinicId': 'clinic_1'},
        'DR002': {'code': '5678', 'name': 'د. أحمد محمد', 'clinicId': 'clinic_2'},
        'DR003': {'code': '9012', 'name': 'د. فاطمة علي', 'clinicId': 'clinic_3'},
        'DR004': {'code': '3456', 'name': 'د. محمود حسن', 'clinicId': 'clinic_4'},
        'DR005': {'code': '7890', 'name': 'د. ليلى أحمد', 'clinicId': 'clinic_5'},
        'DR006': {'code': '2468', 'name': 'د. سارة خالد', 'clinicId': 'clinic_6'},
        'DR007': {'code': '1357', 'name': 'د. عمر يوسف', 'clinicId': 'clinic_7'},
        'DR008': {'code': '9753', 'name': 'د. خالد إبراهيم', 'clinicId': 'clinic_8'},
        'DR009': {'code': '8642', 'name': 'د. نادر سالم', 'clinicId': 'clinic_9'},
        'DR010': {'code': '7410', 'name': 'د. ريم عبدالله', 'clinicId': 'clinic_10'},
        'DR011': {'code': '3691', 'name': 'د. مها زيد', 'clinicId': 'clinic_11'},
        'DR012': {'code': '2580', 'name': 'د. وائل ناصر', 'clinicId': 'clinic_12'},
      };
      
      final doctorData = doctors[doctorId.toUpperCase()];
      
      if (doctorData == null || doctorData['code'] != doctorCode) {
        isLoading.value = false;
        Get.snackbar('خطأ', 'المعرف أو الرمز غير صحيح');
        return;
      }
      
      // ربط العيادة بالطبيب
      final clinicController = Get.find<ClinicController>();
      final clinic = clinicController.getClinicById(doctorData['clinicId']!);
      if (clinic != null) {
        clinicController.selectClinic(clinic);
      }
      
      currentUser.value = UserModel(
        id: 'doctor_${doctorId.toLowerCase()}',
        name: doctorData['name']!,
        phoneNumber: '07901234567',
        userType: 'doctor',
        gender: 'male',
        age: 35,
        city: 'بغداد',
        doctorId: doctorId.toUpperCase(),
        doctorCode: doctorCode,
        clinicId: doctorData['clinicId'],
      );
      
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.doctorPatientsList);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
      return;
    }
    try {
      isLoading.value = true;
      final user = await _authService.staffLogin(
        username: doctorId,
        password: doctorCode,
      );
      
      currentUser.value = user;
      
      // ربط العيادة بالطبيب إذا كان clinicId موجود
      if (user.clinicId != null) {
        final clinicController = Get.find<ClinicController>();
        final clinic = clinicController.getClinicById(user.clinicId!);
        if (clinic != null) {
          clinicController.selectClinic(clinic);
        }
      }
      
      Get.offAllNamed(AppRoutes.doctorPatientsList);
      Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تسجيل الدخول');
    } finally {
      isLoading.value = false;
    }
  }

  // تسجيل مريض جديد (مع OTP)
  Future<void> registerPatient({
    required String name,
    required String phoneNumber,
    required String gender,
    required int age,
    required String city,
  }) async {
    try {
      isLoading.value = true;
      // أولاً طلب OTP
      await _authService.requestOtp(phoneNumber);
      Get.snackbar('نجح', 'تم إرسال رمز التحقق. يرجى إدخال الرمز لإكمال التسجيل');
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء التسجيل');
    } finally {
      isLoading.value = false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    if (demoMode) {
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.userSelection);
      return;
    }
    try {
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.userSelection);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تسجيل الخروج');
    }
  }
}
