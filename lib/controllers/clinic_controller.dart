import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class ClinicController extends GetxController {
  final RxList<ClinicModel> clinics = <ClinicModel>[].obs;
  final Rx<ClinicModel?> selectedClinic = Rx<ClinicModel?>(null);
  final RxBool isLoading = true.obs;
  
  final _firebaseService = FirebaseService();
  Box<ClinicModel>? _clinicBox;
  
  Box<ClinicModel> get clinicBox {
    _clinicBox ??= Hive.box<ClinicModel>('clinics');
    return _clinicBox!;
  }

  @override
  void onInit() {
    super.onInit();
    initializeClinics();
  }

  Future<void> initializeClinics() async {
    try {
      isLoading.value = true;
      
      // تحميل العيادات من Firebase
      final firebaseClinics = await _firebaseService.getAllClinics();
      
      if (firebaseClinics.isEmpty) {
        // إذا لم توجد عيادات في Firebase، أضف البيانات التجريبية
        await _firebaseService.seedClinics();
        await loadClinics();
      } else {
        clinics.value = firebaseClinics;
      }
    } catch (e) {
      // في حالة وجود خطأ، أضف العيادات مباشرة
      try {
        await _firebaseService.seedClinics();
        await loadClinics();
      } catch (e2) {
        // خطأ في إضافة العيادات
      }
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loadClinics() async {
    try {
      // تحميل من Firebase
      final loadedClinics = await _firebaseService.getAllClinics();
      clinics.value = loadedClinics;
    } catch (e) {
      clinics.value = [];
    }
  }

  void selectClinic(ClinicModel clinic) {
    selectedClinic.value = clinic;
  }

  Future<ClinicModel?> getClinicById(String id) async {
    try {
      return await _firebaseService.getClinicById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addClinic(ClinicModel clinic) async {
    await clinicBox.put(clinic.id, clinic);
    await loadClinics();
  }

  Future<void> deleteClinic(String id) async {
    await clinicBox.delete(id);
    await loadClinics();
  }

  // طريقة لإجبار إضافة العيادات مباشرة
  Future<void> forceAddClinics() async {
    try {
      isLoading.value = true;
      
      // إنشاء قائمة العيادات مباشرة
      final demoClinics = [
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
      
      // إضافة العيادات مباشرة إلى القائمة أولاً
      clinics.value = demoClinics;
      
      // ثم محاولة حفظها في Hive
      try {
        _clinicBox ??= Hive.box<ClinicModel>('clinics');
        await clinicBox.clear();
        for (var clinic in demoClinics) {
          await clinicBox.put(clinic.id, clinic);
        }
      } catch (e) {
        // إذا فشل Hive، العيادات موجودة في الذاكرة على أي حال
      }
    } catch (e) {
      // خطأ في إضافة العيادات
    } finally {
      isLoading.value = false;
    }
  }
}

