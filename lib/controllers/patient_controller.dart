import 'package:get/get.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';

class PatientController extends GetxController {
  final _firebaseService = FirebaseService();
  
  final RxList<PatientModel> patients = <PatientModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<PatientModel?> selectedPatient = Rx<PatientModel?>(null);
  final Rx<PatientModel?> myProfile = Rx<PatientModel?>(null);


  // جلب قائمة المرضى (للطبيب)
  Future<void> loadPatients({int skip = 0, int limit = 50}) async {
    try {
      isLoading.value = true;
      // جلب جميع المرضى من Firebase
      final patientsList = await _firebaseService.getAllPatients();
      patients.value = patientsList;
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل المرضى: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب بيانات المريض الحالي (للمريض)
  Future<void> loadMyProfile() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null || currentUser.userType != 'patient') {
        print('المستخدم غير مريض أو غير مسجل دخول'); // للتشخيص
        isLoading.value = false;
        return;
      }
      
      print('جلب بيانات المريض برقم الهاتف: ${currentUser.phoneNumber}'); // للتشخيص
      
      // جلب بيانات المريض من Firebase
      final patient = await _firebaseService.getPatientByPhone(currentUser.phoneNumber);
      
      if (patient == null) {
        print('لم يتم العثور على بيانات المريض'); // للتشخيص
        Get.snackbar('خطأ', 'لم يتم العثور على بيانات المريض');
        myProfile.value = null;
      } else {
        print('تم جلب بيانات المريض: ${patient.name}'); // للتشخيص
        myProfile.value = patient;
      }
    } catch (e) {
      print('خطأ في loadMyProfile: $e'); // للتشخيص
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل البيانات: ${e.toString()}');
      myProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // تحديد نوع العلاج (للطبيب)
  Future<void> setTreatmentType({
    required String patientId,
    required String treatmentType,
  }) async {
    try {
      isLoading.value = true;
      
      // تحديث في Firebase
      final patient = patients.firstWhere((p) => p.id == patientId);
      final updatedHistory = <String>[...(patient.treatmentHistory ?? <String>[]), treatmentType];
      
      await _firebaseService.updatePatient(patientId, {
        'treatmentHistory': updatedHistory,
      });
      
      // تحديث القائمة
      final index = patients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        patients[index] = PatientModel(
          id: patient.id,
          name: patient.name,
          phoneNumber: patient.phoneNumber,
          gender: patient.gender,
          age: patient.age,
          city: patient.city,
          imageUrl: patient.imageUrl,
          doctorId: patient.doctorId,
          treatmentHistory: updatedHistory,
        );
      }
      
      Get.snackbar('نجح', 'تم تحديث نوع العلاج');
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحديث نوع العلاج: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  PatientModel? getPatientById(String patientId) {
    try {
      return patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      return null;
    }
  }

  List<PatientModel> searchPatients(String query) {
    if (query.isEmpty) return patients;

    return patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase()) ||
          patient.phoneNumber.contains(query);
    }).toList();
  }

  void selectPatient(PatientModel? patient) {
    selectedPatient.value = patient;
  }

  // تحديث بيانات المريض
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _firebaseService.updatePatient(patientId, data);
      
      // تحديث البيانات المحلية
      final index = patients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        final patient = patients[index];
        patients[index] = PatientModel(
          id: patient.id,
          name: data['name'] ?? patient.name,
          phoneNumber: patient.phoneNumber,
          gender: data['gender'] ?? patient.gender,
          age: data['age'] ?? patient.age,
          city: data['city'] ?? patient.city,
          imageUrl: patient.imageUrl,
          doctorId: patient.doctorId,
          treatmentHistory: patient.treatmentHistory,
        );
      }
      
      // تحديث myProfile إذا كان نفس المريض
      if (myProfile.value?.id == patientId) {
        final profile = myProfile.value!;
        myProfile.value = PatientModel(
          id: profile.id,
          name: data['name'] ?? profile.name,
          phoneNumber: profile.phoneNumber,
          gender: data['gender'] ?? profile.gender,
          age: data['age'] ?? profile.age,
          city: data['city'] ?? profile.city,
          imageUrl: profile.imageUrl,
          doctorId: profile.doctorId,
          treatmentHistory: profile.treatmentHistory,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحديث البيانات: ${e.toString()}');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
