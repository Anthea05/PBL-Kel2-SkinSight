import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile_data.dart';

class SkinProfilePage extends StatelessWidget {
  const SkinProfilePage({super.key});

  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFF8EB);
  static const _sky = Color(0xFF2FC1ED);
  static const _coral = Color(0xFFE6535F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sky,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_sky, Color(0xFFE6F7F3), _cream],
                  stops: [0, .28, 1],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 350;
                  return Column(
                    children: [
                      _ProfileHeader(compact: compact),
                      Expanded(
                        child: SingleChildScrollView(
                          key: const Key('profile-scroll'),
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            compact ? 14 : 20,
                            8,
                            compact ? 14 : 20,
                            28,
                          ),
                          child: Column(
                            children: [
                              _IdentitySection(compact: compact),
                              SizedBox(height: compact ? 22 : 28),
                              const _ProfileFields(),
                              SizedBox(height: compact ? 26 : 34),
                              const _LogoutButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool compact;

  const _ProfileHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: .94),
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('profile-back'),
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 46 : 52,
                height: compact ? 46 : 52,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: SkinProfilePage._deepTeal,
                  size: 34,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Profil Saya',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkinProfilePage._navy,
                fontSize: compact ? 23 : 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: compact ? 46 : 52),
        ],
      ),
    );
  }
}

class _IdentitySection extends StatelessWidget {
  final bool compact;

  const _IdentitySection({required this.compact});

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!context.mounted) return;
    context.read<ProfileData>().updatePhoto(bytes);
  }

  void _showPhotoSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: SkinProfilePage._cream,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah foto profil',
                style: TextStyle(
                  color: SkinProfilePage._navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                key: const Key('profile-photo-camera'),
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                key: const Key('profile-photo-gallery'),
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileData>();
    final initials = _initials(profile.name);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: compact ? 108 : 124,
              height: compact ? 108 : 124,
              decoration: BoxDecoration(
                color: const Color(0xFFE2F4EF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: SkinProfilePage._deepTeal.withValues(alpha: .16),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipOval(
                child: profile.photoBytes == null
                    ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: SkinProfilePage._deepTeal,
                            fontSize: compact ? 31 : 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : Image.memory(
                        profile.photoBytes!,
                        key: const Key('profile-photo'),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            Positioned(
              right: -3,
              bottom: 4,
              child: Material(
                color: SkinProfilePage._teal,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  key: const Key('edit-profile-photo'),
                  onTap: () => _showPhotoSource(context),
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 39,
                    height: 39,
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          profile.name,
          key: const Key('profile-name-heading'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: SkinProfilePage._navy,
            fontSize: compact ? 23 : 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Akun SkinSight',
          style: TextStyle(color: Color(0xFF5B737C), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F4F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Demo',
            style: TextStyle(
              color: Color(0xFF087467),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileFields extends StatelessWidget {
  const _ProfileFields();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileData>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SkinProfilePage._deepTeal.withValues(alpha: .08),
        ),
      ),
      child: Column(
        children: [
          _ProfileField(
            editKey: const Key('edit-profile-name'),
            icon: Icons.person_outline_rounded,
            label: 'Nama',
            value: profile.name,
            onEdit: () => _editValue(
              context,
              title: 'Ubah nama',
              label: 'Nama lengkap',
              initialValue: profile.name,
              onSaved: context.read<ProfileData>().updateName,
            ),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-password'),
            icon: Icons.lock_outline_rounded,
            label: 'Password',
            value: '••••••••••••',
            onEdit: () => _editPassword(context),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-phone'),
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: profile.phone,
            onEdit: () => _editValue(
              context,
              title: 'Ubah nomor telepon',
              label: 'Nomor telepon',
              initialValue: profile.phone,
              keyboardType: TextInputType.phone,
              onSaved: context.read<ProfileData>().updatePhone,
            ),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-email'),
            icon: Icons.mail_outline_rounded,
            label: 'Alamat email',
            value: profile.email,
            onEdit: () => _editValue(
              context,
              title: 'Ubah alamat email',
              label: 'Alamat email',
              initialValue: profile.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: context.read<ProfileData>().updateEmail,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editValue(
  BuildContext context, {
  required String title,
  required String label,
  required String initialValue,
  required ValueChanged<String> onSaved,
  TextInputType? keyboardType,
}) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => _EditValueDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      keyboardType: keyboardType,
    ),
  );
  if (value != null) onSaved(value);
}

Future<void> _editPassword(BuildContext context) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => const _PasswordDialog(),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui.')),
    );
  }
}

class _EditValueDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final TextInputType? keyboardType;

  const _EditValueDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.keyboardType,
  });

  @override
  State<_EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<_EditValueDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('profile-edit-input'),
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-profile-edit'),
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) Navigator.of(context).pop(text);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _save() {
    if (_newPassword.text.length < 8) {
      setState(() => _error = 'Minimal 8 karakter.');
    } else if (_newPassword.text != _confirmation.text) {
      setState(() => _error = 'Password tidak sama.');
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('new-password-input'),
            controller: _newPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password baru',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('confirm-password-input'),
            controller: _confirmation,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Ulangi password',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-password'),
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final Key editKey;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _ProfileField({
    required this.editKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
      child: Row(
        children: [
          Icon(icon, color: SkinProfilePage._deepTeal, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6D808A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SkinProfilePage._navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: editKey,
            tooltip: 'Edit $label',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: SkinProfilePage._deepTeal,
          ),
        ],
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 52,
      endIndent: 14,
      color: Color(0xFFE5EBEA),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk membuka data akun SkinSight.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm-logout'),
            style: FilledButton.styleFrom(
              backgroundColor: SkinProfilePage._coral,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu telah keluar dari akun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('logout-account'),
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: SkinProfilePage._coral,
          side: const BorderSide(color: Color(0xFFE7A5AA)),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Keluar akun',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
