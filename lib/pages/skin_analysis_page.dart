import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/mock_recommendation_repository.dart';
import '../theme/app_copy.dart';
import '../theme/app_layout.dart';
import '../theme/app_tokens.dart';
import '../utils/analytics.dart';
import 'skin_result_page.dart';

/// Status analisis model v2.0 (FR-11..FR-15).
/// Loading skeleton tanpa progres palsu, timeout 20 dtk, retry maks 3x.
class SkinAnalysisPage extends StatefulWidget {
  final Uint8List? selfieBytes;
  final List<int>? quizAnswers;
  final bool lowAccuracy;
  final String scenario;

  const SkinAnalysisPage({
    super.key,
    this.selfieBytes,
    this.quizAnswers,
    this.lowAccuracy = false,
    this.scenario = 'normal',
  });

  @override
  State<SkinAnalysisPage> createState() => _SkinAnalysisPageState();
}

class _SkinAnalysisPageState extends State<SkinAnalysisPage> {
  int _attempt = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _attempt += 1;
      _error = null;
    });
    AppAnalytics.log('analysis_requested', {'attempt': _attempt});
    try {
      final rec = await MockRecommendationRepository.instance
          .fetchRecommendation(
        quizAnswers: widget.quizAnswers,
        scenario: widget.scenario,
      );
      AppAnalytics.log('analysis_success', {});
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SkinResultPage(
            selfieBytes: widget.selfieBytes,
            recommendation: rec,
            lowAccuracy: widget.lowAccuracy,
          ),
        ),
      );
    } on TimeoutException {
      AppAnalytics.log('analysis_failed', {'reason': 'timeout'});
      if (mounted) setState(() => _finishError(AppCopy.errTimeout));
    } on FormatException catch (e) {
      AppAnalytics.log('analysis_failed', {'reason': 'schema'});
      if (mounted) setState(() => _finishError('Data model rusak: ${e.message}'));
    } catch (_) {
      AppAnalytics.log('analysis_failed', {'reason': 'unknown'});
      if (mounted) setState(() => _finishError(AppCopy.errTimeout));
    }
  }

  void _finishError(String message) {
    _error = message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < AppLayout.compactBreakpoint;
                final margin = AppLayout.marginFor(constraints.maxWidth);
                return Padding(
                  padding: EdgeInsets.all(margin),
                  child: _error == null
                      ? _LoadingBody(compact: compact)
                      : _ErrorBody(
                          compact: compact,
                          message: _error.toString(),
                          canRetry: _attempt <
                              MockRecommendationRepository.maxRetry,
                          onRetry: _fetch,
                          onRetake: () => Navigator.of(context).pop(),
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

class _LoadingBody extends StatelessWidget {
  final bool compact;
  const _LoadingBody({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('analysis-loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppTokens.primary),
        const SizedBox(height: 16),
        Text(
          AppCopy.loadingRekomendasi,
          style: AppTokens.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 64,
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.r16),
              border: Border.all(color: AppTokens.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final bool compact;
  final String message;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onRetake;

  const _ErrorBody({
    required this.compact,
    required this.message,
    required this.canRetry,
    required this.onRetry,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('analysis-error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_rounded,
            size: 48, color: AppTokens.disabled),
        const SizedBox(height: 12),
        Text('Gagal menyusun rekomendasi',
            style: AppTokens.title, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(canRetry ? message : AppCopy.errRetryLimit,
            style: AppTokens.caption, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (canRetry)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('analysis-retry'),
              onPressed: onRetry,
              child: Text(AppCopy.ctaCobaLagi),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onRetake,
            child: const Text('Ulangi foto'),
          ),
        ),
      ],
    );
  }
}
