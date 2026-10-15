import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/skin_journey_store.dart';
import '../data/skin_timeline_engine.dart';
import '../models/skin_analysis.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import 'skin_checkin_page.dart';
import 'skin_quiz_page.dart';
import 'skin_result_page.dart';

/// Satu halaman Skin Journey: jumlah temuan per waktu + timeline check-in.
/// Tidak mengubah jumlah deteksi menjadi tingkat kesembuhan.
class SkinProgressPage extends StatefulWidget {
  const SkinProgressPage({super.key});
  @override
  State<SkinProgressPage> createState() => _SkinProgressPageState();
}

class _SkinProgressPageState extends State<SkinProgressPage> {
  String _selected = 'Acne';
  static const _navy = Color(0xFF16363C);
  static const _teal = Color(0xFF087D73);
  static const _cream = Color(0xFFFFFBF4);
  static const _mint = Color(0xFFE4F5ED);

  String _date(DateTime d) => '${d.day} ${const [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ][d.month - 1]}';
  String _value(String name, double v) =>
    SkinJourneyStore.detectionClasses.contains(name)
      ? '${v.toInt()}' : '${(v * 100).toStringAsFixed(0)}%';
  String _unit(String name) => SkinJourneyStore.detectionClasses.contains(name)
    ? 'area terdeteksi' : 'luas mask wajah';

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return Scaffold(backgroundColor: _cream,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AnimatedBuilder(animation: store, builder: (context, _) {
          final engine = store.timeline;
          final classes = engine.tracks.isEmpty
            ? SkinJourneyStore.visualClasses : engine.tracks.keys.toList();
          final selected = classes.contains(_selected) ? _selected : classes.first;
          final values = store.metricHistory(selected);
          final isDetection = SkinJourneyStore.detectionClasses.contains(selected);
          // Satu event per TANGGAL, bukan per foto atau per laporan.
          // Data beberapa sesi tetap disimpan dan dapat dibuka masing-masing.
          final events = _dailyEvents(store, engine);
          return ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 32), children: [
            const SkinPageHeader(title: 'Skin Journey', backKey: Key('journey-back')),
            const SizedBox(height: 8),
            if (!store.hasBaseline) _emptyJourney(context) else ...[
              Container(padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFFB8EBDD), Color(0xFFE3F5EA),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(26)),
                child: Stack(children: [
                  Positioned(right: -4, top: -8, child: Icon(
                    Icons.spa_rounded, color: Colors.white.withValues(alpha: .7),
                    size: 84)),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('PERJALANAN KULITMU', style: TextStyle(
                        color: _teal, fontSize: 10, fontWeight: FontWeight.w900,
                        letterSpacing: 1.3)),
                      const Spacer(),
                      const Icon(Icons.spa_outlined, color: _teal, size: 18),
                    ]),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onLongPress: kDebugMode ? () async {
                        final selectedDate = await showDatePicker(
                          context:context,
                          firstDate:store.baselineDate!,
                          lastDate:DateTime(2035),
                          initialDate:store.today.isBefore(store.baselineDate!)
                            ? store.baselineDate! : store.today);
                        if (selectedDate != null) store.setTestingDate(selectedDate);
                      } : null,
                      child:Text('Minggu ke-${store.currentWeek}',
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900,
                        letterSpacing: -.7, color: _navy))),
                    const SizedBox(height: 5),
                    Text('Dimulai ${_date(store.baselineDate!)}',
                      style: const TextStyle(color: SkinTokens.muted, fontSize: 13)),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              const Text('Grafik temuan kulit', style: TextStyle(fontSize: 23,
                fontWeight: FontWeight.w900, color: _navy)),
              const SizedBox(height: 5),
              const Text('Pilih kondisi untuk melihat perbandingan tiap tanggal.',
                style: SkinTokens.caption),
              const SizedBox(height: 13),
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(children: classes.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c), selected: selected == c,
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFCEF0E5),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700,
                      color: selected == c ? _teal : SkinTokens.muted),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: selected == c
                        ? const Color(0xFF9ED5C6) : const Color(0xFFE0EAE5))),
                    onSelected: (_) => setState(() => _selected = c)),
                )).toList())),
              const SizedBox(height: 12),
              _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selected, style: const TextStyle(fontSize: 19,
                        fontWeight: FontWeight.w900, color: _navy)),
                      const SizedBox(height: 3),
                      Text(isDetection ? 'Jumlah temuan terdeteksi' : 'Luas mask wajah',
                        style: SkinTokens.caption),
                    ])),
                  if (values.isNotEmpty) Column(crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_value(selected, values.last.value),
                        style: const TextStyle(fontSize: 29,
                          color: _teal, fontWeight: FontWeight.w900)),
                      Text(_unit(selected), style: const TextStyle(
                        color: SkinTokens.muted, fontSize: 11)),
                    ]),
                ]),
                const SizedBox(height: 14),
                if (values.isEmpty) const SizedBox(height: 165,
                  child: Center(child: Text('Belum ada titik pengamatan untuk kelas ini.',
                    textAlign: TextAlign.center, style: SkinTokens.caption)))
                else ...[
                  SizedBox(height: 178, width: double.infinity,
                    child: CustomPaint(painter: _JourneyPlot(values,
                      _teal, isDetection))),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: values.map((v) => Text(_date(v.date),
                      style: const TextStyle(fontSize: 10,
                        color: SkinTokens.muted))).toList()),
                  const SizedBox(height: 17),
                  Container(padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F8F4),
                      borderRadius: BorderRadius.circular(13)),
                    child: Row(children: [
                      const Icon(Icons.compare_arrows_rounded, color: _teal, size: 21),
                      const SizedBox(width: 9),
                      Expanded(child: Text(values.length == 1
                        ? 'Pengamatan awal: ${_value(selected, values.first.value)} ${_unit(selected)}'
                        : 'Dari ${_value(selected, values.first.value)} ke ${_value(selected, values.last.value)} ${_unit(selected)}',
                        style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: _navy))),
                    ])),
                ],
                const SizedBox(height: 13),
                Text(isDetection
                  ? 'Angka menunjukkan jumlah box terdeteksi pada foto dengan pose dan versi model yang sebanding; bukan tingkat keparahan.'
                  : 'Angka menunjukkan proporsi luas mask dari area wajah yang valid; bukan skor kesembuhan.',
                  style: const TextStyle(color: SkinTokens.muted,
                    fontSize: 11, height: 1.4)),
              ])),
              const SizedBox(height: 26),
              Row(children: [
                const Expanded(child: Text('Timeline', style: TextStyle(
                  fontSize: 23, fontWeight: FontWeight.w900, color: _navy))),
                const Icon(Icons.calendar_month_rounded, color: _teal),
              ]),
              const SizedBox(height: 6),
              const Text('Riwayat → hari ini → jadwal mendatang, dalam satu garis waktu.',
                style: SkinTokens.caption),
              const SizedBox(height: 12),
              if (events.isEmpty) const Text('Belum ada peristiwa atau jadwal.',
                style: SkinTokens.caption),
              ...List.generate(events.length, (i) =>
                _timelineRow(context, events[i], i == events.length - 1)),
            ],
          ]);
        }),
      ))),
    );
  }

  /// Satu baris timeline untuk satu tanggal kalender, bahkan jika pada hari
  /// itu terdapat scan awal, beberapa foto tambahan, check-in dan jadwal.
  List<_Event> _dailyEvents(SkinJourneyStore store, SkinTimelineEngine engine) {
    final byDate = <DateTime, _DayBucket>{};
    _DayBucket getDay(DateTime value) {
      final d = SkinJourneyStore.day(value);
      return byDate.putIfAbsent(d, () => _DayBucket(d));
    }
    for (final planned in _plannedEvents(store, engine)) {
      getDay(planned.date).planned = planned;
    }
    for (final p in store.photos) {
      getDay(p.date).photos.add(p);
    }
    for (final c in store.checkins) {
      getDay(c.date).checkins.add(c);
    }
    final days = byDate.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return [for (final day in days) day.toEvent()];
  }

  /// Buka layar HASIL lengkap dari masing-masing foto yang sudah tersimpan.
  /// archived memastikan tidak muncul tombol Simpan ulang di hasil tersebut.
  void _openSavedSession(BuildContext context, JourneyPhoto photo) {
    final result = SkinAnalysis(
      id: photo.id, analyzedAt: photo.date, selfieBytes: photo.bytes,
      score: 0, oil: 0, pores: 0, acne: 0, redness: 0,
      title: 'Hasil sesi foto', skinType: photo.skinType ?? 'Belum diketahui',
      skinTypeConfidence: photo.skinTypeConfidence,
      visualFindings: photo.visualFindings,
      modelConnected: photo.modelConnected, isDemo: photo.isDemo,
      detectionCounts: photo.detectionCounts,
      segmentationAreas: photo.segmentationAreas,
      classConfidences: photo.confidences,
      modelVersion: photo.modelVersion,
    );
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SkinResultPage(analysis: result, archived: true)));
  }

  /// Beberapa foto = beberapa sesi DALAM satu event tanggal, bukan beberapa
  /// titik timeline. Nilai setiap foto tidak dirata-ratakan.
  Widget _photoSessions(BuildContext context, List<JourneyPhoto> photos) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${photos.length} sesi foto tersimpan',
          style: const TextStyle(color: _navy,
            fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final p = photos[index];
              return InkWell(
                key: Key('journey-session-${p.id}'),
                onTap: () => _openSavedSession(context, p),
                borderRadius: BorderRadius.circular(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: p.bytes.isNotEmpty
                        ? Image.memory(p.bytes, width: 72, height: 76,
                            fit: BoxFit.cover)
                        : Container(width: 72, height: 76,
                            color: _mint,
                            child: const Icon(Icons.image_outlined,
                              color: _teal))),
                    const SizedBox(height: 5),
                    Text('Sesi ${index + 1}',
                      style: const TextStyle(fontSize: 11,
                        color: _teal, fontWeight: FontWeight.w700)),
                  ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _emptyJourney(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: _mint,
      borderRadius: BorderRadius.circular(24)),
    child: Column(children: [
      const Icon(Icons.spa_rounded, size: 49, color: _teal),
      const SizedBox(height: 12),
      const Text('Mulai perjalanan kulitmu', style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w900, color: _navy)),
      const SizedBox(height: 8),
      const Text('Simpan hasil scan pertama untuk membuka grafik, catatan kondisi, dan check-in mingguan.',
        textAlign: TextAlign.center, style: SkinTokens.caption),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const SkinQuizPage())),
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Mulai scan pertama'))),
    ]),
  );

  /// Satu urutan: riwayat, periode yang terlewat, check-in tersedia,
  /// dan jadwal masa depan yang dihitung dari baseline. Tidak memprediksi hasil.
  List<_Event> _plannedEvents(SkinJourneyStore store, SkinTimelineEngine engine) {
    if (!store.hasBaseline) return const [];
    final items=<_Event>[];
    final today=SkinJourneyStore.day(store.today);
    for (int w=0;w<=engine.maxHorizon;w++) {
      final active=engine.classesAt(w);
      if (active.isEmpty) continue;
      final due=engine.onWeek(w);
      final checkin=store.checkins.where((c)=>
        SkinJourneyStore.sameDay(c.dueDate,due)).toList();
      final complete=checkin.isNotEmpty;
      final isDue=w>0 && !complete && w==engine.currentWeek && store.hasCheckinDue;
      final isMissed=w>0 && !complete && w<engine.currentWeek;
      final isPlanned=w>engine.currentWeek;
      final lines=<String>[];
      final classContent=<TimelineClassContent>[];
      for (final name in active) {
        final content=engine.content(name,w);
        classContent.add(content);
        final parts=<String>[content.message];
        if (content.focus.isNotEmpty) parts.add(content.focus);
        parts.addAll(content.notes);
        lines.add('$name\n${parts.join(' ')}');
      }
      if (isMissed) lines.add('Belum ada laporan pada minggu ini. Perubahan tidak diasumsikan sama.');
      final review=active.where((name)=>w==engine.tracks[name]!.horizon &&
        !isPlanned && engine.canClose(name)).toList();
      items.add(_Event(due,
        w==0?'Awal Skin Journey':'Check-in minggu $w',
        lines.join('\n\n'),
        w==0?Icons.flag_outlined:
          complete?Icons.check_circle_outline:
          isDue?Icons.edit_calendar_outlined:Icons.event_outlined,
        false,null, dueDate:isDue?due:null,
        isPlanned:isPlanned,isMissed:isMissed,
        reviewNames:review, classItems:classContent,
        order:2));
    }
    return items;
  }

  // Semua event masuk dalam SATU timeline kronologis, termasuk masa depan.
  // Tombol Mulai hanya muncul pada baris due, sesuai wireframe pengguna.
  Widget _timelineRow(BuildContext context, _Event e, bool last) {
    final isCurrentDue = e.dueDate != null;
    final isFuture = e.isPlanned || e.isResearch;
    final foreground = isFuture ? SkinTokens.muted : _navy;
    return IntrinsicHeight(child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 39, child: Column(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(
              color: isCurrentDue ? const Color(0xFFCEF0E5) :
                isFuture ? const Color(0xFFF1F5F2) : _mint,
              shape: BoxShape.circle),
            child: Icon(e.icon,
              color: isCurrentDue ? _teal :
                isFuture ? SkinTokens.muted : _teal, size: 18)),
          if (!last) Expanded(child: Container(width: 2,
            margin: const EdgeInsets.symmetric(vertical: 3),
            color: const Color(0xFFD2E8E0))),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 1, 0, 23),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_date(e.date), style: const TextStyle(
                color: _teal, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              if (e.isMissed) _tinyLabel('TERLEWAT')
              else if (isCurrentDue) _tinyLabel(
                SkinJourneyStore.sameDay(e.date, SkinJourneyStore.day(SkinJourneyStore.instance.today))
                  ? 'HARI INI' : 'BELUM DIISI')
              else if (e.isResearch) _tinyLabel('ACUAN RISET')
              else if (e.isPlanned) _tinyLabel('JADWAL'),
            ]),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.title, style: TextStyle(color: foreground,
                    fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  if (e.classItems.isEmpty && e.description.isNotEmpty)
                    Text(e.description, style: SkinTokens.caption)
                  else ...[
                    for (final item in e.classItems) ...[
                      const SizedBox(height: 7),
                      Text(item.name, style: const TextStyle(
                        fontWeight: FontWeight.w800,color:_navy,fontSize:13)),
                      const SizedBox(height:3),
                      Text(item.message, style: SkinTokens.caption),
                      if (item.focus.isNotEmpty) ...[
                        const SizedBox(height:3),
                        Text(item.focus, style: SkinTokens.caption),
                      ],
                      for (final note in item.notes) ...[
                        const SizedBox(height:4),
                        Text(note, style: SkinTokens.caption),
                      ],
                      if (item.source!='Dokumentasi SkinSight')
                        Padding(padding:const EdgeInsets.only(top:4),
                          child:Text('Referensi: ${item.source}',
                            style:const TextStyle(fontSize:10,color:SkinTokens.muted))),
                      const SizedBox(height:8),
                    ],
                    if(e.isMissed) const Text('Tidak ada laporan check-in pada minggu ini.',
                      style:SkinTokens.caption),
                  ],
                ])),
              if (isCurrentDue) ...[
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('start-timeline-checkin'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SkinCheckinPage())),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(66, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child: const Text('Mulai'),
                ),
              ],
            ]),
            // Check-in yang dilakukan pada hari yang sama tidak menciptakan
            // titik tanggal baru: rangkuman disisipkan ke event harian ini.
            for (final report in e.reports) ...[
              const SizedBox(height: 10),
              const Text('Laporan check-in',
                style: TextStyle(color: _navy, fontSize: 12,
                  fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(report.perClass.entries.map((item) =>
                '${item.key}: ${item.value}').join(' · '),
                style: SkinTokens.caption),
              const SizedBox(height: 3),
              Text('Perawatan: ${report.treatment} · Iritasi: ${report.irritation}',
                style: SkinTokens.caption),
            ],
            _photoSessions(context, e.photos),
            if (e.reviewNames.isNotEmpty) ...[
              const SizedBox(height:8),
              for (final name in e.reviewNames) TextButton.icon(
                onPressed: () {
                  if (SkinJourneyStore.instance.closeCondition(name)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:Text('Pemantauan $name diakhiri. Riwayat tetap tersimpan.')));
                  }
                },
                icon:const Icon(Icons.done_all,size:16),
                label:Text('Akhiri pemantauan $name')),
            ],
          ]),
        )),
      ],
    ));
  }

  Widget _tinyLabel(String title) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFFEAF5F0),
      borderRadius: BorderRadius.circular(9)),
    child: Text(title, style: const TextStyle(color: _teal,
      fontSize: 9, fontWeight: FontWeight.w800)),
  );

  Widget _panel({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2ECE6))),
    child: child,
  );


}

class _Event {
  final DateTime date;
  final String title;
  final String description;
  final IconData icon;
  final bool isDemo;
  final Uint8List? thumbnail;
  final DateTime? dueDate;
  final bool isPlanned;
  final bool isResearch;
  final bool isMissed;
  final int order;
  final List<String> reviewNames;
  final List<TimelineClassContent> classItems;
  final List<JourneyPhoto> photos;
  final List<JourneyCheckin> reports;
  const _Event(this.date, this.title, this.description, this.icon,
    this.isDemo, this.thumbnail, {this.dueDate,
    this.isPlanned = false, this.isResearch = false,
    this.isMissed = false, this.order = 0, this.reviewNames = const [],
    this.classItems = const [], this.photos = const [], this.reports = const []});
}

/// Penggabungan ini hanya mengubah PRESENTASI timeline; semua foto asli dan
/// laporan check-in tetap entitas terpisah di SkinJourneyStore.
class _DayBucket {
  final DateTime date;
  _Event? planned;
  final List<JourneyPhoto> photos = [];
  final List<JourneyCheckin> checkins = [];
  _DayBucket(this.date);

  _Event toEvent() {
    photos.sort((a,b) => a.date.compareTo(b.date));
    checkins.sort((a,b) => a.date.compareTo(b.date));
    final plan = planned;
    return _Event(date,
      plan?.title ?? (checkins.isNotEmpty ? 'Check-in kulit' : 'Sesi foto'),
      plan?.description ?? '',
      plan?.icon ?? (checkins.isNotEmpty
        ? Icons.task_alt_rounded : Icons.camera_alt_outlined),
      false, null,
      dueDate: plan?.dueDate,
      isPlanned: plan?.isPlanned ?? false,
      isResearch: plan?.isResearch ?? false,
      isMissed: plan?.isMissed ?? false,
      reviewNames: plan?.reviewNames ?? const [],
      classItems: plan?.classItems ?? const [],
      photos: List.unmodifiable(photos),
      reports: List.unmodifiable(checkins),
    );
  }
}

/// Grafik jumlah temuan berdasarkan observasi sebanding, bukan skor kesehatan.
class _JourneyPlot extends CustomPainter {
  final List<JourneyMetric> points;
  final Color color;
  final bool detection;
  const _JourneyPlot(this.points, this.color, this.detection);

  @override
  void paint(Canvas canvas, Size size) {
    const top = 12.0;
    final bottom = size.height - 18;
    final left = 35.0;
    final right = size.width - 8;
    final ceiling = points.isEmpty ? 1.0 : math.max(detection ? 1.0 : .05,
      points.map((p) => p.value).reduce(math.max) * 1.2);
    final textStyle = TextStyle(color: const Color(0xFF819A94), fontSize: 10);
    for (int i = 0; i <= 3; i++) {
      final y = top + (bottom - top) * i / 3;
      canvas.drawLine(Offset(left, y), Offset(right, y),
        Paint()..color = const Color(0xFFE7EFEA)..strokeWidth = 1);
      final val = ceiling * (3 - i) / 3;
      final painter = TextPainter(
        text: TextSpan(text: detection ? val.round().toString() :
          '${(val * 100).toStringAsFixed(0)}%', style: textStyle),
        textDirection: TextDirection.ltr)..layout();
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }
    if (points.isEmpty) return;
    Offset point(int i) {
      final x = points.length == 1 ? (left + right) / 2
        : left + (right - left) * i / (points.length - 1);
      final y = bottom - points[i].value / ceiling * (bottom - top);
      return Offset(x, y);
    }
    final line = Path()..moveTo(point(0).dx, point(0).dy);
    for (int i = 1; i < points.length; i++) {
      line.lineTo(point(i).dx, point(i).dy);
    }
    if (points.length > 1) {
      final fill = Path.from(line)
        ..lineTo(point(points.length - 1).dx, bottom)
        ..lineTo(point(0).dx, bottom)..close();
      canvas.drawPath(fill, Paint()
        ..color = color.withValues(alpha: .10));
      canvas.drawPath(line, Paint()..color = color
        ..strokeWidth = 3.3..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke);
    }
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(point(i), 5.3, Paint()..color = Colors.white);
      canvas.drawCircle(point(i), 4.0, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPlot old) =>
    old.points != points || old.color != color || old.detection != detection;
}
