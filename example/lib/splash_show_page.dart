import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/data/common.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:amps_sdk_example/widgets/demo_ui.dart';
import 'package:flutter/material.dart';

class SplashShowPage extends StatefulWidget {
  const SplashShowPage({super.key, required this.title});

  final String title;

  @override
  State<SplashShowPage> createState() => _SplashShowPageState();
}

class _SplashShowPageState extends State<SplashShowPage> {
  AMPSSplashAd? _splashAdA;
  AMPSSplashAd? _splashAdB;
  late AdCallBack _adCallBackA;
  late AdCallBack _adCallBackB;

  num eCpm = 0;
  bool couldBack = true;
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
        _splashAdA?.showAd(splashBottomWidget: _buildBottomWidget('实例 A'));
      },
      onLoadFailure: (code, msg) {
        _setStatus('A 加载失败($code)，尝试 B');
        _tryShowB();
      },
      onAdClicked: () => setState(() => couldBack = true),
      onAdExposure: () => setState(() => couldBack = false),
      onAdClosed: () {
        setState(() => couldBack = true);
        _setStatus('A 已关闭，准备展示 B');
        _pendingShowBAfterAClosed = true;
        _tryShowB();
      },
      onAdShow: () => _setStatus('A 展示中'),
    );

    _adCallBackB = AdCallBack(
      onRenderOk: () {
        _isBReady = true;
        _setStatus('B 渲染完成');
        if (_pendingShowBAfterAClosed) _tryShowB();
      },
      onLoadFailure: (code, msg) => _setStatus('B 加载失败($code)'),
      onAdClicked: () => setState(() => couldBack = true),
      onAdExposure: () => setState(() => couldBack = false),
      onAdClosed: () {
        setState(() => couldBack = true);
        _setStatus('B 已关闭');
      },
      onAdShow: () => _setStatus('B 展示中'),
    );
  }

  void _setStatus(String text) {
    if (!mounted) return;
    setState(() => _statusText = text);
    debugPrint('[SplashMulti] $text');
  }

  SplashBottomWidget _buildBottomWidget(String label) {
    return SplashBottomWidget(
      height: 100,
      backgroundColor: '#FFFFFFFF',
      children: [
        ImageComponent(
          width: 25,
          height: 25,
          x: 170,
          y: 10,
          imagePath: 'assets/images/img.png',
        ),
        TextComponent(
          fontSize: 24,
          color: '#00ff00',
          x: 120,
          y: 50,
          text: label,
        ),
      ],
    );
  }

  void _loadTwoSplashAds() {
    _isBReady = false;
    _isShowingB = false;
    _pendingShowBAfterAClosed = false;
    _setStatus('正在并行加载 A / B...');

    final options = AdOptions(
      spaceId: splashSpaceId,
      screenMode: ScreenMode.fullScreen,
      splashAdBottomBuilderHeight: 100,
    );

    _splashAdA = AMPSSplashAd(config: options, mCallBack: _adCallBackA);
    _splashAdB = AMPSSplashAd(config: options, mCallBack: _adCallBackB);

    debugPrint('[SplashMulti] A instanceId=${_splashAdA!.instanceId}');
    debugPrint('[SplashMulti] B instanceId=${_splashAdB!.instanceId}');

    _splashAdA?.load();
    _splashAdB?.load();
  }

  Future<void> _tryShowB() async {
    if (!mounted || _isShowingB || _splashAdB == null || !_isBReady) return;
    final ready = await _splashAdB!.isReadyAd();
    if (!mounted || !ready) return;
    _isShowingB = true;
    _pendingShowBAfterAClosed = false;
    _splashAdB?.showAd(splashBottomWidget: _buildBottomWidget('实例 B'));
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
              title: '开屏双实例验证',
              subtitle: '并行 load A/B，A 先展示，关闭后自动展示 B',
              primaryText: '加载开屏 (A/B)',
              onPrimaryTap: _loadTwoSplashAds,
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
                    value: _splashAdA?.instanceId ?? '-',
                  ),
                  DemoInfoCard(
                    icon: Icons.fingerprint,
                    label: '实例 B ID',
                    value: _splashAdB?.instanceId ?? '-',
                  ),
                  DemoInfoCard(
                    icon: Icons.monetization_on_outlined,
                    label: '实例 A eCPM',
                    value: '$eCpm',
                  ),
                  const SizedBox(height: 8),
                  ButtonWidget(
                    buttonText: '刷新 A eCPM',
                    callBack: () async {
                      final v = await _splashAdA?.getECPM() ?? 0;
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
