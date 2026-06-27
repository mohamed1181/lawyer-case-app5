# تطبيق إدارة القضايا القانونية (Lawyer Case Management App)

## ⚠️ تنويه مهم
لا يمكن تجميع ملف APK من داخل محادثة Claude (لا تتوفر بيئة Flutter SDK ولا اتصال بـ pub.dev هنا).
هذا المجلد يحتوي **كود مصدري كامل وجاهز للتشغيل** — تحتاج فقط لتثبيت Flutter على جهاز الكمبيوتر
(مرة واحدة) ثم تشغيل أمرين لإخراج APK تثبّته على موبايلك مباشرة.

## خطوات تحويله إلى APK (٥ دقائق إذا كان Flutter مُثبّت لديك)

1. ثبّت Flutter SDK (إن لم يكن مثبتاً):
   https://docs.flutter.dev/get-started/install

2. افتح Terminal داخل مجلد المشروع `lawyer_case_app` ونفّذ:
   ```
   flutter pub get
   flutter build apk --release
   ```

3. ستجد ملف APK الجاهز للتثبيت في:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. انقل هذا الملف لموبايل الأندرويد (واتساب لنفسك / كابل / Google Drive) وثبّته
   (فعّل "السماح بالتثبيت من مصادر غير معروفة" إذا طلب منك ذلك).

## لتشغيله مباشرة على موبايل متصل بالكمبيوتر (بدون بناء APK):
```
flutter run
```

## بنية المشروع
```
lawyer_case_app/
├── pubspec.yaml                     # الحزم: Hive, Provider, intl ...
└── lib/
    ├── main.dart                    # نقطة البداية + تهيئة قاعدة البيانات
    ├── models/legal_case.dart       # نموذج القضية + مخطط قاعدة البيانات (Hive Adapter)
    ├── services/case_repository.dart# عمليات CRUD + البحث + الفلترة
    ├── providers/case_provider.dart # إدارة الحالة (State Management)
    ├── theme/app_theme.dart         # الهوية البصرية (Navy/Charcoal/Gold - Dark Mode)
    ├── widgets/case_card.dart       # بطاقة عرض القضية
    └── screens/
        ├── dashboard_screen.dart    # الداشبورد: جلسات اليوم + بحث + فلاتر + القائمة
        ├── quick_add_screen.dart    # شاشة الإضافة السريعة
        └── case_details_screen.dart # تفاصيل وحذف القضية
```

## مخطط قاعدة البيانات (Hive Box: legal_cases_box)
كل قضية (LegalCase) تحتوي الحقول:
رقم القضية، السنة، نوع القضية، الخصوم، المحكمة، تاريخ الجلسة القادمة،
سجل الجلسات، مواعيد الطعون، الموقف القانوني، الملاحظات، المرفقات، تواريخ الإنشاء/التعديل.

## لإضافة "إشعارات تلقائية" بمواعيد الجلسات (تطوير لاحق)
الحزمة `flutter_local_notifications` مضافة بالفعل في pubspec.yaml — يحتاج فقط
ربطها بدالة جدولة في `case_repository.dart` عند إضافة/تعديل تاريخ الجلسة.

## للتعديل أو إعادة التصميم
أرسل لي أي تعديل تريده (إضافة شاشة، حقل جديد، شعار، أو تغيير الألوان) وسأحدّث الملفات فوراً.
