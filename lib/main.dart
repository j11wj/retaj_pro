import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:farah_sys_final/core/theme/app_theme.dart';
import 'package:farah_sys_final/core/routes/app_routes.dart';
import 'package:farah_sys_final/views/splash_screen.dart';
import 'package:farah_sys_final/views/user_selection_screen.dart';
import 'package:farah_sys_final/views/patient_login_screen.dart';
import 'package:farah_sys_final/views/doctor_login_screen.dart';
import 'package:farah_sys_final/views/add_patient_screen.dart';
import 'package:farah_sys_final/views/patient_home_screen.dart';
import 'package:farah_sys_final/views/appointments_screen.dart';
import 'package:farah_sys_final/views/chat_screen.dart';
import 'package:farah_sys_final/views/patient_profile_screen.dart';
import 'package:farah_sys_final/views/edit_patient_profile_screen.dart';
import 'package:farah_sys_final/views/qr_code_screen.dart';
import 'package:farah_sys_final/views/doctor_patients_list_screen.dart';
import 'package:farah_sys_final/views/patient_details_screen.dart';
import 'package:farah_sys_final/views/otp_verification_screen.dart';
import 'package:farah_sys_final/models/user_model.dart';
import 'package:farah_sys_final/models/patient_model.dart';
import 'package:farah_sys_final/models/appointment_model.dart';
import 'package:farah_sys_final/models/medical_record_model.dart';
import 'package:farah_sys_final/models/message_model.dart';
import 'package:farah_sys_final/models/clinic_model.dart';
import 'package:farah_sys_final/controllers/auth_controller.dart';
import 'package:farah_sys_final/controllers/patient_controller.dart';
import 'package:farah_sys_final/controllers/appointment_controller.dart';
import 'package:farah_sys_final/controllers/chat_controller.dart';
import 'package:farah_sys_final/controllers/clinic_controller.dart';
import 'package:farah_sys_final/views/clinic_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(PatientModelAdapter());
  Hive.registerAdapter(AppointmentModelAdapter());
  Hive.registerAdapter(MedicalRecordModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ClinicModelAdapter());

  await Hive.openBox('users');
  await Hive.openBox('patients');
  await Hive.openBox('appointments');
  await Hive.openBox('medicalRecords');
  await Hive.openBox('messages');
  await Hive.openBox('clinics');

  // Initialize Controllers
  Get.put(AuthController());
  Get.put(PatientController());
  Get.put(AppointmentController());
  Get.put(ChatController());
  final clinicController = Get.put(ClinicController());
  
  // تهيئة العيادات مباشرة بعد إنشاء Controller
  clinicController.initializeClinics();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'مجمع بابل الطبي',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(
              name: AppRoutes.splash,
              page: () => const SplashScreen(),
            ),
            GetPage(
              name: AppRoutes.clinicSelection,
              page: () => const ClinicSelectionScreen(),
            ),
            GetPage(
              name: AppRoutes.userSelection,
              page: () => const UserSelectionScreen(),
            ),
            GetPage(
              name: AppRoutes.patientLogin,
              page: () => const PatientLoginScreen(),
            ),
            GetPage(
              name: AppRoutes.doctorLogin,
              page: () => const DoctorLoginScreen(),
            ),
            GetPage(
              name: AppRoutes.otpVerification,
              page: () {
                final args = Get.arguments as Map<String, dynamic>?;
                return OtpVerificationScreen(
                  phoneNumber: args?['phoneNumber'] ?? '',
                  name: args?['name'],
                  gender: args?['gender'],
                  age: args?['age'],
                  city: args?['city'],
                  isRegistration: args?['isRegistration'] ?? false,
                );
              },
            ),
            GetPage(
              name: AppRoutes.addPatient,
              page: () => const AddPatientScreen(),
            ),
            GetPage(
              name: AppRoutes.patientHome,
              page: () => const PatientHomeScreen(),
            ),
            GetPage(
              name: AppRoutes.doctorPatientsList,
              page: () => const DoctorPatientsListScreen(),
            ),
            GetPage(
              name: AppRoutes.patientDetails,
              page: () => const PatientDetailsScreen(),
            ),
            GetPage(
              name: AppRoutes.appointments,
              page: () => const AppointmentsScreen(),
            ),
            GetPage(
              name: AppRoutes.chat,
              page: () => const ChatScreen(),
            ),
            GetPage(
              name: AppRoutes.patientProfile,
              page: () => const PatientProfileScreen(),
            ),
            GetPage(
              name: AppRoutes.editPatientProfile,
              page: () => const EditPatientProfileScreen(),
            ),
            GetPage(
              name: AppRoutes.qrCode,
              page: () {
                final args = Get.arguments as Map<String, dynamic>?;
                return QrCodeScreen(
                  patientId: args?['patientId'] ?? '',
                  patientName: args?['patientName'] ?? 'مريض',
                );
              },
            ),
          ],
          builder: (context, widget) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: widget!,
            );
          },
        );
      },
    );
  }
}
