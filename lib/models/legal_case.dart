import 'package:hive/hive.dart';

/// الموقف القانوني الحالي للقضية
enum CaseStatus {
  active,      // قيد النظر
  adjourned,   // مؤجلة
  appealed,    // بالطعن
  closedWon,   // مغلقة - حُكم لصالحنا
  closedLost,  // مغلقة - حُكم ضدنا
  archived,    // مؤرشفة
}

extension CaseStatusLabel on CaseStatus {
  String get arabicLabel {
    switch (this) {
      case CaseStatus.active:
        return 'قيد النظر';
      case CaseStatus.adjourned:
        return 'مؤجلة';
      case CaseStatus.appealed:
        return 'بالطعن';
      case CaseStatus.closedWon:
        return 'مغلقة (لصالحنا)';
      case CaseStatus.closedLost:
        return 'مغلقة (ضدنا)';
      case CaseStatus.archived:
        return 'مؤرشفة';
    }
  }
}

/// كائن القضية الأساسي - يمثل سجل واحد في قاعدة البيانات المحلية (Hive Box)
class LegalCase extends HiveObject {
  String caseNumber;       // رقم القضية
  String year;             // السنة
  String caseType;         // نوع القضية: جنائي / مدني / أحوال شخصية ...
  String parties;          // أسماء الخصوم والموكلين
  String court;            // المحكمة المختصة / الدائرة
  DateTime? nextSessionDate; // أقرب جلسة قادمة
  List<String> sessionHistory; // سجل تواريخ الجلسات السابقة (كنصوص ISO)
  List<String> appealDeadlines; // مواعيد الطعون والمواعيد الإجرائية (نصوص ISO)
  CaseStatus status;       // الموقف القانوني الحالي
  String notes;            // ملاحظات
  List<String> attachmentPaths; // مسارات الملفات المرفقة محلياً
  DateTime createdAt;
  DateTime updatedAt;

  LegalCase({
    required this.caseNumber,
    required this.year,
    required this.caseType,
    required this.parties,
    required this.court,
    this.nextSessionDate,
    List<String>? sessionHistory,
    List<String>? appealDeadlines,
    this.status = CaseStatus.active,
    this.notes = '',
    List<String>? attachmentPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : sessionHistory = sessionHistory ?? [],
        appealDeadlines = appealDeadlines ?? [],
        attachmentPaths = attachmentPaths ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// معرّف فريد قابل للعرض: رقم القضية / السنة
  String get displayId => '$caseNumber / $year';

  /// نص موحّد يُستخدم في فهرسة البحث (لتسريع الاستعلامات)
  String get searchIndex =>
      '$caseNumber $year $caseType $parties $court ${status.arabicLabel}'
          .toLowerCase();
}

/// TypeAdapter مكتوب يدوياً (بدلاً من الاعتماد على build_runner)
/// typeId يجب أن يكون فريداً وثابتاً عبر كامل التطبيق
class LegalCaseAdapter extends TypeAdapter<LegalCase> {
  @override
  final int typeId = 0;

  @override
  LegalCase read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return LegalCase(
      caseNumber: fields[0] as String,
      year: fields[1] as String,
      caseType: fields[2] as String,
      parties: fields[3] as String,
      court: fields[4] as String,
      nextSessionDate: fields[5] as DateTime?,
      sessionHistory: (fields[6] as List).cast<String>(),
      appealDeadlines: (fields[7] as List).cast<String>(),
      status: CaseStatus.values[fields[8] as int],
      notes: fields[9] as String,
      attachmentPaths: (fields[10] as List).cast<String>(),
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LegalCase obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.caseNumber)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.caseType)
      ..writeByte(3)
      ..write(obj.parties)
      ..writeByte(4)
      ..write(obj.court)
      ..writeByte(5)
      ..write(obj.nextSessionDate)
      ..writeByte(6)
      ..write(obj.sessionHistory)
      ..writeByte(7)
      ..write(obj.appealDeadlines)
      ..writeByte(8)
      ..write(obj.status.index)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.attachmentPaths)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }
}
