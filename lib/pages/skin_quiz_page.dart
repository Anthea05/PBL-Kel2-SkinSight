import 'package:flutter/material.dart';
import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import '../widgets/skin_page_background.dart';
import 'skin_initial_scan_page.dart';
import 'skin_progress_page.dart';

/// Kuesioner pra-scan M01–M07. Semua pertanyaan berada dalam satu halaman.
class SkinQuizPage extends StatefulWidget {
  final bool enableCamera;
  const SkinQuizPage({super.key, this.enableCamera = true});

  @override
  State<SkinQuizPage> createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
  static const questions = <(String, String, List<String>)>[
    (
      'M01',
      'Sedang menggunakan bahan aktif atau obat perawatan wajah?',
      ['Ya', 'Tidak', 'Tidak tahu']
    ),
    (
      'M02',
      'Seberapa rutin kamu memakai perawatan dalam 7 hari terakhir?',
      ['Rutin', 'Kadang', 'Tidak', 'Tidak memakai', 'Tidak tahu']
    ),
    (
      'M03',
      'Apakah wajah sedang perih, gatal, panas, ruam, atau mengelupas?',
      ['Tidak', 'Ringan', 'Sedang-berat', 'Tidak yakin']
    ),
    (
      'M04',
      'Pernah ada produk atau bahan yang menimbulkan reaksi buruk?',
      ['Tidak', 'Ya', 'Tidak tahu']
    ),
    (
      'M05',
      'Seberapa sering memakai sunscreen saat terpapar matahari?',
      ['Rutin', 'Kadang', 'Tidak', 'Tidak tahu']
    ),
    (
      'M06',
      'Sedang dalam perawatan dokter untuk masalah kulit ini?',
      ['Ya', 'Tidak', 'Tidak yakin']
    ),
    (
      'M07',
      'Masalah mana yang ingin kamu perhatikan? (Boleh lebih dari satu)',
      ['Acne', 'PIH', 'Dark Circle', 'Redness', 'Wrinkle', 'Belum yakin']
    ),
  ];

  final Map<String, String> _answers = {...SkinJourneyStore.instance.answers};
  final TextEditingController _regimenName = TextEditingController();
  final Set<String> _concerns = {};
  final List<GlobalKey> _questionKeys = List.generate(7, (_) => GlobalKey());
  String? _regimenClass;
  DateTime? _regimenStart;
  bool _consent = false;

  @override
  void initState() {
    super.initState();
    _regimenName.text = _answers['regimen_name'] ?? '';
    _regimenClass = _answers['regimen_class'];
    _regimenStart = DateTime.tryParse(_answers['regimen_start'] ?? '');
    _concerns.addAll(
      (_answers['M07'] ?? '').split('|').where((answer) => answer.isNotEmpty),
    );
    _consent = SkinJourneyStore.instance.consent == true;
  }

  @override
  void dispose() {
    _regimenName.dispose();
    super.dispose();
  }

  void _choose(String id, String answer) {
    setState(() {
      if (id != 'M07') {
        _answers[id] = answer;
        return;
      }
      if (answer == 'Belum yakin') {
        _concerns
          ..clear()
          ..add(answer);
      } else {
        _concerns.remove('Belum yakin');
        if (!_concerns.add(answer)) _concerns.remove(answer);
      }
    });
  }

  void _showMissing(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jawab pertanyaan ${index + 1} terlebih dahulu.')),
    );
    final target = _questionKeys[index].currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> _submit() async {
    for (var i = 0; i < questions.length; i++) {
      final id = questions[i].$1;
      if (id == 'M07'
          ? _concerns.isEmpty
          : (_answers[id] == null || _answers[id]!.isEmpty)) {
        _showMissing(i);
        return;
      }
    }
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Setujui pemrosesan foto untuk melanjutkan scan.'),
      ));
      return;
    }

    _answers['M07'] = _concerns.join('|');
    if (_answers['M01'] == 'Ya') {
      _answers['regimen_name'] = _regimenName.text.trim();
      if (_regimenClass != null) {
        _answers['regimen_class'] = _regimenClass!;
      } else {
        _answers.remove('regimen_class');
      }
      if (_regimenStart != null) {
        _answers['regimen_start'] = _regimenStart!.toIso8601String();
      } else {
        _answers.remove('regimen_start');
      }
    } else {
      // Jangan gunakan perawatan lama bila pengguna sekarang menjawab tidak.
      _answers.remove('regimen_name');
      _answers.remove('regimen_class');
      _answers.remove('regimen_start');
    }

    SkinJourneyStore.instance
        .saveQuestionnaire(_answers, photoConsent: _consent);
    if (_answers['M03'] == 'Sedang-berat') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Jika iritasi cukup berat, periksakan ke tenaga kesehatan sebelum mencoba bahan aktif baru.'),
      ));
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SkinInitialScanPage(
          enableCamera: widget.enableCamera,
          autoStartScan: true,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SkinProgressPage()),
    );
  }

  Widget _option(String id, String answer) {
    final selected =
        id == 'M07' ? _concerns.contains(answer) : _answers[id] == answer;
    return OutlinedButton(
      onPressed: () => _choose(id, answer),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? SkinTokens.primaryDark : SkinTokens.muted,
        backgroundColor: selected ? SkinTokens.mint : SkinTokens.surface,
        side: BorderSide(
          color: selected ? SkinTokens.primary : SkinTokens.border,
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(64, 43),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Text(answer),
    );
  }

  Widget _question(int index) {
    final q = questions[index];
    return Container(
      key: _questionKeys[index],
      margin: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.$2, style: SkinTokens.section.copyWith(fontSize: 17)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: q.$3.map((answer) => _option(q.$1, answer)).toList(),
          ),
          if (q.$1 == 'M01' && _answers['M01'] == 'Ya') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _regimenName,
              decoration: const InputDecoration(
                labelText: 'Nama perawatan (opsional)',
                hintText: 'Produk atau bahan yang sedang dipakai',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _regimenClass,
              decoration: const InputDecoration(
                labelText: 'Perawatan ini untuk kondisi apa? (opsional)',
              ),
              items: SkinJourneyStore.visualClasses
                  .map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _regimenClass = value),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2010),
                  lastDate: DateTime.now(),
                  initialDate: _regimenStart ?? DateTime.now(),
                );
                if (picked != null) setState(() => _regimenStart = picked);
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_regimenStart == null
                  ? 'Sejak kapan digunakan? (opsional)'
                  : '${_regimenStart!.day}/${_regimenStart!.month}/${_regimenStart!.year}'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
          child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
            child: Column(
              children: [
                SkinPageHeader(
                  title: 'Kuesioner Awal',
                  backKey: const Key('quiz-back'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jawab tujuh pertanyaan berikut sesuai kondisimu.',
                          style: SkinTokens.caption,
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(questions.length, _question),
                        CheckboxListTile(
                          value: _consent,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) =>
                              setState(() => _consent = value ?? false),
                          title: const Text(
                            'Saya mengizinkan foto diproses untuk analisis dan pemantauan.',
                            style:
                                TextStyle(fontSize: 14, color: SkinTokens.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Lanjut ke Scan'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
