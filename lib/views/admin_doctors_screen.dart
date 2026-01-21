import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  final _firebaseService = FirebaseService();
  final RxList<UserModel> _doctors = <UserModel>[].obs;
  final RxList<ClinicModel> _clinics = <ClinicModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _isLoading.value = true;
      final doctors = await _firebaseService.getAllDoctors();
      final clinics = await _firebaseService.getAllClinics();
      _doctors.value = doctors;
      _clinics.value = clinics;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل البيانات: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void _showAddEditDoctorDialog({UserModel? doctor}) {
    final doctorIdController = TextEditingController(text: doctor?.doctorId ?? '');
    final doctorCodeController = TextEditingController(text: doctor?.doctorCode ?? '');
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final phoneController = TextEditingController(text: doctor?.phoneNumber ?? '');
    final selectedClinicId = RxString(doctor?.clinicId ?? '');

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
                  doctor == null ? 'إضافة طبيب جديد' : 'تعديل الطبيب',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: doctorIdController,
                  enabled: doctor == null,
                  decoration: InputDecoration(
                    labelText: 'معرف الطبيب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: doctorCodeController,
                  decoration: InputDecoration(
                    labelText: 'الرمز الخاص',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedClinicId.value.isEmpty ? null : selectedClinicId.value,
                  decoration: InputDecoration(
                    labelText: 'العيادة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: _clinics.map((clinic) {
                    return DropdownMenuItem(
                      value: clinic.id,
                      child: Text(clinic.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedClinicId.value = value ?? '';
                  },
                )),
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
                        if (doctorIdController.text.isEmpty ||
                            doctorCodeController.text.isEmpty ||
                            nameController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            selectedClinicId.value.isEmpty) {
                          Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
                          return;
                        }

                        try {
                          final doctorModel = UserModel(
                            id: doctor?.id ?? '',
                            name: nameController.text,
                            phoneNumber: phoneController.text,
                            userType: 'doctor',
                            doctorId: doctorIdController.text.toUpperCase(),
                            doctorCode: doctorCodeController.text,
                            clinicId: selectedClinicId.value,
                          );

                          if (doctor == null) {
                            await _firebaseService.createDoctor(doctorModel);
                            Get.snackbar('نجح', 'تم إضافة الطبيب بنجاح');
                          } else {
                            await _firebaseService.updateDoctor(
                              doctor.doctorId ?? doctor.id,
                              doctorModel.toJson(),
                            );
                            Get.snackbar('نجح', 'تم تحديث الطبيب بنجاح');
                          }

                          Get.back();
                          await _loadData();
                        } catch (e) {
                          Get.snackbar('خطأ', 'فشل العملية: ${e.toString()}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: Text(doctor == null ? 'إضافة' : 'تحديث'),
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

  Future<void> _deleteDoctor(UserModel doctor) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${doctor.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteDoctor(doctor.doctorId ?? doctor.id);
        Get.snackbar('نجح', 'تم حذف الطبيب بنجاح');
        await _loadData();
      } catch (e) {
        Get.snackbar('خطأ', 'فشل حذف الطبيب: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الأطباء',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_doctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 64.sp, color: AppColors.textSecondary),
                SizedBox(height: 16.h),
                Text(
                  'لا يوجد أطباء',
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
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            final clinic = _clinics.firstWhereOrNull(
              (c) => c.id == doctor.clinicId,
            );

            return Card(
              margin: EdgeInsets.only(bottom: 16.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: AppColors.secondary),
                ),
                title: Text(
                  doctor.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المعرف: ${doctor.doctorId ?? doctor.id}'),
                    Text('الهاتف: ${doctor.phoneNumber}'),
                    if (clinic != null) Text('العيادة: ${clinic.name}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.secondary),
                      onPressed: () => _showAddEditDoctorDialog(doctor: doctor),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDoctor(doctor),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDoctorDialog(),
        backgroundColor: AppColors.secondary,
        child: Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}

