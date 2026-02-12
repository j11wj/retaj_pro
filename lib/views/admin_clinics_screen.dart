import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/services/firebase_service.dart';

class AdminClinicsScreen extends StatefulWidget {
  const AdminClinicsScreen({super.key});

  @override
  State<AdminClinicsScreen> createState() => _AdminClinicsScreenState();
}

class _AdminClinicsScreenState extends State<AdminClinicsScreen> {
  final _firebaseService = FirebaseService();
  final RxList<ClinicModel> _clinics = <ClinicModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      _isLoading.value = true;
      final clinics = await _firebaseService.getAllClinics();
      _clinics.value = clinics;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل العيادات: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void _showAddEditClinicDialog({ClinicModel? clinic}) {
    final nameController = TextEditingController(text: clinic?.name ?? '');
    final specialtyController = TextEditingController(text: clinic?.specialty ?? '');
    final descriptionController = TextEditingController(text: clinic?.description ?? '');
    final doctorNameController = TextEditingController(text: clinic?.doctorName ?? '');
    final doctorPhoneController = TextEditingController(text: clinic?.doctorPhone ?? '');
    final locationController = TextEditingController(text: clinic?.location ?? '');

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
                  clinic == null ? 'إضافة عيادة جديدة' : 'تعديل العيادة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم العيادة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: specialtyController,
                  decoration: InputDecoration(
                    labelText: 'التخصص',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: doctorNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الطبيب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: doctorPhoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم هاتف الطبيب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'الموقع',
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
                        if (nameController.text.isEmpty || specialtyController.text.isEmpty) {
                          Get.snackbar('خطأ', 'يرجى ملء جميع الحقول المطلوبة');
                          return;
                        }

                        try {
                          final clinicModel = ClinicModel(
                            id: clinic?.id ?? 'clinic_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text,
                            specialty: specialtyController.text,
                            description: descriptionController.text.isEmpty
                                ? null
                                : descriptionController.text,
                            doctorName: doctorNameController.text.isEmpty
                                ? null
                                : doctorNameController.text,
                            doctorPhone: doctorPhoneController.text.isEmpty
                                ? null
                                : doctorPhoneController.text,
                            location: locationController.text.isEmpty
                                ? null
                                : locationController.text,
                          );

                          if (clinic == null) {
                            await _firebaseService.createClinic(clinicModel);
                            Get.snackbar('نجح', 'تم إضافة العيادة بنجاح');
                          } else {
                            await _firebaseService.updateClinic(
                              clinic.id,
                              clinicModel.toJson(),
                            );
                            Get.snackbar('نجح', 'تم تحديث العيادة بنجاح');
                          }

                          Get.back();
                          await _loadClinics();
                        } catch (e) {
                          Get.snackbar('خطأ', 'فشل العملية: ${e.toString()}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(clinic == null ? 'إضافة' : 'تحديث'),
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

  Future<void> _deleteClinic(ClinicModel clinic) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${clinic.name}؟'),
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
        await _firebaseService.deleteClinic(clinic.id);
        Get.snackbar('نجح', 'تم حذف العيادة بنجاح');
        await _loadClinics();
      } catch (e) {
        Get.snackbar('خطأ', 'فشل حذف العيادة: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة العيادات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
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

        if (_clinics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_hospital, size: 64.sp, color: AppColors.textSecondary),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد عيادات',
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
          itemCount: _clinics.length,
          itemBuilder: (context, index) {
            final clinic = _clinics[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.local_hospital, color: AppColors.primary),
                ),
                title: Text(
                  clinic.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التخصص: ${clinic.specialty}'),
                    if (clinic.doctorName != null)
                      Text('الطبيب: ${clinic.doctorName}'),
                    if (clinic.location != null)
                      Text('الموقع: ${clinic.location}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showAddEditClinicDialog(clinic: clinic),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClinic(clinic),
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
        onPressed: () => _showAddEditClinicDialog(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}



