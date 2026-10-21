import 'package:flutter/material.dart';

import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import '../widgets/skin_page_background.dart';
import 'skin_progress_page.dart';
import 'skin_quiz_page.dart';

class SkinJourneysPage extends StatelessWidget {
  const SkinJourneysPage({super.key});

  static const _cream = Color(0xFFFFFBF4);
  static const _navy = Color(0xFF16363C);
  static const _teal = Color(0xFF087D73);
  static const _mint = Color(0xFFE4F5ED);

  Future<void> _startJourney(BuildContext context) async {
    SkinJourneyStore.instance.beginNewJourney();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SkinQuizPage()),
    );
  }

  Future<void> _openJourney(
    BuildContext context,
    SkinJourneyRecord journey,
  ) async {
    if (!SkinJourneyStore.instance.selectJourney(journey.id)) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SkinProgressPage()),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    SkinJourneyRecord journey,
  ) async {
    final action = await showModalBottomSheet<_JourneyAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: _cream,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(
                  journey.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _actionTile(
                sheetContext,
                _JourneyAction.rename,
                Icons.edit_outlined,
                'Edit nama',
                key: Key('rename-journey-${journey.id}'),
              ),
              _actionTile(
                sheetContext,
                _JourneyAction.pin,
                journey.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                journey.isPinned ? 'Lepas pin' : 'Pin perjalanan',
                key: Key('pin-journey-${journey.id}'),
              ),
              if (journey.status != JourneyStatus.active)
                _actionTile(
                  sheetContext,
                  _JourneyAction.activate,
                  Icons.play_circle_outline_rounded,
                  'Aktifkan kembali',
                ),
              if (journey.status == JourneyStatus.active) ...[
                _actionTile(
                  sheetContext,
                  _JourneyAction.complete,
                  Icons.task_alt_rounded,
                  'Tandai selesai',
                ),
                _actionTile(
                  sheetContext,
                  _JourneyAction.cancel,
                  Icons.cancel_outlined,
                  'Batalkan perjalanan',
                  key: Key('cancel-journey-${journey.id}'),
                ),
              ],
              const Divider(height: 20),
              ListTile(
                key: Key('trash-journey-${journey.id}'),
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFB44B55)),
                title: const Text(
                  'Pindahkan ke sampah',
                  style: TextStyle(
                    color: Color(0xFFB44B55),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, _JourneyAction.trash),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    final store = SkinJourneyStore.instance;
    switch (action) {
      case _JourneyAction.rename:
        await _renameJourney(context, journey);
      case _JourneyAction.pin:
        store.togglePin(journey.id);
      case _JourneyAction.activate:
        store.setJourneyStatus(journey.id, JourneyStatus.active);
      case _JourneyAction.complete:
        store.setJourneyStatus(journey.id, JourneyStatus.completed);
      case _JourneyAction.cancel:
        store.setJourneyStatus(journey.id, JourneyStatus.cancelled);
      case _JourneyAction.trash:
        store.moveJourneyToTrash(journey.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perjalanan dipindahkan ke sampah.'),
              action: SnackBarAction(
                label: 'Pulihkan',
                onPressed: () => store.restoreJourney(journey.id),
              ),
            ),
          );
        }
    }
  }

  Widget _actionTile(
    BuildContext context,
    _JourneyAction action,
    IconData icon,
    String label, {
    Key? key,
  }) {
    return ListTile(
      key: key,
      leading: Icon(icon, color: _teal),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () => Navigator.pop(context, action),
    );
  }

  Future<void> _renameJourney(
    BuildContext context,
    SkinJourneyRecord journey,
  ) async {
    var draftName = journey.name;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit nama perjalanan'),
        content: TextFormField(
          key: const Key('journey-name-field'),
          initialValue: journey.name,
          autofocus: true,
          maxLength: 50,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nama perjalanan'),
          onChanged: (value) => draftName = value,
          onFieldSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('save-journey-name'),
            onPressed: () => Navigator.pop(dialogContext, draftName),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (name != null) {
      SkinJourneyStore.instance.renameJourney(journey.id, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return Scaffold(
      backgroundColor: _cream,
      body: SkinPageBackground(
          child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final journeys = store.journeys;
                return ListView(
                  key: const Key('journeys-list'),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                  children: [
                    const SkinPageHeader(
                      title: 'Skin Journey',
                      backKey: Key('journeys-back'),
                    ),
                    const Text(
                      'Pantau setiap perjalanan kulit secara terpisah.',
                      style: SkinTokens.caption,
                    ),
                    const SizedBox(height: 18),
                    _NewJourneyCard(onTap: () => _startJourney(context)),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Perjalanan Saya',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${journeys.length} perjalanan',
                          style: SkinTokens.caption,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          key: const Key('open-journey-trash'),
                          tooltip: 'Sampah',
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const SkinJourneyTrashPage(),
                            ),
                          ),
                          icon: Badge(
                            isLabelVisible: store.trashedJourneys.isNotEmpty,
                            label: Text('${store.trashedJourneys.length}'),
                            child: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (journeys.isEmpty)
                      const _EmptyJourneys()
                    else
                      for (var index = 0; index < journeys.length; index++) ...[
                        _JourneyListItem(
                          journey: journeys[index],
                          onTap: () => _openJourney(context, journeys[index]),
                          onMore: () => _showActions(context, journeys[index]),
                        ),
                        if (index < journeys.length - 1)
                          const Divider(
                            height: 1,
                            color: Color(0xFFDDE7E2),
                          ),
                      ],
                  ],
                );
              },
            ),
          ),
        ),
      )),
    );
  }
}

class _NewJourneyCard extends StatelessWidget {
  const _NewJourneyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F4F1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: SkinJourneysPage._teal, size: 21),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Mulai Perjalanan Baru',
                  style: TextStyle(
                    color: SkinJourneysPage._navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Buat perjalanan baru dengan kuis dan scan awal.',
            style: SkinTokens.caption,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('start-new-journey'),
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Mulai perjalanan baru'),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyListItem extends StatelessWidget {
  const _JourneyListItem({
    required this.journey,
    required this.onTap,
    required this.onMore,
  });

  final SkinJourneyRecord journey;
  final VoidCallback onTap;
  final VoidCallback onMore;

  String _date(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final findings = journey.findings;
    final start = journey.baselineDate ?? journey.createdAt;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('journey-card-${journey.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _JourneyThumbnail(journey: journey),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (journey.isPinned) ...[
                          const Icon(
                            Icons.push_pin_rounded,
                            color: SkinJourneysPage._teal,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          child: Text(
                            journey.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SkinJourneysPage._navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusChip(status: journey.status),
                        Text('Dimulai ${_date(start)}',
                            style: SkinTokens.caption),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      findings.isEmpty
                          ? 'Belum ada hasil scan'
                          : findings.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkinJourneysPage._navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${journey.photos.length} foto · '
                      '${journey.checkins.length} check-in',
                      style: SkinTokens.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: Key('journey-menu-${journey.id}'),
                    tooltip: 'Kelola perjalanan',
                    visualDensity: VisualDensity.compact,
                    onPressed: onMore,
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: SkinJourneysPage._teal,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyThumbnail extends StatelessWidget {
  const _JourneyThumbnail({required this.journey});

  final SkinJourneyRecord journey;

  @override
  Widget build(BuildContext context) {
    final photo = journey.photos.isEmpty ? null : journey.photos.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: photo != null && photo.bytes.isNotEmpty
          ? Image.memory(photo.bytes, width: 68, height: 68, fit: BoxFit.cover)
          : Container(
              width: 68,
              height: 68,
              color: SkinJourneysPage._mint,
              child: const Icon(Icons.spa_outlined,
                  color: SkinJourneysPage._teal, size: 30),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final JourneyStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      JourneyStatus.active => (
          'Aktif',
          const Color(0xFFDDF4E7),
          const Color(0xFF16734B),
        ),
      JourneyStatus.completed => (
          'Selesai',
          const Color(0xFFE4EEF8),
          const Color(0xFF315F86),
        ),
      JourneyStatus.cancelled => (
          'Batal',
          const Color(0xFFF6E7E8),
          const Color(0xFF9D424B),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyJourneys extends StatelessWidget {
  const _EmptyJourneys();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      key: Key('empty-journeys'),
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Text(
        'Belum ada perjalanan.',
        textAlign: TextAlign.center,
        style: SkinTokens.caption,
      ),
    );
  }
}

class SkinJourneyTrashPage extends StatelessWidget {
  const SkinJourneyTrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return Scaffold(
      backgroundColor: SkinJourneysPage._cream,
      body: SkinPageBackground(
          child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final items = store.trashedJourneys;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                  children: [
                    const SkinPageHeader(
                      title: 'Sampah',
                      backKey: Key('journey-trash-back'),
                    ),
                    const Text(
                      'Perjalanan di sini tidak dihapus permanen.',
                      style: SkinTokens.caption,
                    ),
                    const SizedBox(height: 18),
                    if (items.isEmpty)
                      const _EmptyTrash()
                    else
                      for (final journey in items)
                        Container(
                          key: Key('trashed-journey-${journey.id}'),
                          margin: const EdgeInsets.only(bottom: 11),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: SkinTokens.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: SkinTokens.muted),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  journey.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: SkinJourneysPage._navy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              TextButton(
                                key: Key('restore-journey-${journey.id}'),
                                onPressed: () =>
                                    store.restoreJourney(journey.id),
                                child: const Text('Pulihkan'),
                              ),
                            ],
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      )),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('empty-journey-trash'),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SkinTokens.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.delete_sweep_outlined, color: SkinTokens.muted, size: 34),
          SizedBox(height: 8),
          Text('Sampah masih kosong.', style: SkinTokens.caption),
        ],
      ),
    );
  }
}

enum _JourneyAction { rename, pin, activate, complete, cancel, trash }
