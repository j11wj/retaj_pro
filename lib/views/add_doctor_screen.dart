import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/widgets/custom_button.dart';
import 'package:farah_sys_final/core/widgets/custom_text_field.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final ClinicController _clinicController = Get.find<ClinicController>();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _doctorCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final RxString selectedClinicId = ''.obs;

  @override
  void initState() {
    super.initState();
    _clinicController.initializeClinics();
  }

  @override
  void dispose() {
    _doctorIdController.dispose();
    _doctorCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'إضافة طبيب جديد',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            children: [
              CustomTextField(
                labelText: 'معرف الطبيب',
                hintText: 'مثال: DR001',
                controller: _doctorIdController,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                labelText: 'الرمز الخاص',
                hintText: 'أدخل الرمز الخاص',
                controller: _doctorCodeController,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                labelText: 'اسم الطبيب',
                hintText: 'أدخل اسم الطبيب',
                controller: _nameController,
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                labelText: 'رقم الهاتف',
                hintText: '0000 000 0000',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'اختر العيادة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    final clinics = _clinicController.clinics;
                    final selectedClinic = selectedClinicId.value.isNotEmpty && clinics.isNotEmpty
                        ? clinics.firstWhereOrNull((c) => c.id == selectedClinicId.value)
                        : null;
                    
                    return GestureDetector(
                      onTap: () => _showClinicPicker(clinics),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              selectedClinic?.name ?? 'اختر العيادة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: selectedClinic != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 48.h),
              Obx(() => CustomButton(
                    text: 'إضافة طبيب',
                    onPressed: _authController.isLoading.value
                        ? null
                        : () async {
                            if (_doctorIdController.text.isEmpty ||
                                _doctorCodeController.text.isEmpty ||
                                _nameController.text.isEmpty ||
                                _phoneController.text.isEmpty ||
                                selectedClinicId.value.isEmpty) {
                              Get.snackbar(
                                'خطأ',
                                'يرجى ملء جميع الحقول',
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }

                            await _authController.registerDoctor(
                              doctorId: _doctorIdController.text.trim().toUpperCase(),
                              doctorCode: _doctorCodeController.text.trim(),
                              name: _nameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              clinicId: selectedClinicId.value,
                            );

                            Get.back();
                          },
                    width: double.infinity,
                    isLoading: _authController.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showClinicPicker(List clinics) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ...clinics.map((clinic) {
                return ListTile(
                  title: Text(
                    clinic.name,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    clinic.specialty,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  selected: selectedClinicId.value == clinic.id,
                  onTap: () {
                    selectedClinicId.value = clinic.id;
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}


