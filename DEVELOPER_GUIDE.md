# 👨‍💻 دليل المطور - Developer Guide

## 📚 جدول المحتويات

1. [البدء السريع](#البدء-السريع)
2. [هيكل المشروع](#هيكل-المشروع)
3. [إضافة شاشة جديدة](#إضافة-شاشة-جديدة)
4. [إضافة Controller جديد](#إضافة-controller-جديد)
5. [إضافة Model جديد](#إضافة-model-جديد)
6. [العمل مع Hive](#العمل-مع-hive)
7. [استخدام GetX](#استخدام-getx)
8. [الثيمات والألوان](#الثيمات-والألوان)
9. [أفضل الممارسات](#أفضل-الممارسات)

---

## 🚀 البدء السريع

### التثبيت الأولي

```bash
# 1. استنساخ المشروع
git clone <repository-url>
cd farah_sys_final

# 2. تثبيت الحزم
flutter pub get

# 3. توليد Hive Adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 4. تشغيل التطبيق
flutter run
```

### عند إضافة Model جديد

```bash
# بعد إضافة أو تعديل Model مع Hive
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📂 هيكل المشروع

```
lib/
├── 📁 controllers/           # GetX Controllers
│   ├── auth_controller.dart
│   ├── appointment_controller.dart
│   ├── chat_controller.dart
│   └── patient_controller.dart
│
├── 📁 models/               # Data Models (Hive)
│   ├── user_model.dart
│   ├── patient_model.dart
│   ├── appointment_model.dart
│   ├── medical_record_model.dart
│   └── message_model.dart
│
├── 📁 views/                # UI Screens
│   ├── splash_screen.dart
│   ├── user_selection_screen.dart
│   ├── patient_login_screen.dart
│   ├── patient_home_screen.dart
│   └── ...
│
└── 📁 core/
    ├── 📁 constants/        # الثوابت
    │   ├── app_colors.dart
    │   └── app_strings.dart
    │
    ├── 📁 theme/           # الثيم
    │   └── app_theme.dart
    │
    ├── 📁 routes/          # المسارات
    │   └── app_routes.dart
    │
    └── 📁 widgets/         # الويدجات المشتركة
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── gender_selector.dart
        ├── loading_widget.dart
        └── empty_state_widget.dart
```

---

## 🎨 إضافة شاشة جديدة

### الخطوات:

#### 1. إنشاء ملف الشاشة

```dart
// lib/views/my_new_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:farah_sys_final/core/constants/app_colors.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'شاشة جديدة',
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 2. إضافة Route

```dart
// lib/core/routes/app_routes.dart
class AppRoutes {
  // ... الروابط الموجودة
  static const String myNewScreen = '/my-new-screen';
}
```

#### 3. تسجيل الشاشة في main.dart

```dart
// lib/main.dart
import 'package:farah_sys_final/views/my_new_screen.dart';

// في getPages:
GetPage(
  name: AppRoutes.myNewScreen,
  page: () => const MyNewScreen(),
),
```

#### 4. الانتقال للشاشة

```dart
// من أي مكان في التطبيق
Get.toNamed(AppRoutes.myNewScreen);

// أو مع تمرير بيانات
Get.toNamed(AppRoutes.myNewScreen, arguments: {'id': '123'});

// استقبال البيانات في الشاشة
final arguments = Get.arguments;
```

---

## 🎮 إضافة Controller جديد

### الخطوات:

```dart
// lib/controllers/my_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MyController extends GetxController {
  // المتغيرات التفاعلية
  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;
  final RxList<String> items = <String>[].obs;

  // عند تهيئة الـ Controller
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // تحميل البيانات
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      // منطق التحميل هنا
      await Future.delayed(const Duration(seconds: 1));
      items.value = ['item 1', 'item 2'];
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // وظائف أخرى
  void addItem(String item) {
    items.add(item);
  }

  // عند إغلاق الـ Controller
  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }
}
```

### استخدام Controller في الشاشة:

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الـ Controller
    final controller = Get.put(MyController());

    return Scaffold(
      body: Obx(() {
        // استخدام المتغيرات التفاعلية
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            return Text(controller.items[index]);
          },
        );
      }),
    );
  }
}
```

---

## 📦 إضافة Model جديد

### الخطوات:

#### 1. إنشاء Model

```dart
// lib/models/my_model.dart
import 'package:hive/hive.dart';

part 'my_model.g.dart';

@HiveType(typeId: 5) // رقم فريد لكل Model
class MyModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // من JSON
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

#### 2. توليد Adapter

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. تسجيل Adapter في main.dart

```dart
void main() async {
  // ... الكود الموجود

  Hive.registerAdapter(MyModelAdapter());
  await Hive.openBox('myModels');

  // ...
}
```

---

## 💾 العمل مع Hive

### حفظ البيانات

```dart
Future<void> saveData() async {
  final box = await Hive.openBox('myBox');

  // حفظ قيمة بسيطة
  await box.put('key', 'value');

  // حفظ Model
  final myModel = MyModel(
    id: '1',
    name: 'Test',
    createdAt: DateTime.now(),
  );
  await box.put(myModel.id, myModel);
}
```

### قراءة البيانات

```dart
Future<void> loadData() async {
  final box = await Hive.openBox('myBox');

  // قراءة قيمة بسيطة
  final value = box.get('key');

  // قراءة Model
  final myModel = box.get('1') as MyModel?;

  // قراءة جميع القيم
  final allValues = box.values.toList();
}
```

### حذف البيانات

```dart
Future<void> deleteData() async {
  final box = await Hive.openBox('myBox');

  // حذف قيمة واحدة
  await box.delete('key');

  // حذف جميع القيم
  await box.clear();
}
```

---

## 🎯 استخدام GetX

### التنقل

```dart
// الانتقال لشاشة جديدة
Get.to(() => const NewScreen());

// الانتقال مع اسم
Get.toNamed(AppRoutes.newScreen);

// الرجوع
Get.back();

// الرجوع للشاشة الرئيسية
Get.offAllNamed(AppRoutes.home);
```

### Snackbar

```dart
Get.snackbar(
  'العنوان',
  'الرسالة',
  backgroundColor: AppColors.primary,
  colorText: AppColors.white,
);
```

### Dialog

```dart
Get.defaultDialog(
  title: 'تأكيد',
  middleText: 'هل أنت متأكد؟',
  textConfirm: 'نعم',
  textCancel: 'لا',
  onConfirm: () {
    // الكود هنا
    Get.back();
  },
);
```

---

## 🎨 الثيمات والألوان

### استخدام الألوان

```dart
import 'package:farah_sys_final/core/constants/app_colors.dart';

// في الويدجت
Container(
  color: AppColors.primary,
  child: Text(
    'نص',
    style: TextStyle(color: AppColors.white),
  ),
)
```

### إضافة لون جديد

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // ... الألوان الموجودة
  static const Color myNewColor = Color(0xFF123456);
}
```

---

## ✅ أفضل الممارسات

### 1. تسمية الملفات
- استخدم `snake_case` لأسماء الملفات
- مثال: `patient_home_screen.dart`

### 2. تسمية الـ Classes
- استخدم `PascalCase`
- مثال: `PatientHomeScreen`

### 3. تسمية المتغيرات
- استخدم `camelCase`
- مثال: `patientName`

### 4. الـ Widgets
- افصل الويدجات الكبيرة إلى ويدجات أصغر
- استخدم `const` حيثما أمكن

### 5. Controllers
- لا تضع منطق UI في الـ Controllers
- استخدم `try-catch` للأخطاء
- نظف الموارد في `onClose()`

### 6. التصميم المتجاوب
- استخدم `.w` للعرض
- استخدم `.h` للارتفاع
- استخدم `.sp` للخط
- مثال: `16.sp`, `100.w`, `50.h`

### 7. RTL Support
- جميع النصوص بالعربية تلقائياً RTL
- لا حاجة لإضافة `textDirection`

---

## 🔧 أدوات مفيدة

### تنظيف المشروع

```bash
flutter clean
flutter pub get
```

### فحص الأخطاء

```bash
flutter analyze
```

### تنسيق الكود

```bash
flutter format lib/
```

---

## 📞 المساعدة

إذا واجهت أي مشكلة:
1. تحقق من الوثائق
2. راجع الأمثلة في المشروع
3. افتح Issue في المستودع

---

**Happy Coding! 💙**
