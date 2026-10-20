import 'package:flutter/material.dart';
import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import '../widgets/skin_page_background.dart';

/// Pertanyaan lanjutan per kelas mengikuti SkinSight Rule Lab v1.3.
/// Jawaban khusus kelas memengaruhi poin timeline setelah dikonfirmasi.
class SkinCheckinQuizPage extends StatefulWidget {
  const SkinCheckinQuizPage({super.key});
  @override
  State<SkinCheckinQuizPage> createState() => _SkinCheckinQuizPageState();
}

class _FollowupQuestion {
  final String id;
  final String label;
  final Map<String, String> options;
  const _FollowupQuestion(this.id, this.label, this.options);
}

const _questions = <String, List<_FollowupQuestion>>{
  'Acne': [
    _FollowupQuestion(
        'new_lesions',
        'Ada jerawat baru sejak check-in sebelumnya?',
        {'ya': 'Ya', 'tidak': 'Tidak', 'tidak_yakin': 'Tidak yakin'}),
    _FollowupQuestion(
        'pain_scars',
        'Ada jerawat dalam/nyeri atau bekas parut yang mengkhawatirkan?',
        {'ya': 'Ya', 'tidak': 'Tidak', 'tidak_yakin': 'Tidak yakin'}),
  ],
  'PIH': [
    _FollowupQuestion(
        'new_spots',
        'Apakah kamu melihat noda baru sejak check-in sebelumnya?',
        {'ya': 'Ya', 'tidak': 'Tidak', 'tidak_yakin': 'Tidak yakin'}),
    _FollowupQuestion('uv',
        'Saat terpapar matahari minggu ini, pemakaian sunscreen bagaimana?', {
      'rutin': 'Rutin',
      'kadang': 'Kadang',
      'tidak': 'Tidak',
      'tidak_yakin': 'Tidak yakin'
    }),
  ],
  'Dark Circle': [
    _FollowupQuestion(
        'lighting', 'Apakah pencahayaan dan posisi foto pembanding serupa?', {
      'ya': 'Ya',
      'tidak': 'Tidak',
      'tidak_yakin': 'Tidak yakin',
      'tanpa_foto': 'Belum ada foto'
    }),
  ],
  'Redness': [
    _FollowupQuestion('burning', 'Ada rasa perih/panas pada area kemerahan?',
        {'ya': 'Ya', 'tidak': 'Tidak', 'tidak_yakin': 'Tidak yakin'}),
    _FollowupQuestion(
        'new_product_reaction',
        'Ada reaksi setelah memakai produk baru?',
        {'ya': 'Ya', 'tidak': 'Tidak', 'tidak_yakin': 'Tidak yakin'}),
  ],
  'Wrinkle': [
    _FollowupQuestion('expression',
        'Apakah foto diambil dengan ekspresi wajah netral yang serupa?', {
      'ya': 'Ya',
      'tidak': 'Tidak',
      'tidak_yakin': 'Tidak yakin',
      'tanpa_foto': 'Belum ada foto'
    }),
    _FollowupQuestion('uv',
        'Saat terpapar matahari minggu ini, pemakaian sunscreen bagaimana?', {
      'rutin': 'Rutin',
      'kadang': 'Kadang',
      'tidak': 'Tidak',
      'tidak_yakin': 'Tidak yakin'
    }),
  ],
};

class _SkinCheckinQuizPageState extends State<SkinCheckinQuizPage> {
  final store = SkinJourneyStore.instance;
  late final Map<String, String> reports = {...store.draftReports};
  late final Map<String, Map<String, String>> followups = {
    for (final e in store.draftFollowups.entries) e.key: Map.of(e.value)
  };
  late String care = store.draftCare;
  late String irritation = store.draftIrritation;
  late DateTime? careDate = store.draftCareDate;
  late final TextEditingController careNote =
      TextEditingController(text: store.draftCareNote);

  @override
  void dispose() {
    careNote.dispose();
    super.dispose();
  }

  void _save() {
    for (final condition in store.timeline.classesAt(store.currentWeek)) {
      if (reports[condition] == null) {
        _error('Isi perubahan $condition terlebih dahulu.');
        return;
      }
      for (final q in _questions[condition] ?? const <_FollowupQuestion>[]) {
        if (followups[condition]?[q.id] == null) {
          _error('Isi pertanyaan ${q.label}');
          return;
        }
      }
    }
    if (care.isEmpty || irritation.isEmpty) {
      _error('Isi status perawatan dan iritasi terlebih dahulu.');
      return;
    }
    store.saveDraftQuiz(reports, care, irritation,
        followups: followups,
        careDate: careDate,
        careNote: careNote.text.trim());
    if (irritation == 'Sedang-berat') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Iritasi sedang–berat perlu diperiksa tenaga kesehatan. Jangan menunggu check-in berikutnya.')));
    }
    Navigator.of(context).pop();
  }

  void _error(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Widget _choice(String value, String? chosen, void Function() onTap) =>
      ChoiceChip(
          label: Text(value),
          selected: chosen == value,
          onSelected: (_) => setState(onTap));

  @override
  Widget build(BuildContext context) {
    final classes = store.timeline.classesAt(store.currentWeek);
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
          child: SafeArea(
              child: Center(
                  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: Column(children: [
          const SkinPageHeader(
              title: 'Kuis Check-in', backKey: Key('checkin-quiz-back')),
          Expanded(
              child: ListView(padding: const EdgeInsets.all(20), children: [
            const Text('Perubahan sejak check-in lalu',
                style: SkinTokens.title),
            const SizedBox(height: 8),
            const Text('Ceritakan kondisi yang kamu rasakan minggu ini.',
                style: SkinTokens.caption),
            const SizedBox(height: 20),
            ...classes.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: SkinTokens.section),
                      const SizedBox(height: 9),
                      Wrap(spacing: 8, runSpacing: 7, children: [
                        for (final v in [
                          'Membaik',
                          'Sama',
                          'Memburuk',
                          'Tidak yakin'
                        ])
                          _choice(v, reports[name], () => reports[name] = v),
                      ]),
                      for (final q in _questions[name] ??
                          const <_FollowupQuestion>[]) ...[
                        const SizedBox(height: 17),
                        Text(q.label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 7, runSpacing: 7, children: [
                          for (final option in q.options.entries)
                            ChoiceChip(
                                label: Text(option.value),
                                selected: followups[name]?[q.id] == option.key,
                                onSelected: (_) => setState(() => followups
                                        .putIfAbsent(name, () => {})[q.id] =
                                    option.key)),
                        ]),
                      ],
                    ]))),
            const Divider(height: 30),
            const Text('Apakah masih mengikuti perawatan sebelumnya?',
                style: SkinTokens.section),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final v in ['Ya', 'Tidak', 'Berubah', 'Belum ada perawatan'])
                _choice(v, care, () => care = v),
            ]),
            if (care == 'Berubah') ...[
              const SizedBox(height: 11),
              OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: store.today,
                        initialDate: careDate ?? store.today);
                    if (picked != null) setState(() => careDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(careDate == null
                      ? 'Tanggal perubahan (opsional)'
                      : '${careDate!.day}/${careDate!.month}/${careDate!.year}')),
              TextField(
                  controller: careNote,
                  decoration: const InputDecoration(
                      labelText: 'Catatan perawatan (opsional)')),
            ],
            const SizedBox(height: 23),
            const Text('Ada keluhan baru atau iritasi?',
                style: SkinTokens.section),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final v in [
                'Tidak',
                'Ringan',
                'Sedang-berat',
                'Tidak yakin'
              ])
                _choice(v, irritation, () => irritation = v),
            ]),
          ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _save,
                      child: const Text('Simpan jawaban kuis')))),
        ]),
      )))),
    );
  }
}
