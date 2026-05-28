import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/data/common.dart';
import 'package:amps_sdk_example/widgets/demo_ui.dart';
import 'package:flutter/material.dart';

class _FeedAdItem {
  const _FeedAdItem({
    required this.adId,
    required this.nativeAd,
    required this.label,
  });

  final String adId;
  final AMPSNativeAd nativeAd;
  final String label;
}

class NativePage extends StatefulWidget {
  const NativePage({super.key, required this.title});

  final String title;

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  AMPSNativeAd? _nativeAdA;
  AMPSNativeAd? _nativeAdB;

  final List<String> feedList = [];
  final List<_FeedAdItem> feedAdList = [];

  double _cardWidth = 0;
  double _adHeight = 128;

  bool _isBLoaded = false;
  String? _bAdId;
  bool _pendingShowBAfterAClosed = false;
  bool _isShowingB = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add('Feed #$i');
    }
  }

  void _updateLayoutSize(BuildContext context) {
    _cardWidth = MediaQuery.of(context).size.width - 32;
    _adHeight = (_cardWidth * 0.36).clamp(120.0, 180.0);
  }

  AMPSNativeAd _createNativeAd(String label) {
    return AMPSNativeAd(
      config: AdOptions(
        spaceId: nativeSpaceId,
        adCount: 1,
        expressSize: [_cardWidth, _adHeight],
      ),
      mCallBack: AmpsNativeAdListener(
        loadOk: (adIds) =>
            debugPrint('[NativeMulti] $label loadOk adIds=$adIds instanceId=${label == 'A' ? _nativeAdA?.instanceId : _nativeAdB?.instanceId}'),
        loadFail: (code, message) {
          debugPrint('[NativeMulti] $label loadFail code=$code msg=$message');
          if (label == 'A') _tryShowB();
        },
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (adId) {
          debugPrint('[NativeMulti] $label renderSuccess adId=$adId');
          if (label == 'A') {
            setState(() {
              feedAdList.removeWhere((item) => item.label == 'A');
              feedAdList.add(_FeedAdItem(
                adId: adId,
                nativeAd: _nativeAdA!,
                label: 'A',
              ));
            });
          } else {
            _bAdId = adId;
            _isBLoaded = true;
            if (_pendingShowBAfterAClosed) _tryShowB();
          }
        },
        renderFailed: (adId, code, message) =>
            debugPrint('[NativeMulti] $label renderFailed adId=$adId code=$code'),
      ),
      mInteractiveCallBack: AmpsNativeInteractiveListener(
        onAdShow: (adId) => debugPrint('[NativeMulti] $label onAdShow adId=$adId'),
        onAdExposure: (adId) => debugPrint('[NativeMulti] $label onAdExposure adId=$adId'),
        onAdClicked: (adId) => debugPrint('[NativeMulti] $label onAdClicked adId=$adId'),
        toCloseAd: (adId) {
          if (adId != null) _handleAdClosed(adId, isInstanceA: label == 'A');
        },
      ),
    );
  }

  void _handleAdClosed(String adId, {required bool isInstanceA}) {
    debugPrint('[NativeMulti] ${isInstanceA ? 'A' : 'B'} toCloseAd adId=$adId');
    if (!mounted) return;
    setState(() => feedAdList.removeWhere((item) => item.adId == adId));
    if (isInstanceA) {
      _pendingShowBAfterAClosed = true;
      _tryShowB();
    }
  }

  void _loadTwoNativeAds() {
    if (_cardWidth <= 0) return;

    _isBLoaded = false;
    _bAdId = null;
    _isShowingB = false;
    _pendingShowBAfterAClosed = false;
    setState(() => feedAdList.clear());

    _nativeAdA = _createNativeAd('A');
    _nativeAdB = _createNativeAd('B');

    debugPrint('[NativeMulti] A instanceId=${_nativeAdA!.instanceId}');
    debugPrint('[NativeMulti] B instanceId=${_nativeAdB!.instanceId}');

    _nativeAdA?.setVideoPlayConfig(
      const AMPSAdVideoPlayConfig(
        videoSoundEnable: true,
        videoAutoPlayType: 3,
        videoLoopReplay: true,
      ),
    );
    _nativeAdB?.setVideoPlayConfig(
      const AMPSAdVideoPlayConfig(
        videoSoundEnable: true,
        videoAutoPlayType: 3,
        videoLoopReplay: true,
      ),
    );

    _nativeAdA?.load();
    _nativeAdB?.load();
  }

  void _tryShowB() {
    if (!mounted || _isShowingB || _nativeAdB == null) return;
    if (!_isBLoaded || _bAdId == null) return;
    _isShowingB = true;
    _pendingShowBAfterAClosed = false;
    setState(() {
      feedAdList.removeWhere((item) => item.label == 'B');
      feedAdList.add(_FeedAdItem(
        adId: _bAdId!,
        nativeAd: _nativeAdB!,
        label: 'B',
      ));
    });
  }

  Widget _buildAdCard(_FeedAdItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DemoColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: _cardWidth,
            height: _adHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: NativeWidget(
                    item.nativeAd,
                    key: ValueKey('${item.label}_${item.adId}'),
                    adId: item.adId,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: DemoInstanceBadge(label: item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateLayoutSize(context);

    return Scaffold(
      backgroundColor: DemoColors.background,
      appBar: demoAppBar(widget.title),
      body: Column(
        children: [
          DemoPageHeader(
            title: '原生双实例验证',
            subtitle: 'A 先展示，原生关闭回调带 adId 移除对应 Item',
            primaryText: '加载原生广告 (A/B)',
            onPrimaryTap: _loadTwoNativeAds,
          ),
          if (_nativeAdA != null || _nativeAdB != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  DemoInfoCard(
                    icon: Icons.fingerprint,
                    label: '实例 A ID',
                    value: _nativeAdA?.instanceId ?? '-',
                  ),
                  DemoInfoCard(
                    icon: Icons.fingerprint,
                    label: '实例 B ID',
                    value: _nativeAdB?.instanceId ?? '-',
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: feedList.length + feedAdList.length,
              itemBuilder: (context, index) {
                final adIndex = index ~/ 5;
                final feedIndex = index - adIndex;
                if (index % 5 == 4 && adIndex < feedAdList.length) {
                  return _buildAdCard(feedAdList[adIndex]);
                }
                return DemoFeedTile(
                  index: feedIndex + 1,
                  title: feedList[feedIndex],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
