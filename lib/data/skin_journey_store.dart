import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'skin_demo_data.dart';
import 'skin_timeline_engine.dart';

/// Satu journey per pengguna. Prototype menyimpan state di RAM; belum backend.
/// Data historis contoh hanya ditambahkan dalam mode demo, terpisah dari ML asli.
class SkinJourneyStore extends ChangeNotifier {
  SkinJourneyStore._();
  static final SkinJourneyStore instance = SkinJourneyStore._();

  static const visualClasses = <String>[
    'Acne', 'PIH', 'Dark Circle', 'Redness', 'Wrinkle',
  ];
  static const detectionClasses = <String>['Acne', 'PIH', 'Dark Circle'];
  static const segmentationClasses = <String>['Redness', 'Wrinkle'];
  static const skinTypes = <String>['Oily', 'Dry', 'Normal', 'Combination'];

  final Map<String, String> answers = {};
  final List<JourneyPhoto> photos = [];
  final List<JourneyPhoto> pendingPhotos = [];
  final List<JourneyCheckin> checkins = [];
  final Map<String, DateTime> closedConditions = {};
  DateTime? _testingDate;
  int _photoSequence = 0;
  DateTime get today => _testingDate ?? DateTime.now();
  // Pengujian logika dapat memakai tanggal virtual tanpa mengganti jam perangkat.
  void setTestingDate(DateTime? date) { _testingDate = date; notifyListeners(); }
  SkinTimelineEngine get timeline => SkinTimelineEngine(this);
  final Map<String, List<JourneyMetric>> _demoHistory = {}; // Tidak membuat sejarah otomatis.
  bool get hasDemoHistory => _demoHistory.isNotEmpty;
  // Sumber snapshot DEMO yang sama dengan grafik: hanya data contoh, bukan
  // sesi foto pasien nyata. Ditampilkan sebagai peristiwa demo di timeline.
  List<JourneyDemoSnapshot> get demoSnapshots {
    final byDay = <DateTime, Map<String, double>>{};
    for (final entry in _demoHistory.entries) {
      for (final metric in entry.value) {
        final date = day(metric.date);
        byDay.putIfAbsent(date, () => <String, double>{})[entry.key] = metric.value;
      }
    }
    return [for (final entry in byDay.entries)
      JourneyDemoSnapshot(entry.key, Map.unmodifiable(entry.value))]
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  DateTime? baselineDate;
  bool? consent;
  bool _checkinQuizDone = false;
  final Map<String, String> _draftReports = {};
  String _draftCare = '';
  String _draftIrritation = '';
  final Map<String, Map<String, String>> _draftFollowups = {};
  DateTime? _draftCareDate;
  String _draftCareNote = '';
  Map<String, Map<String, String>> get draftFollowups => {for (final e in _draftFollowups.entries) e.key: Map.unmodifiable(e.value)};
  DateTime? get draftCareDate => _draftCareDate;
  String get draftCareNote => _draftCareNote;

  bool get questionnaireDone => List.generate(7, (i) => 'M0${i + 1}')
      .every(answers.containsKey);
  bool get hasBaseline => baselineDate != null;
  bool get baselineFinalized => hasBaseline; // manual save = baseline final
  bool get checkinQuizDone => _checkinQuizDone;
  Map<String, String> get draftReports => Map.unmodifiable(_draftReports);
  String get draftCare => _draftCare;
  String get draftIrritation => _draftIrritation;

  static DateTime day([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get currentWeek {
    if (baselineDate == null) return 0;
    final days = day(today).difference(day(baselineDate)).inDays;
    return days < 0 ? 0 : days ~/ 7;
  }

  bool get hasCheckinDue {
    if (!hasBaseline || currentWeek < 1) return false;
    final engine = timeline;
    if (!engine.hasActiveTracks) return false;
    final due = day(baselineDate).add(Duration(days: currentWeek * 7));
    return !checkins.any((c) => sameDay(c.dueDate, due));
  }

  DateTime? get activeDueDate {
    if (!hasCheckinDue) return null;
    return day(baselineDate).add(Duration(days: currentWeek * 7));
  }

  DateTime? get nextCheckin {
    if (!hasBaseline) return null;
    final days = day(today).difference(day(baselineDate)).inDays;
    final nextWeek = days < 0 ? 1 : days ~/ 7 + 1;
    return day(baselineDate).add(Duration(days: nextWeek * 7));
  }

  List<String> get userConcerns {
    final selected = (answers['M07'] ?? '').split('|');
    return visualClasses.where(selected.contains).toList();
  }

  List<String> get trackedConditions {
    final observed = photos.expand((p) => p.visualFindings).toSet();
    final existing = <String>{...observed}; // M07 hanya memprioritaskan urutan, bukan menambah diagnosis.
    for (final checkin in checkins) { existing.addAll(checkin.perClass.keys); }
    return visualClasses.where(existing.contains).toList();
  }

  void saveQuestionnaire(Map<String, String> response, {bool photoConsent = false}) {
    answers..clear()..addAll(response);
    consent = photoConsent;
    notifyListeners();
  }

  JourneyPhoto _makePhoto(Uint8List bytes, {
    List<String> visualFindings = const [], String? skinType,
    bool isDemo = false,
    double? skinTypeConfidence, bool modelConnected = false,
    Map<String, int> detectionCounts = const {},
    Map<String, double> segmentationAreas = const {},
    Map<String, double> confidences = const {},
    String pose = 'depan', String? modelVersion, String quality = 'unchecked',
  }) {
    final sequence=++_photoSequence;
    final now = _testingDate == null ? DateTime.now() :
      day(_testingDate).add(Duration(hours:12,seconds:sequence));
    return JourneyPhoto(
      id: 'photo-${DateTime.now().microsecondsSinceEpoch}-$sequence', date: now, bytes: bytes,
      visualFindings: List.unmodifiable(visualFindings),
      skinType: skinType, skinTypeConfidence: skinTypeConfidence,
      modelConnected: modelConnected, isDemo: isDemo,
      detectionCounts: Map.unmodifiable(detectionCounts),
      segmentationAreas: Map.unmodifiable(segmentationAreas),
      confidences: Map.unmodifiable(confidences), pose: pose,
      modelVersion: modelVersion, quality: quality,
    );
  }

  /// Hanya dipanggil sesudah pengguna memilih Simpan Hasil (baseline/scan bebas).
  void addPhoto(Uint8List bytes, {
    List<String> visualFindings = const [], String? skinType,
    bool isDemo = false,
    double? skinTypeConfidence, bool modelConnected = false,
    Map<String, int> detectionCounts = const {},
    Map<String, double> segmentationAreas = const {},
    Map<String, double> confidences = const {},
    String pose = 'depan', String? modelVersion, String quality = 'unchecked',
  }) {
    final photo = _makePhoto(bytes, visualFindings: visualFindings,
      skinType: skinType, skinTypeConfidence: skinTypeConfidence,
      modelConnected: modelConnected, isDemo: isDemo, detectionCounts: detectionCounts,
      segmentationAreas: segmentationAreas, confidences: confidences,
      pose: pose, modelVersion: modelVersion, quality: quality);
    photos.insert(0, photo);
    // Scan baru tidak membuat riwayat fiktif maupun memundurkan baseline.
    baselineDate ??= day(photo.date);
    notifyListeners();
  }

  /// Halaman kiri menyimpan sesi ke draft, bukan otomatis mengonfirmasi check-in.
  void stagePhoto(Uint8List bytes, {String pose = 'depan'}) {
    final analysis = SkinDemoData.forPhoto(bytes,
      sessionIndex: photos.length + pendingPhotos.length);
    pendingPhotos.add(_makePhoto(bytes, pose: pose,
      visualFindings: analysis.visualFindings,
      skinType: analysis.skinType,
      skinTypeConfidence: analysis.skinTypeConfidence,
      isDemo: true,
      detectionCounts: analysis.detectionCounts,
      segmentationAreas: analysis.segmentationAreas,
      confidences: analysis.classConfidences,
      modelVersion: analysis.modelVersion, quality: 'pass'));
    notifyListeners();
  }

  void clearPendingPhoto(String id) {
    pendingPhotos.removeWhere((photo) => photo.id == id);
    notifyListeners();
  }

  void saveDraftQuiz(Map<String, String> perClass, String care, String irritation,
      {Map<String, Map<String, String>> followups = const {},
       DateTime? careDate, String careNote = ''}) {
    _draftReports..clear()..addAll(perClass);
    _draftCare = care;
    _draftIrritation = irritation;
    _draftFollowups..clear()..addAll({for (final e in followups.entries) e.key: Map.of(e.value)});
    _draftCareDate=careDate;
    _draftCareNote=careNote;
    _checkinQuizDone = true;
    notifyListeners();
  }

  /// Konfirmasi MANUAL pada hari yang sama; satu check-in per jadwal.
  bool confirmCheckin() {
    if (!hasCheckinDue || !_checkinQuizDone) return false;
    final due = activeDueDate!;
    checkins.add(JourneyCheckin(
      date: today, dueDate: due,
      perClass: Map.unmodifiable(_draftReports),
      treatment: _draftCare, irritation: _draftIrritation,
      photoIds: List.unmodifiable(pendingPhotos.map((p) => p.id)),
      followup: {for (final e in _draftFollowups.entries) e.key: Map.unmodifiable(e.value)},
      careDate: _draftCareDate, careNote: _draftCareNote,
    ));
    photos.insertAll(0, pendingPhotos.reversed);
    pendingPhotos.clear();
    _draftReports.clear();
    _draftCare = '';
    _draftIrritation = '';
    _draftFollowups.clear();
    _draftCareDate = null;
    _draftCareNote = '';
    _checkinQuizDone = false;
    notifyListeners();
    return true;
  }

  bool closeCondition(String name) {
    if (!timeline.canClose(name)) return false;
    closedConditions[name] = today;
    notifyListeners();
    return true;
  }
  void reopenCondition(String name) {
    closedConditions.remove(name);
    notifyListeners();
  }

  bool isFinalized(DateTime date) => checkins.any((c) => sameDay(c.date, date)) ||
      (baselineDate != null && sameDay(baselineDate!, date));

  /// Metrik grafik hanya dari observasi ML yang tersedia dan pose depan yang sebanding.
  /// Tidak menggabungkan beberapa foto pada hari sama. Pilih satu foto terbaru per hari.
  List<JourneyMetric> metricHistory(String condition) {
    final newestFirst = [...photos]..sort((a, b) => b.date.compareTo(a.date));
    final visited = <String>{};
    String? referenceModelVersion;
    final collected = <JourneyMetric>[];
    for (final photo in newestFirst) {
      if (!(photo.modelConnected || photo.isDemo) || photo.pose != 'depan' ||
          photo.quality != 'pass') continue;
      if (photo.modelVersion == null || photo.modelVersion!.isEmpty) continue;
      referenceModelVersion ??= photo.modelVersion;
      if (photo.modelVersion != referenceModelVersion) continue;
      final key = '${photo.date.year}-${photo.date.month}-${photo.date.day}';
      if (visited.contains(key)) continue;
      final number = detectionClasses.contains(condition)
          ? photo.detectionCounts[condition]?.toDouble()
          : photo.segmentationAreas[condition];
      if (number == null) continue;
      visited.add(key);
      collected.add(JourneyMetric(photo.date, number, photo.id));
    }
    final actual = collected.reversed.toList();
    final demos = _demoHistory[condition] ?? const <JourneyMetric>[];
    return [...demos, ...actual]..sort((a, b) => a.date.compareTo(b.date));
  }
}

class JourneyMetric {
  final DateTime date;
  final double value;
  final String photoId;
  const JourneyMetric(this.date, this.value, this.photoId);
}

class JourneyPhoto {
  final String id;
  final DateTime date;
  final Uint8List bytes;
  final List<String> visualFindings;
  final String? skinType;
  final double? skinTypeConfidence;
  final bool modelConnected;
  final bool isDemo;
  final Map<String, int> detectionCounts;
  /// Rasio area segmentasi dari area wajah valid (0..1), bukan skor severity.
  final Map<String, double> segmentationAreas;
  final Map<String, double> confidences;
  final String pose;
  final String? modelVersion;
  final String quality;
  const JourneyPhoto({required this.id, required this.date, required this.bytes,
    required this.visualFindings, required this.skinType,
    required this.skinTypeConfidence, required this.modelConnected,
    required this.isDemo,
    required this.detectionCounts, required this.segmentationAreas,
    required this.confidences, required this.pose, required this.modelVersion,
    required this.quality});
}

class JourneyCheckin {
  final DateTime date;
  final DateTime dueDate;
  final Map<String, String> perClass;
  final String treatment;
  final String irritation;
  final List<String> photoIds;
  final Map<String, Map<String, String>> followup;
  final DateTime? careDate;
  final String careNote;
  final bool isDemo;
  const JourneyCheckin({required this.date, required this.dueDate,
    required this.perClass, required this.treatment,
    required this.irritation, required this.photoIds, this.isDemo = false,
    this.followup = const {}, this.careDate, this.careNote = ''});
}

/// Snapshot angka fixture (tanpa foto), agar grafik demo dan timeline sejalan.
class JourneyDemoSnapshot {
  final DateTime date;
  final Map<String, double> values;
  const JourneyDemoSnapshot(this.date, this.values);
}
