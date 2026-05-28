import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/data/common.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:amps_sdk_example/widgets/demo_ui.dart';
import 'package:flutter/material.dart';

class InterstitialShowPage extends StatefulWidget {
  const InterstitialShowPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialShowPage> createState() => _InterstitialShowPageState();
}

class _InterstitialShowPageState extends State<InterstitialShowPage> {
  AMPSInterstitialAd? _interAdA;
  AMPSInterstitialAd? _interAdB;
  late AdCallBack _adCallBackA;
  late AdCallBack _adCallBackB;

  bool couldBack = true;
  num eCpm = 0;
  bool _isBReady = false;
  bool _pendingShowBAfterAClosed = false;
  bool _isShowingB = false;
  String _statusText = '等待加载';

  @override
  void initState() {
    super.initState();
    _initListeners();
  }

  void _initListeners() {
    _adCallBackA = AdCallBack(
      onRenderOk: () {
        _setStatus('A 渲染完成，正在展示');
        _interAdA?.showAd();
      },
      onLoadFailure: (code, msg) {
        _setStatus('A 加载失败($code)，尝试 B');
        _tryShowB();
      },
      onAdClicked: () => setState(() => couldBack = true),
      onAdClosed: () {
        setState(() => couldBack = true);
        _setStatus('A 已关闭，准备展示 B');
        _pendingShowBAfterAClosed = true;
        _tryShowB();
      },
      onAdShow: () {
        setState(() => couldBack = false);
        _setStatus('A 展示中');
      },
    );

    _adCallBackB = AdCallBack(
      onRenderOk: () {
        _isBReady = true;
        _setStatus('B 渲染完成');
        if (_pendingShowBAfterAClosed) _tryShowB();
      },
      onLoadFailure: (code, msg) => _setStatus('B 加载失败($code)'),
      onAdClicked: () => setState(() => couldBack = true),
      onAdClosed: () {
        setState(() => couldBack = true);
        _setStatus('B 已关闭');
      },
      onAdShow: () {
        setState(() => couldBack = false);
        _setStatus('B 展示中');
      },
    );
  }

  void _setStatus(String text) {
    if (!mounted) return;
    setState(() => _statusText = text);
    debugPrint('[InterstitialMulti] $text');
  }

  void _loadTwoInterstitialAds() {
    _isBReady = false;
    _isShowingB = false;
    _pendingShowBAfterAClosed = false;
    _setStatus('正在并行加载 A / B...');

    final options = AdOptions(spaceId: interstitialSpaceId);

    _interAdA = AMPSInterstitialAd(config: options, mCallBack: _adCallBackA);
    _interAdB = AMPSInterstitialAd(config: options, mCallBack: _adCallBackB);

    debugPrint('[InterstitialMulti] A instanceId=${_interAdA!.instanceId}');
    debugPrint('[InterstitialMulti] B instanceId=${_interAdB!.instanceId}');

    _interAdA?.load();
    _interAdB?.load();
  }

  Future<void> _tryShowB() async {
    if (!mounted || _isShowingB || _interAdB == null || !_isBReady) return;
    final ready = await _interAdB!.isReadyAd();
    if (!mounted || !ready) return;
    _isShowingB = true;
    _pendingShowBAfterAClosed = false;
    _interAdB?.showAd();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: couldBack,
      child: Scaffold(
        backgroundColor: DemoColors.background,
        appBar: demoAppBar(widget.title),
        body: Column(
          children: [
            DemoPageHeader(
              title: '插屏双实例验证',
              subtitle: '并行 load A/B，A 先展示，关闭后自动展示 B',
              primaryText: '加载插屏 (A/B)',
              onPrimaryTap: _loadTwoInterstitialAds,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  DemoInfoCard(
                    icon: Icons.info_outline,
                    label: '当前状态',
                    value: _statusText,
                  ),
                  DemoInfoCard(
                    icon: Icons.fingerprint,
                    label: '实例 A ID',
                    value: _interAdA?.instanceId ?? '-',
                  ),
                  DemoInfoCard(
                    icon: Icons.fingerprint,
                    label: '实例 B ID',
                    value: _interAdB?.instanceId ?? '-',
                  ),
                  DemoInfoCard(
                    icon: Icons.monetization_on_outlined,
                    label: '实例 A eCPM',
                    value: '$eCpm',
                  ),
                  const SizedBox(height: 8),
              ButtonWidget(
                buttonText: '刷新 A eCPM',
                backgroundColor: DemoColors.primary,
                callBack: () async {
                  final v = await _interAdA?.getECPM() ?? 0;
                  if (mounted) setState(() => eCpm = v);
                },
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
