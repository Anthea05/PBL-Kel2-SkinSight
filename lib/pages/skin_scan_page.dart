import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_copy.dart';
import '../utils/analytics.dart';
import 'skin_analysis_page.dart';

class SkinScanPage extends StatefulWidget {
  final bool enableCamera;
  final List<int>? quizAnswers;

  const SkinScanPage({super.key, this.enableCamera = true, this.quizAnswers});

  @override
  State<SkinScanPage> createState() => _SkinScanPageState();
}

class _SkinScanPageState extends State<SkinScanPage>
    with WidgetsBindingObserver {
  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFFBF2);

  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _automaticMode = true;
  bool _consented = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableCamera) {
      _initializeCamera();
    } else {
      _isLoading = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && widget.enableCamera) {
      _initializeCamera(preferredIndex: _cameraIndex);
    }
  }

  Future<void> _initializeCamera({int? preferredIndex}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 30),
      );
      if (cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'Tidak ada kamera yang ditemukan pada perangkat ini.',
        );
      }

      final frontIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      final selectedIndex = preferredIndex != null &&
              preferredIndex >= 0 &&
              preferredIndex < cameras.length
          ? preferredIndex
          : (frontIndex >= 0 ? frontIndex : 0);

      final oldController = _controller;
      final controller = CameraController(
        cameras[selectedIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller = controller;
      await oldController?.dispose();
      await controller.initialize().timeout(const Duration(seconds: 30));

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameras = cameras;
        _cameraIndex = selectedIndex;
        _isLoading = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = switch (error.code) {
          'CameraAccessDenied' ||
          'CameraAccessDeniedWithoutPrompt' ||
          'CameraAccessRestricted' =>
            AppCopy.errCameraDenied,
          'CameraNotFound' || 'NoCameraFound' => AppCopy.errNoCamera,
          _ => error.description ?? 'Kamera tidak dapat dibuka.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kamera tidak dapat dibuka. Coba muat ulang halaman.';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    await _initializeCamera(preferredIndex: nextIndex);
  }

  static const int _maxPhotoBytes = 10 * 1024 * 1024;

  /// FR-07/privasi: persetujuan sebelum foto pertama (§13).
  Future<bool> _ensureConsent() async {
    if (_consented) return true;
    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.consentTitle),
        content: const Text(AppCopy.consentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppCopy.consentAgree),
          ),
        ],
      ),
    );
    if (agreed == true) {
      AppAnalytics.log('consent_granted', {});
      setState(() => _consented = true);
      return true;
    }
    return false;
  }

  bool _checkSize(Uint8List bytes) {
    if (bytes.lengthInBytes > _maxPhotoBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppCopy.errFileTooBig)),
      );
      return false;
    }
    return true;
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isCapturing) {
      return;
    }
    if (!await _ensureConsent()) return;

    setState(() => _isCapturing = true);
    try {
      final picture = await controller.takePicture();
      final bytes = await picture.readAsBytes();
      if (!mounted) return;
      if (!_checkSize(bytes)) return;
      AppAnalytics.log('scan_captured', {'source': 'camera'});
      await _openAnalysis(bytes);
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.description ?? 'Gagal mengambil foto.')),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;
    if (!await _ensureConsent()) return;
    final picture = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
    );
    if (picture == null || !mounted) return;
    final bytes = await picture.readAsBytes();
    if (!mounted) return;
    if (!_checkSize(bytes)) return;
    AppAnalytics.log('scan_captured', {'source': 'gallery'});
    await _openAnalysis(bytes);
  }

  Future<void> _openAnalysis(Uint8List bytes) async {
    final quizAnswers = widget.quizAnswers;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SkinAnalysisPage(
          selfieBytes: bytes,
          quizAnswers: quizAnswers,
          lowAccuracy: quizAnswers == null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 350;
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, _cream, Color(0xFFE8FBF7)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _ScanBackgroundPainter()),
                        ),
                      ),
                      Column(
                        children: [
                          _ScanHeader(
                            compact: compact,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                compact ? 12 : 18,
                                8,
                                compact ? 12 : 18,
                                24,
                              ),
                              child: Column(
                                children: [
                                  _CameraFrame(
                                    compact: compact,
                                    controller: _controller,
                                    loading: _isLoading,
                                    errorMessage: _errorMessage,
                                    onRetry: _initializeCamera,
                                  ),
                                  const SizedBox(height: 10),
                                  _ModeSwitch(
                                    automatic: _automaticMode,
                                    compact: compact,
                                    onChanged: (value) => setState(
                                      () => _automaticMode = value,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                          // Sticky: tombol shutter/galeri selalu terlihat
                          // tanpa scroll (zona jempol, §9.1/§11.2).
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 12 : 18,
                              8,
                              compact ? 12 : 18,
                              12,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8FBF7),
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFD9E6E3),
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CaptureControls(
                                  compact: compact,
                                  canSwitch: _cameras.length > 1,
                                  isCapturing: _isCapturing,
                                  onGallery: _pickFromGallery,
                                  onCapture: _takePicture,
                                  onSwitch: _switchCamera,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _automaticMode
                                      ? '${AppCopy.lightHint}. Posisikan wajah di dalam frame.'
                                      : 'Mode manual. ${AppCopy.lightHint}.',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _navy.withValues(alpha: .62),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback onBack;

  const _ScanHeader({required this.compact, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 8),
      child: Row(
        children: [
          Material(
            color: const Color(0xFFE9F7F4),
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('scan-back'),
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 46 : 52,
                height: compact ? 46 : 52,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: _SkinScanPageState._deepTeal,
                  size: 34,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Scan Wajah',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _SkinScanPageState._navy,
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

class _CameraFrame extends StatelessWidget {
  final bool compact;
  final CameraController? controller;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _CameraFrame({
    required this.compact,
    required this.controller,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 360.0 : 440.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 30 : 38),
        boxShadow: [
          BoxShadow(
            color: _SkinScanPageState._deepTeal.withValues(alpha: .10),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 26 : 34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(),
            const CustomPaint(painter: _FaceGuidePainter()),
            Align(
              alignment: const Alignment(0, .84),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 26),
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: compact ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: _SkinScanPageState._navy.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Text(
                  'Posisikan wajah di dalam frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final camera = controller;
    if (loading) {
      return const ColoredBox(
        color: Color(0xFFF4FAF8),
        child: Center(
          child: CircularProgressIndicator(color: _SkinScanPageState._teal),
        ),
      );
    }
    if (errorMessage != null) {
      return ColoredBox(
        color: const Color(0xFFF4FAF8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  color: _SkinScanPageState._deepTeal,
                  size: 52,
                ),
                const SizedBox(height: 14),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _SkinScanPageState._navy,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const Key('retry-camera'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (camera == null || !camera.value.isInitialized) {
      return const ColoredBox(color: Color(0xFFF4FAF8));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = camera.value.previewSize;
        if (previewSize == null) return CameraPreview(camera);
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(camera),
            ),
          ),
        );
      },
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool automatic;
  final bool compact;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({
    required this.automatic,
    required this.compact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 52 : 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD9E6E3)),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Foto Otomatis',
            selected: automatic,
            onTap: () => onChanged(true),
          ),
          _ModeButton(
            label: 'Foto Manual',
            selected: !automatic,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _SkinScanPageState._teal : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF718184),
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureControls extends StatelessWidget {
  final bool compact;
  final bool canSwitch;
  final bool isCapturing;
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onSwitch;

  const _CaptureControls({
    required this.compact,
    required this.canSwitch,
    required this.isCapturing,
    required this.onGallery,
    required this.onCapture,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SquareAction(
          key: const Key('scan-gallery'),
          icon: Icons.photo_library_outlined,
          onTap: onGallery,
        ),
        Semantics(
          button: true,
          label: 'Ambil foto wajah',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('capture-selfie'),
              onTap: isCapturing ? null : onCapture,
              customBorder: const CircleBorder(),
              child: Container(
                width: compact ? 82 : 94,
                height: compact ? 82 : 94,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _SkinScanPageState._deepTeal,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _SkinScanPageState._deepTeal.withValues(alpha: .18),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _SkinScanPageState._teal,
                    shape: BoxShape.circle,
                  ),
                  child: isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        _SquareAction(
          key: const Key('switch-camera'),
          icon: Icons.cameraswitch_outlined,
          onTap: canSwitch ? onSwitch : null,
        ),
      ],
    );
  }
}

class _SquareAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SquareAction({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: _SkinScanPageState._deepTeal.withValues(alpha: .16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: 66,
          height: 66,
          child: Icon(
            icon,
            color: onTap == null
                ? const Color(0xFFB5C1C0)
                : _SkinScanPageState._deepTeal,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .47),
      width: size.width * .62,
      height: size.height * .68,
    );
    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: .70),
    );

    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = _SkinScanPageState._teal;
    final path = Path()..addOval(oval.deflate(14));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 9),
          dashPaint,
        );
        distance += 17;
      }
    }

    final cornerPaint = Paint()
      ..color = _SkinScanPageState._teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const corner = 34.0;
    final left = size.width * .17;
    final right = size.width * .83;
    final top = size.height * .16;
    final bottom = size.height * .77;
    canvas.drawLine(Offset(left, top + corner), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + corner, top), cornerPaint);
    canvas.drawLine(
        Offset(right - corner, top), Offset(right, top), cornerPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + corner), cornerPaint);
    canvas.drawLine(
        Offset(left, bottom - corner), Offset(left, bottom), cornerPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left + corner, bottom), cornerPaint);
    canvas.drawLine(
        Offset(right - corner, bottom), Offset(right, bottom), cornerPaint);
    canvas.drawLine(
        Offset(right, bottom), Offset(right, bottom - corner), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanBackgroundPainter extends CustomPainter {
  const _ScanBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = const Color(0xFF47BDE8).withValues(alpha: .10);
    final mint = Paint()
      ..color = const Color(0xFF6EDBCB).withValues(alpha: .12);
    final topPath = Path()
      ..moveTo(0, size.height * .13)
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .07,
        size.width * .62,
        size.height * .15,
      )
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .20,
        size.width,
        size.height * .10,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(topPath, blue);

    final bottomPath = Path()
      ..moveTo(0, size.height * .92)
      ..quadraticBezierTo(
        size.width * .33,
        size.height,
        size.width * .61,
        size.height * .94,
      )
      ..quadraticBezierTo(
        size.width * .83,
        size.height * .90,
        size.width,
        size.height * .97,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottomPath, mint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
