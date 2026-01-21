import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/models/appointment_model.dart';
import 'package:farah_sys_final/models/medical_record_model.dart';
import 'package:farah_sys_final/models/message_model.dart';

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

  /// تحديث بيانات عيادة
  Future<void> updateClinic(String clinicId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(clinicsCollection)
          .doc(clinicId)
          .update(data);
    } catch (e) {
      throw Exception('فشل تحديث بيانات العيادة: $e');
    }
  }

  /// حذف عيادة
  Future<void> deleteClinic(String clinicId) async {
    try {
      await _firestore
          .collection(clinicsCollection)
          .doc(clinicId)
          .delete();
    } catch (e) {
      throw Exception('فشل حذف العيادة: $e');
    }
  }

  /// تحديث بيانات طبيب
  Future<void> updateDoctor(String doctorId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(doctorsCollection)
          .doc(doctorId.toUpperCase())
          .update(data);
    } catch (e) {
      throw Exception('فشل تحديث بيانات الطبيب: $e');
    }
  }

  /// حذف طبيب
  Future<void> deleteDoctor(String doctorId) async {
    try {
      await _firestore
          .collection(doctorsCollection)
          .doc(doctorId.toUpperCase())
          .delete();
    } catch (e) {
      throw Exception('فشل حذف الطبيب: $e');
    }
  }

  /// جلب جميع الحجوزات
  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final querySnapshot = await _firestore
          .collection(appointmentsCollection)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppointmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('فشل جلب قائمة الحجوزات: $e');
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

  // ============ Appointments ============

  /// إضافة موعد جديد
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      print('إضافة موعد جديد للمريض: ${appointment.patientId}'); // للتشخيص
      final docRef = _firestore.collection(appointmentsCollection).doc();
      final appointmentData = {
        'id': docRef.id,
        'patientId': appointment.patientId,
        'patientName': appointment.patientName,
        'doctorId': appointment.doctorId,
        'doctorName': appointment.doctorName,
        'date': appointment.date.toIso8601String(),
        'scheduled_at': appointment.date.toIso8601String(), // للحفاظ على التوافق
        'time': appointment.time,
        'status': appointment.status,
        'notes': appointment.notes,
      };
      print('بيانات الموعد: $appointmentData'); // للتشخيص
      await docRef.set(appointmentData);
      print('تم حفظ الموعد بنجاح برقم: ${docRef.id}'); // للتشخيص
      return docRef.id;
    } catch (e) {
      print('خطأ في createAppointment: $e'); // للتشخيص
      throw Exception('فشل إضافة الموعد: $e');
    }
  }

  /// جلب مواعيد مريض محدد
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      print('جلب مواعيد المريض: $patientId'); // للتشخيص
      final querySnapshot = await _firestore
          .collection(appointmentsCollection)
          .where('patientId', isEqualTo: patientId)
          .get();

      print('تم العثور على ${querySnapshot.docs.length} موعد'); // للتشخيص

      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('معالجة موعد: ${doc.id}, patientId: ${data['patientId']}'); // للتشخيص
        return AppointmentModel.fromJson(data);
      }).toList();
      
      // ترتيب المواعيد حسب التاريخ (الأقدم أولاً)
      appointments.sort((a, b) => a.date.compareTo(b.date));
      
      return appointments;
    } catch (e) {
      print('خطأ في getPatientAppointments: $e'); // للتشخيص
      throw Exception('فشل جلب مواعيد المريض: $e');
    }
  }

  /// جلب مواعيد طبيب محدد
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      print('جلب مواعيد الطبيب: $doctorId'); // للتشخيص
      final querySnapshot = await _firestore
          .collection(appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print('تم العثور على ${querySnapshot.docs.length} موعد'); // للتشخيص

      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('معالجة موعد: ${doc.id}, doctorId: ${data['doctorId']}'); // للتشخيص
        return AppointmentModel.fromJson(data);
      }).toList();
      
      // ترتيب المواعيد حسب التاريخ (الأقدم أولاً)
      appointments.sort((a, b) => a.date.compareTo(b.date));
      
      return appointments;
    } catch (e) {
      print('خطأ في getDoctorAppointments: $e'); // للتشخيص
      throw Exception('فشل جلب مواعيد الطبيب: $e');
    }
  }

  // ============ Medical Records ============

  /// إضافة سجل طبي جديد
  Future<String> createMedicalRecord(MedicalRecordModel record) async {
    try {
      print('إضافة سجل طبي جديد للمريض: ${record.patientId}'); // للتشخيص
      final docRef = _firestore.collection(medicalRecordsCollection).doc();
      final recordData = {
        'id': docRef.id,
        'patientId': record.patientId,
        'doctorId': record.doctorId,
        'date': record.date.toIso8601String(),
        'created_at': record.date.toIso8601String(), // للحفاظ على التوافق
        'treatmentType': record.treatmentType,
        'diagnosis': record.diagnosis,
        'notes': record.notes,
        'images': record.images,
      };
      print('بيانات السجل: $recordData'); // للتشخيص
      await docRef.set(recordData);
      print('تم حفظ السجل بنجاح برقم: ${docRef.id}'); // للتشخيص
      return docRef.id;
    } catch (e) {
      print('خطأ في createMedicalRecord: $e'); // للتشخيص
      throw Exception('فشل إضافة السجل الطبي: $e');
    }
  }

  /// جلب سجلات مريض محدد
  Future<List<MedicalRecordModel>> getPatientMedicalRecords(String patientId) async {
    try {
      print('البحث عن السجلات للمريض: $patientId'); // للتشخيص
      final querySnapshot = await _firestore
          .collection(medicalRecordsCollection)
          .where('patientId', isEqualTo: patientId)
          .get();

      print('تم العثور على ${querySnapshot.docs.length} وثيقة'); // للتشخيص

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('معالجة سجل: ${doc.id}, patientId: ${data['patientId']}'); // للتشخيص
        return MedicalRecordModel.fromJson(data);
      }).toList();
      
      // ترتيب السجلات حسب التاريخ (الأحدث أولاً)
      records.sort((a, b) => b.date.compareTo(a.date));
      
      return records;
    } catch (e) {
      print('خطأ في getPatientMedicalRecords: $e'); // للتشخيص
      throw Exception('فشل جلب السجلات الطبية: $e');
    }
  }

  /// جلب مريض بالمعرف (للمسح الباركود)
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      final doc = await _firestore
          .collection(patientsCollection)
          .doc(patientId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      return PatientModel.fromJson(data);
    } catch (e) {
      throw Exception('فشل جلب بيانات المريض: $e');
    }
  }

  // ============ Messages ============

  /// إرسال رسالة جديدة
  Future<String> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final docRef = _firestore.collection(messagesCollection).doc();
      final messageData = {
        'id': docRef.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      await docRef.set(messageData);
      return docRef.id;
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  /// جلب الرسائل بين مستخدمين (Stream للوقت الفعلي)
  Stream<List<MessageModel>> getMessagesStream({
    required String userId1,
    required String userId2,
  }) {
    try {
      final controller = StreamController<List<MessageModel>>();
      final allMessages = <String, MessageModel>{};
      
      // جلب الرسائل من كلا الاتجاهين
      final stream1 = _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: userId1)
          .where('receiverId', isEqualTo: userId2)
          .orderBy('timestamp', descending: false)
          .snapshots();

      final stream2 = _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .orderBy('timestamp', descending: false)
          .snapshots();

      StreamSubscription? sub1;
      StreamSubscription? sub2;
      
      void updateMessages() {
        final messages = allMessages.values.toList();
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        controller.add(messages);
      }
      
      sub1 = stream1.listen(
        (snapshot) {
          // معالجة التغييرات في Stream
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              // حذف الرسالة إذا تم حذفها
              allMessages.remove(change.doc.id);
            } else {
              // إضافة أو تحديث الرسالة
              final data = change.doc.data();
              if (data != null) {
                data['id'] = change.doc.id;
                if (data['timestamp'] == null) {
                  data['timestamp'] = DateTime.now().toIso8601String();
                } else if (data['timestamp'] is Timestamp) {
                  data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
                }
                try {
                  final message = MessageModel.fromJson(data);
                  allMessages[message.id] = message;
                } catch (e) {
                  print('خطأ في تحويل الرسالة: $e');
                }
              }
            }
          }
          updateMessages();
        },
        onError: (error) {
          print('خطأ في stream1: $error');
          controller.addError(error);
        },
      );
      
      sub2 = stream2.listen(
        (snapshot) {
          // معالجة التغييرات في Stream
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              // حذف الرسالة إذا تم حذفها
              allMessages.remove(change.doc.id);
            } else {
              // إضافة أو تحديث الرسالة
              final data = change.doc.data();
              if (data != null) {
                data['id'] = change.doc.id;
                if (data['timestamp'] == null) {
                  data['timestamp'] = DateTime.now().toIso8601String();
                } else if (data['timestamp'] is Timestamp) {
                  data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
                }
                try {
                  final message = MessageModel.fromJson(data);
                  allMessages[message.id] = message;
                } catch (e) {
                  print('خطأ في تحويل الرسالة: $e');
                }
              }
            }
          }
          updateMessages();
        },
        onError: (error) {
          print('خطأ في stream2: $error');
          controller.addError(error);
        },
      );
      
      controller.onCancel = () {
        sub1?.cancel();
        sub2?.cancel();
      };
      
      return controller.stream;
    } catch (e) {
      throw Exception('فشل جلب الرسائل: $e');
    }
  }

  /// جلب الرسائل (للاستخدام غير المتزامن)
  Future<List<MessageModel>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      print('جلب الرسائل: userId1=$userId1, userId2=$userId2'); // للتشخيص
      
      // جلب الرسائل من كلا الاتجاهين
      final query1 = await _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: userId1)
          .where('receiverId', isEqualTo: userId2)
          .orderBy('timestamp', descending: false)
          .limit(limit)
          .get();
      
      print('الرسائل المرسلة من $userId1 إلى $userId2: ${query1.docs.length}'); // للتشخيص

      final query2 = await _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .orderBy('timestamp', descending: false)
          .limit(limit)
          .get();
      
      print('الرسائل المرسلة من $userId2 إلى $userId1: ${query2.docs.length}'); // للتشخيص

      final allMessages = <String, MessageModel>{};
      
      for (var doc in query1.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['timestamp'] == null) {
          data['timestamp'] = DateTime.now().toIso8601String();
        } else if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        final message = MessageModel.fromJson(data);
        allMessages[message.id] = message;
      }
      
      for (var doc in query2.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['timestamp'] == null) {
          data['timestamp'] = DateTime.now().toIso8601String();
        } else if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        final message = MessageModel.fromJson(data);
        allMessages[message.id] = message;
      }
      
      final messages = allMessages.values.toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      print('إجمالي الرسائل: ${messages.length}'); // للتشخيص
      return messages;
    } catch (e) {
      throw Exception('فشل جلب الرسائل: $e');
    }
  }

  /// تحديث حالة القراءة للرسائل
  Future<void> markMessagesAsRead({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('فشل تحديث حالة القراءة: $e');
    }
  }

  // ============ Demo Data ============

  /// إضافة بيانات تجريبية للاختبار (أطباء، مرضى، حجوزات)
  Future<void> seedDemoData() async {
    try {
      // التحقق من وجود بيانات
      final existingPatients = await getAllPatients();
      final existingDoctors = await getAllDoctors();
      final existingAppointments = await getAllAppointments();

      if (existingPatients.isNotEmpty || existingDoctors.isNotEmpty || existingAppointments.isNotEmpty) {
        print('يوجد بيانات موجودة بالفعل. سيتم إضافة بيانات إضافية فقط.');
      }

      // جلب العيادات
      final clinics = await getAllClinics();
      if (clinics.isEmpty) {
        await seedClinics();
        final updatedClinics = await getAllClinics();
        clinics.addAll(updatedClinics);
      }

      // إنشاء أطباء تجريبيين
      final demoDoctors = [
        UserModel(
          id: '',
          name: 'د. سجاد الساعاتي',
          phoneNumber: '07901234567',
          userType: 'doctor',
          doctorId: 'DOC001',
          doctorCode: '1234',
          clinicId: clinics.isNotEmpty ? clinics[0].id : 'clinic_1',
        ),
        UserModel(
          id: '',
          name: 'د. أحمد محمد',
          phoneNumber: '07901234568',
          userType: 'doctor',
          doctorId: 'DOC002',
          doctorCode: '5678',
          clinicId: clinics.length > 1 ? clinics[1].id : clinics.isNotEmpty ? clinics[0].id : 'clinic_2',
        ),
        UserModel(
          id: '',
          name: 'د. فاطمة علي',
          phoneNumber: '07901234569',
          userType: 'doctor',
          doctorId: 'DOC003',
          doctorCode: '9012',
          clinicId: clinics.length > 2 ? clinics[2].id : clinics.isNotEmpty ? clinics[0].id : 'clinic_3',
        ),
        UserModel(
          id: '',
          name: 'د. محمود حسن',
          phoneNumber: '07901234570',
          userType: 'doctor',
          doctorId: 'DOC004',
          doctorCode: '3456',
          clinicId: clinics.length > 3 ? clinics[3].id : clinics.isNotEmpty ? clinics[0].id : 'clinic_4',
        ),
        UserModel(
          id: '',
          name: 'د. ليلى أحمد',
          phoneNumber: '07901234571',
          userType: 'doctor',
          doctorId: 'DOC005',
          doctorCode: '7890',
          clinicId: clinics.length > 4 ? clinics[4].id : clinics.isNotEmpty ? clinics[0].id : 'clinic_5',
        ),
      ];

      // إضافة الأطباء
      for (var doctor in demoDoctors) {
        try {
          final existing = await getDoctorByIdAndCode(doctor.doctorId!, '');
          if (existing == null) {
            await createDoctor(doctor);
            print('تم إضافة الطبيب: ${doctor.name}');
          }
        } catch (e) {
          print('خطأ في إضافة الطبيب ${doctor.name}: $e');
        }
      }

      // جلب الأطباء المضافة
      final addedDoctors = await getAllDoctors();

      // إنشاء مرضى تجريبيين
      final demoPatients = [
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_1',
          name: 'محمد علي',
          phoneNumber: '07911111111',
          gender: 'ذكر',
          age: 35,
          city: 'بغداد',
          doctorId: addedDoctors.isNotEmpty ? addedDoctors[0].doctorId : 'DOC001',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_2',
          name: 'فاطمة أحمد',
          phoneNumber: '07922222222',
          gender: 'أنثى',
          age: 28,
          city: 'البصرة',
          doctorId: addedDoctors.length > 1 ? addedDoctors[1].doctorId : 'DOC002',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_3',
          name: 'علي حسن',
          phoneNumber: '07933333333',
          gender: 'ذكر',
          age: 45,
          city: 'الموصل',
          doctorId: addedDoctors.length > 2 ? addedDoctors[2].doctorId : 'DOC003',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_4',
          name: 'سارة محمود',
          phoneNumber: '07944444444',
          gender: 'أنثى',
          age: 32,
          city: 'أربيل',
          doctorId: addedDoctors.length > 3 ? addedDoctors[3].doctorId : 'DOC004',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_5',
          name: 'حسن كريم',
          phoneNumber: '07955555555',
          gender: 'ذكر',
          age: 50,
          city: 'كربلاء',
          doctorId: addedDoctors.length > 4 ? addedDoctors[4].doctorId : 'DOC005',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_6',
          name: 'نورا خالد',
          phoneNumber: '07966666666',
          gender: 'أنثى',
          age: 25,
          city: 'السليمانية',
          doctorId: addedDoctors.isNotEmpty ? addedDoctors[0].doctorId : 'DOC001',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_7',
          name: 'يوسف عمر',
          phoneNumber: '07977777777',
          gender: 'ذكر',
          age: 40,
          city: 'النجف',
          doctorId: addedDoctors.length > 1 ? addedDoctors[1].doctorId : 'DOC002',
        ),
        PatientModel(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}_8',
          name: 'ريم علي',
          phoneNumber: '07988888888',
          gender: 'أنثى',
          age: 30,
          city: 'بابل',
          doctorId: addedDoctors.length > 2 ? addedDoctors[2].doctorId : 'DOC003',
        ),
      ];

      // إضافة المرضى
      for (var patient in demoPatients) {
        try {
          final existing = await getPatientByPhone(patient.phoneNumber);
          if (existing == null) {
            await createPatient(patient);
            print('تم إضافة المريض: ${patient.name}');
          }
        } catch (e) {
          print('خطأ في إضافة المريض ${patient.name}: $e');
        }
      }

      // جلب المرضى المضافة
      final addedPatients = await getAllPatients();

      // التاريخ الحالي: 2026-1-21
      final currentDate = DateTime(2026, 1, 21);
      
      // إنشاء حجوزات للشهر السابق (ديسمبر 2025)
      final lastMonthAppointments = <AppointmentModel>[];
      for (int i = 0; i < 10; i++) {
        final day = 1 + (i % 28); // توزيع على أيام الشهر
        final hour = 9 + (i % 8); // من 9 صباحاً إلى 5 مساءً
        final appointmentDate = DateTime(2025, 12, day, hour, (i % 2) * 30);
        
        if (addedPatients.isNotEmpty && addedDoctors.isNotEmpty) {
          final patient = addedPatients[i % addedPatients.length];
          final doctor = addedDoctors[i % addedDoctors.length];
          
          lastMonthAppointments.add(AppointmentModel(
            id: '',
            patientId: patient.id,
            patientName: patient.name,
            doctorId: doctor.doctorId ?? doctor.id,
            doctorName: doctor.name,
            date: appointmentDate,
            time: '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}',
            status: 'completed',
            notes: 'حجز تجريبي - ديسمبر 2025',
          ));
        }
      }

      // إنشاء حجوزات للشهر الحالي (يناير 2026)
      final currentMonthAppointments = <AppointmentModel>[];
      for (int i = 0; i < 15; i++) {
        final day = 1 + (i % 21); // حتى 21 يناير
        final hour = 9 + (i % 8);
        final appointmentDate = DateTime(2026, 1, day, hour, (i % 2) * 30);
        
        // تحديد الحالة بناءً على التاريخ
        String status;
        if (appointmentDate.isBefore(currentDate)) {
          status = 'completed';
        } else if (appointmentDate.day == currentDate.day) {
          status = 'scheduled';
        } else {
          status = 'scheduled';
        }
        
        if (addedPatients.isNotEmpty && addedDoctors.isNotEmpty) {
          final patient = addedPatients[i % addedPatients.length];
          final doctor = addedDoctors[i % addedDoctors.length];
          
          currentMonthAppointments.add(AppointmentModel(
            id: '',
            patientId: patient.id,
            patientName: patient.name,
            doctorId: doctor.doctorId ?? doctor.id,
            doctorName: doctor.name,
            date: appointmentDate,
            time: '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}',
            status: status,
            notes: 'حجز تجريبي - يناير 2026',
          ));
        }
      }

      // إنشاء حجوزات للشهر القادم (فبراير 2026)
      final nextMonthAppointments = <AppointmentModel>[];
      for (int i = 0; i < 12; i++) {
        final day = 1 + (i % 28);
        final hour = 9 + (i % 8);
        final appointmentDate = DateTime(2026, 2, day, hour, (i % 2) * 30);
        
        if (addedPatients.isNotEmpty && addedDoctors.isNotEmpty) {
          final patient = addedPatients[i % addedPatients.length];
          final doctor = addedDoctors[i % addedDoctors.length];
          
          nextMonthAppointments.add(AppointmentModel(
            id: '',
            patientId: patient.id,
            patientName: patient.name,
            doctorId: doctor.doctorId ?? doctor.id,
            doctorName: doctor.name,
            date: appointmentDate,
            time: '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}',
            status: 'scheduled',
            notes: 'حجز تجريبي - فبراير 2026',
          ));
        }
      }

      // إضافة جميع الحجوزات
      final allAppointments = [
        ...lastMonthAppointments,
        ...currentMonthAppointments,
        ...nextMonthAppointments,
      ];

      for (var appointment in allAppointments) {
        try {
          await createAppointment(appointment);
        } catch (e) {
          print('خطأ في إضافة الحجز: $e');
        }
      }

      print('تم إضافة ${demoDoctors.length} طبيب، ${demoPatients.length} مريض، و ${allAppointments.length} حجز بنجاح');
    } catch (e) {
      throw Exception('فشل إضافة البيانات التجريبية: $e');
    }
  }
}

