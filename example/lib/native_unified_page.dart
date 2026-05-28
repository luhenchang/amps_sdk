import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk/common.dart';
import 'package:amps_sdk/widget/native_unified_widget.dart';
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

class NativeUnifiedPage extends StatefulWidget {
  const NativeUnifiedPage({super.key, required this.title});

  final String title;

  @override
  State<NativeUnifiedPage> createState() => _NativeUnifiedPageState();
}

class _NativeUnifiedPageState extends State<NativeUnifiedPage> {
  AMPSNativeAd? _nativeAdA;
  AMPSNativeAd? _nativeAdB;
  late AMPSUnifiedDownloadListener _downloadListener;

  final List<String> feedList = [];
  final List<_FeedAdItem> feedAdList = [];

  double _cardWidth = 350;
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
    _downloadListener = AMPSUnifiedDownloadListener(
      onDownloadProgressUpdate: (position, adId) =>
          debugPrint('[UnifiedMulti] 下载进度=$position adId=$adId'),
      onDownloadFailed: (adId) {},
      onDownloadPaused: (position, adId) {},
      onDownloadFinished: (adId) {},
      onDownloadStarted: (adId) {},
      onInstalled: (adId) {},
    );
  }

  void _updateLayoutSize(BuildContext context) {
    _cardWidth = MediaQuery.of(context).size.width - 32;
    _adHeight = (_cardWidth * 0.36).clamp(120.0, 180.0);
  }

  NativeUnifiedWidget _buildUnifiedContent() {
    return NativeUnifiedWidget(
      height: _adHeight,
      backgroundColor: '#F0EDF4',
      children: [
        UnifiedMainImgWidget(
          width: _cardWidth - 40,
          height: _adHeight - 40,
          x: 20,
          y: 20,
          backgroundColor: '#FFFFFF',
          clickType: AMPSAdItemClickType.click,
        ),
        UnifiedTitleWidget(
          fontSize: 16,
          color: '#FFFFFF',
          x: 5,
          y: 5,
          clickType: AMPSAdItemClickType.click,
        ),
        UnifiedDescWidget(
          fontSize: 16,
          width: 200,
          color: '#FFFFFF',
          x: 5,
          y: 30,
        ),
        UnifiedActionButtonWidget(
          fontSize: 12,
          width: 50,
          height: 20,
          fontColor: '#FF00FF',
          backgroundColor: '#FFFF33',
          x: 280,
          y: 100,
        ),
        UnifiedAppIconWidget(width: 25, height: 25, x: 320, y: 100),
        DownLoadWidget(
          width: 200,
          x: 22,
          y: 60,
          fontSize: 11,
          fontColor: '#0000FF',
          content:
              '应用名称：${AppDetail.appName} | 开发者：${AppDetail.appDeveloper}',
          downloadListener: _downloadListener,
        ),
        UnifiedVideoWidget(width: 100, height: 0, x: 200, y: 0),
        UnifiedCloseWidget(
          imagePath: 'assets/images/close.png',
          width: 16,
          height: 16,
          x: 330,
          y: 5,
        ),
      ],
    );
  }

  AMPSNativeAd _createNativeAd(String label) {
    return AMPSNativeAd(
      config: AdOptions(
        spaceId: unifiedSpaceId,
        adCount: 1,
        expressSize: [_cardWidth, _adHeight],
      ),
      nativeType: NativeType.unified,
      mCallBack: AmpsNativeAdListener(
        loadOk: (adIds) => debugPrint(
            '[UnifiedMulti] $label loadOk adIds=$adIds'),
        loadFail: (code, message) {
          debugPrint('[UnifiedMulti] $label loadFail code=$code');
          if (label == 'A') _tryShowB();
        },
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (adId) {
          debugPrint('[UnifiedMulti] $label renderSuccess adId=$adId');
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
            debugPrint('[UnifiedMulti] $label renderFailed'),
      ),
      mInteractiveCallBack: AmpsNativeInteractiveListener(
        onAdShow: (adId) => debugPrint('[UnifiedMulti] $label onAdShow'),
        onAdExposure: (adId) => debugPrint('[UnifiedMulti] $label onAdExposure'),
        onAdClicked: (adId) => debugPrint('[UnifiedMulti] $label onAdClicked'),
        toCloseAd: (adId) {
          if (adId != null) _handleAdClosed(adId, isInstanceA: label == 'A');
        },
      ),
    );
  }

  void _handleAdClosed(String adId, {required bool isInstanceA}) {
    debugPrint('[UnifiedMulti] ${isInstanceA ? 'A' : 'B'} close adId=$adId');
    if (!mounted) return;
    if (!feedAdList.any((item) => item.adId == adId)) return;
    setState(() => feedAdList.removeWhere((item) => item.adId == adId));
    if (isInstanceA) {
      _pendingShowBAfterAClosed = true;
      _tryShowB();
    }
  }

  void _loadTwoUnifiedAds() {
    if (_cardWidth <= 0) return;

    _isBLoaded = false;
    _bAdId = null;
    _isShowingB = false;
    _pendingShowBAfterAClosed = false;
    setState(() => feedAdList.clear());

    _nativeAdA = _createNativeAd('A');
    _nativeAdB = _createNativeAd('B');

    debugPrint('[UnifiedMulti] A instanceId=${_nativeAdA!.instanceId}');
    debugPrint('[UnifiedMulti] B instanceId=${_nativeAdB!.instanceId}');

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
                  child: UnifiedWidget(
                    item.nativeAd,
                    key: ValueKey('${item.label}_${item.adId}'),
                    adId: item.adId,
                    unifiedContent: _buildUnifiedContent(),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: DemoInstanceBadge(label: item.label),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleAdClosed(
                        item.adId,
                        isInstanceA: item.label == 'A',
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
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
            title: '自渲染双实例验证',
            subtitle: 'A 先展示，关闭后自动展示 B；右上角为 Flutter 兜底关闭',
            primaryText: '加载自渲染 (A/B)',
            onPrimaryTap: _loadTwoUnifiedAds,
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
