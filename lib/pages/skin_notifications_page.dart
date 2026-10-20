import 'package:flutter/material.dart';

import '../data/skin_journey_store.dart';
import '../data/skin_notification_center.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_background.dart';
import 'skin_progress_page.dart';
import 'skin_scan_page.dart';

class SkinNotificationsPage extends StatelessWidget {
  const SkinNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    final center = SkinNotificationCenter.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      body: SkinPageBackground(
          child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
            child: AnimatedBuilder(
              animation: Listenable.merge([store, center]),
              builder: (context, _) {
                final notifications = SkinNotificationFeed.build(store);
                final unread = notifications
                    .where((item) => !center.isRead(item.id))
                    .length;
                final today = notifications
                    .where((item) =>
                        SkinJourneyStore.sameDay(item.date, store.today))
                    .toList();
                final previous = notifications
                    .where((item) =>
                        !SkinJourneyStore.sameDay(item.date, store.today))
                    .toList();

                return Column(
                  children: [
                    _NotificationHeader(
                      unread: unread,
                      onMarkAll: unread == 0
                          ? null
                          : () => center.markAllRead(notifications),
                    ),
                    Expanded(
                      child: notifications.isEmpty
                          ? const _EmptyNotifications()
                          : ListView(
                              key: const Key('notifications-list'),
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              children: [
                                if (today.isNotEmpty)
                                  _NotificationGroup(
                                    title: 'Hari ini',
                                    items: today,
                                    center: center,
                                  ),
                                if (today.isNotEmpty && previous.isNotEmpty)
                                  const SizedBox(height: 24),
                                if (previous.isNotEmpty)
                                  _NotificationGroup(
                                    title: 'Sebelumnya',
                                    items: previous,
                                    center: center,
                                  ),
                                const SizedBox(height: 26),
                                const _NotificationFootnote(),
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

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.unread, required this.onMarkAll});

  final int unread;
  final VoidCallback? onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 16, 12),
      child: Row(
        children: [
          IconButton(
            key: const Key('notifications-back'),
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: SkinTokens.ink,
          ),
          const Expanded(
            child: Text(
              'Notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkinTokens.ink,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -.3,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: unread == 0
                ? const Icon(Icons.done_all_rounded,
                    color: SkinTokens.primary, size: 22)
                : TextButton(
                    key: const Key('mark-all-notifications-read'),
                    onPressed: onMarkAll,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 44),
                    ),
                    child: const Text(
                      'Baca',
                      style: TextStyle(
                        color: SkinTokens.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.title,
    required this.items,
    required this.center,
  });

  final String title;
  final List<SkinNotificationItem> items;
  final SkinNotificationCenter center;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: SkinTokens.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDCE8E2)),
          ),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _NotificationTile(
                  item: items[index],
                  isRead: center.isRead(items[index].id),
                  onTap: () => _open(context, items[index]),
                ),
                if (index != items.length - 1)
                  const Divider(height: 1, indent: 70, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, SkinNotificationItem item) {
    center.markRead(item.id);
    final page = switch (item.destination) {
      SkinNotificationDestination.scan => const SkinScanPage(),
      SkinNotificationDestination.journey => const SkinProgressPage(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isRead,
    required this.onTap,
  });

  final SkinNotificationItem item;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = switch (item.kind) {
      'result' => (
          Icons.auto_graph_rounded,
          const Color(0xFFFFE9D8),
          const Color(0xFFB66446)
        ),
      'checkin' => (
          Icons.task_alt_rounded,
          const Color(0xFFE3F2EB),
          SkinTokens.primary
        ),
      _ => (
          Icons.notifications_active_outlined,
          const Color(0xFFDDEFF1),
          const Color(0xFF287D84)
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('notification-${item.id}'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: visual.$2,
                  shape: BoxShape.circle,
                ),
                child: Icon(visual.$1, color: visual.$3, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: SkinTokens.ink,
                              fontSize: 14,
                              fontWeight:
                                  isRead ? FontWeight.w700 : FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _dateLabel(
                              item.date, SkinJourneyStore.instance.today),
                          style: const TextStyle(
                            color: SkinTokens.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 7),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: SkinTokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: SkinTokens.muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date, DateTime now) {
    if (SkinJourneyStore.sameDay(date, now)) {
      return '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NotificationFootnote extends StatelessWidget {
  const _NotificationFootnote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 17, color: SkinTokens.primary),
        SizedBox(width: 7),
        Flexible(
          child: Text(
            'Notifikasi mengikuti aktivitas Skin Journey milikmu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SkinTokens.muted,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 45, color: SkinTokens.primary),
            SizedBox(height: 14),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: SkinTokens.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
