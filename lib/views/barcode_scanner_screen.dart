import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/services/firebase_service.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final FirebaseService _firebaseService = FirebaseService();
  final PatientController _patientController = Get.find<PatientController>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;
    
    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    _isProcessing = true;
    _processBarcode(barcode.rawValue!);
  }

  Future<void> _processBarcode(String patientId) async {
    try {
      // البحث عن المريض في Firebase
      final patient = await _firebaseService.getPatientById(patientId);
      
      if (patient == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على مريض بهذا المعرف',
          snackPosition: SnackPosition.TOP,
        );
        _isProcessing = false;
        return;
      }

      // التحقق من وجود المريض في القائمة المحلية
      final existingPatient = _patientController.getPatientById(patientId);
      if (existingPatient == null) {
        // إضافة المريض إلى القائمة المحلية
        _patientController.patients.add(patient);
      }

      // توجيه إلى صفحة تفاصيل المريض
      Get.back();
      _patientController.selectPatient(patient);
      Get.toNamed(
        AppRoutes.patientDetails,
        arguments: {'patientId': patientId},
      );
      
      Get.snackbar(
        'نجح',
        'تم العثور على المريض: ${patient.name}',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء معالجة الباركود: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'مسح الباركود',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetect,
          ),
          // Overlay with instructions
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'ضع الباركود داخل الإطار لمسحه',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Scanning frame overlay
          Center(
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


