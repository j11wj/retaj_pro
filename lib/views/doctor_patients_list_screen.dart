import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/widgets/empty_state_widget.dart';
import 'package:farah_sys_final/core/widgets/loading_widget.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/views/barcode_scanner_screen.dart';

class DoctorPatientsListScreen extends StatefulWidget {
  const DoctorPatientsListScreen({super.key});

  @override
  State<DoctorPatientsListScreen> createState() => _DoctorPatientsListScreenState();
}

class _DoctorPatientsListScreenState extends State<DoctorPatientsListScreen> {
  final PatientController _patientController = Get.find<PatientController>();
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearching = false.obs;
  final RxList<PatientModel> _filteredPatients = <PatientModel>[].obs;

  @override
  void initState() {
    super.initState();
    // Load patients on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _patientController.loadPatients();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _filteredPatients.clear();
      _isSearching.value = false;
    } else {
      final results = _patientController.searchPatients(query);
      _filteredPatients.value = results;
      _isSearching.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _showBarcodeScanner(),
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                    tooltip: 'مسح الباركود',
                  ),
                  Text(
                    'قائمة المرضى',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_isSearching.value) {
                        _searchController.clear();
                        _isSearching.value = false;
                      } else {
                        _showSearchDialog();
                      }
                    },
                    icon: Icon(
                      _isSearching.value ? Icons.close : Icons.search,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (_isSearching.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مريض بالاسم أو رقم الهاتف...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _isSearching.value = false;
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                if (_patientController.isLoading.value) {
                  return const LoadingWidget(message: 'جاري تحميل المرضى...');
                }

                final patientsToShow = _isSearching.value && _searchController.text.trim().isNotEmpty
                    ? _filteredPatients
                    : _patientController.patients;

                if (patientsToShow.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: _isSearching.value ? 'لا توجد نتائج' : 'لا يوجد مرضى',
                    subtitle: _isSearching.value ? 'لم يتم العثور على مرضى بهذا الاسم' : 'لم يتم إضافة أي مريض بعد',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: patientsToShow.length,
                  itemBuilder: (context, index) {
                    final patient = patientsToShow[index];
                    return GestureDetector(
                      onTap: () {
                        _patientController.selectPatient(patient);
                        Get.toNamed(
                          AppRoutes.patientDetails,
                          arguments: {'patientId': patient.id},
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Phone Icon
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.phone,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Phone Number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رقم الهاتف',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  patient.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Patient Info
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    patient.name,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Wrap(
                                    spacing: 6.w,
                                    runSpacing: 6.h,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          '${patient.age} سنة',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          patient.gender == 'male' ? 'ذكر' : 'أنثى',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // Avatar
                            Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.white,
                                size: 30.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    _isSearching.value = true;
  }

  void _showBarcodeScanner() {
    Get.to(() => BarcodeScannerScreen());
  }
}
