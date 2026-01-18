import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/models/clinic_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String patientsCollection = 'patients';
  static const String doctorsCollection = 'doctors';
  static const String clinicsCollection = 'clinics';
  static const String appointmentsCollection = 'appointments';
  static const String medicalRecordsCollection = 'medicalRecords';
  static const String messagesCollection = 'messages';

  // ============ Patients ============
  
  /// حفظ بيانات مريض جديد
  Future<void> createPatient(PatientModel patient) async {
    try {
      await _firestore
          .collection(patientsCollection)
          .doc(patient.id)
          .set(patient.toJson());
    } catch (e) {
      throw Exception('فشل حفظ بيانات المريض: $e');
    }
  }

  /// جلب بيانات مريض برقم الهاتف
  Future<PatientModel?> getPatientByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(patientsCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return PatientModel.fromJson(data);
    } catch (e) {
      throw Exception('فشل جلب بيانات المريض: $e');
    }
  }

  /// تحديث بيانات مريض
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(patientsCollection)
          .doc(patientId)
          .update(data);
    } catch (e) {
      throw Exception('فشل تحديث بيانات المريض: $e');
    }
  }

  /// جلب جميع المرضى
  Future<List<PatientModel>> getAllPatients() async {
    try {
      final querySnapshot = await _firestore
          .collection(patientsCollection)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PatientModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('فشل جلب قائمة المرضى: $e');
    }
  }

  // ============ Doctors ============

  /// حفظ بيانات طبيب جديد
  Future<void> createDoctor(UserModel doctor) async {
    try {
      // استخدام doctorId كمعرف المستند
      final docId = doctor.doctorId ?? doctor.id;
      await _firestore
          .collection(doctorsCollection)
          .doc(docId)
          .set(doctor.toJson());
    } catch (e) {
      throw Exception('فشل حفظ بيانات الطبيب: $e');
    }
  }

  /// جلب بيانات طبيب بالمعرف والرمز
  Future<UserModel?> getDoctorByIdAndCode(String doctorId, String doctorCode) async {
    try {
      final doc = await _firestore
          .collection(doctorsCollection)
          .doc(doctorId.toUpperCase())
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      
      // إذا كان doctorCode فارغاً، نرجع البيانات فقط (للتحقق من الوجود)
      if (doctorCode.isNotEmpty && data['doctorCode'] != doctorCode) {
        return null;
      }

      data['id'] = doc.id;
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('فشل جلب بيانات الطبيب: $e');
    }
  }

  /// جلب جميع الأطباء
  Future<List<UserModel>> getAllDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection(doctorsCollection)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('فشل جلب قائمة الأطباء: $e');
    }
  }

  // ============ Clinics ============

  /// حفظ عيادة جديدة
  Future<void> createClinic(ClinicModel clinic) async {
    try {
      await _firestore
          .collection(clinicsCollection)
          .doc(clinic.id)
          .set(clinic.toJson());
    } catch (e) {
      throw Exception('فشل حفظ بيانات العيادة: $e');
    }
  }

  /// جلب جميع العيادات
  Future<List<ClinicModel>> getAllClinics() async {
    try {
      final querySnapshot = await _firestore
          .collection(clinicsCollection)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ClinicModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('فشل جلب قائمة العيادات: $e');
    }
  }

  /// جلب عيادة بالمعرف
  Future<ClinicModel?> getClinicById(String clinicId) async {
    try {
      final doc = await _firestore
          .collection(clinicsCollection)
          .doc(clinicId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      return ClinicModel.fromJson(data);
    } catch (e) {
      throw Exception('فشل جلب بيانات العيادة: $e');
    }
  }

  /// إضافة بيانات تجريبية للعيادات
  Future<void> seedClinics() async {
    try {
      final clinics = [
        ClinicModel(
          id: 'clinic_1',
          name: 'عيادة بابل للأسنان',
          specialty: 'طب الأسنان',
          description: 'عيادة متخصصة في طب الأسنان وعلاج جميع مشاكل الفم والأسنان',
          doctorName: 'د. سجاد الساعاتي',
          doctorPhone: '07901234567',
          location: 'الطابق الأول - غرفة 101',
        ),
        ClinicModel(
          id: 'clinic_2',
          name: 'عيادة بابل الباطنية',
          specialty: 'الباطنية',
          description: 'عيادة متخصصة في الأمراض الباطنية والفحوصات العامة',
          doctorName: 'د. أحمد محمد',
          doctorPhone: '07901234568',
          location: 'الطابق الأول - غرفة 102',
        ),
        ClinicModel(
          id: 'clinic_3',
          name: 'عيادة بابل الجلدية',
          specialty: 'الأمراض الجلدية',
          description: 'عيادة متخصصة في علاج الأمراض الجلدية والجمالية',
          doctorName: 'د. فاطمة علي',
          doctorPhone: '07901234569',
          location: 'الطابق الثاني - غرفة 201',
        ),
        ClinicModel(
          id: 'clinic_4',
          name: 'عيادة بابل العيون',
          specialty: 'طب العيون',
          description: 'عيادة متخصصة في علاج أمراض العيون وفحوصات النظر',
          doctorName: 'د. محمود حسن',
          doctorPhone: '07901234570',
          location: 'الطابق الثاني - غرفة 202',
        ),
        ClinicModel(
          id: 'clinic_5',
          name: 'عيادة بابل الأنف والأذن',
          specialty: 'الأنف والأذن والحنجرة',
          description: 'عيادة متخصصة في علاج أمراض الأنف والأذن والحنجرة',
          doctorName: 'د. ليلى أحمد',
          doctorPhone: '07901234571',
          location: 'الطابق الأول - غرفة 103',
        ),
        ClinicModel(
          id: 'clinic_6',
          name: 'عيادة بابل النسائية',
          specialty: 'النسائية والتوليد',
          description: 'عيادة متخصصة في صحة المرأة والولادة',
          doctorName: 'د. سارة خالد',
          doctorPhone: '07901234572',
          location: 'الطابق الثاني - غرفة 203',
        ),
        ClinicModel(
          id: 'clinic_7',
          name: 'عيادة بابل الأطفال',
          specialty: 'طب الأطفال',
          description: 'عيادة متخصصة في صحة الأطفال وعلاج الأمراض الشائعة',
          doctorName: 'د. عمر يوسف',
          doctorPhone: '07901234573',
          location: 'الطابق الأول - غرفة 104',
        ),
        ClinicModel(
          id: 'clinic_8',
          name: 'عيادة بابل العظام',
          specialty: 'جراحة العظام',
          description: 'عيادة متخصصة في علاج إصابات العظام والمفاصل',
          doctorName: 'د. خالد إبراهيم',
          doctorPhone: '07901234574',
          location: 'الطابق الثاني - غرفة 204',
        ),
        ClinicModel(
          id: 'clinic_9',
          name: 'عيادة بابل القلب',
          specialty: 'أمراض القلب',
          description: 'عيادة متخصصة في أمراض القلب والشرايين',
          doctorName: 'د. نادر سالم',
          doctorPhone: '07901234575',
          location: 'الطابق الأول - غرفة 105',
        ),
        ClinicModel(
          id: 'clinic_10',
          name: 'عيادة بابل الأعصاب',
          specialty: 'طب الأعصاب',
          description: 'عيادة متخصصة في أمراض الجهاز العصبي',
          doctorName: 'د. ريم عبدالله',
          doctorPhone: '07901234576',
          location: 'الطابق الثاني - غرفة 205',
        ),
        ClinicModel(
          id: 'clinic_11',
          name: 'عيادة بابل النفسية',
          specialty: 'الطب النفسي',
          description: 'عيادة متخصصة في الصحة النفسية والعلاج النفسي',
          doctorName: 'د. مها زيد',
          doctorPhone: '07901234577',
          location: 'الطابق الأول - غرفة 106',
        ),
        ClinicModel(
          id: 'clinic_12',
          name: 'عيادة بابل المسالك',
          specialty: 'المسالك البولية',
          description: 'عيادة متخصصة في أمراض المسالك البولية',
          doctorName: 'د. وائل ناصر',
          doctorPhone: '07901234578',
          location: 'الطابق الثاني - غرفة 206',
        ),
      ];

      final batch = _firestore.batch();
      for (var clinic in clinics) {
        final docRef = _firestore.collection(clinicsCollection).doc(clinic.id);
        batch.set(docRef, clinic.toJson());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('فشل إضافة بيانات العيادات: $e');
    }
  }
}

