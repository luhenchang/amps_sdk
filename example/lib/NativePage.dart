import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key, required this.title});

  final String title;

  @override
  State<NativePage> createState() => _SplashPageState();
}

class _SplashPageState extends State<NativePage> {
  late AmpsNativeAdListener _adCallBack;
  late AMPSNativeRenderListener _renderCallBack;
  late AmpsNativeInteractiveListener _interactiveCallBack;
  late AmpsVideoPlayListener _videoPlayerCallBack;
  AMPSNativeAd? _nativeAd;
  List<String> feedList = [];
  List<String> feedAdList = [];
  late double expressWidth = 350;
  late double expressHeight = 128;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add("item name =$i");
    }
    setState(() {});
    _adCallBack = AmpsNativeAdListener(
        loadOk: (adIds) {}, loadFail: (code, message) => {});

    _renderCallBack = AMPSNativeRenderListener(renderSuccess: (adId) {
      setState(() {
        debugPrint("adId renderCallBack=$adId");
        feedAdList.add(adId);
      });
    }, renderFailed: (code, message) {
      debugPrint("渲染失败=$code,$message");
    });

    _interactiveCallBack = AmpsNativeInteractiveListener(onAdShow: (adId) {
      debugPrint("广告展示=$adId");
    }, onAdExposure: (adId) {
      debugPrint("广告曝光=$adId");
    }, onAdClicked: (adId) {
      debugPrint("广告点击=$adId");
    }, toCloseAd: (adId) {
      debugPrint("广告关闭=$adId");
      setState(() {
        feedAdList.remove(adId);
      });
    });
    _videoPlayerCallBack = AmpsVideoPlayListener(onVideoPause: (adId) {
      debugPrint("视频暂停");
    }, onVideoPlayError: (code, message) {
      debugPrint("视频播放错误");
    }, onVideoResume: (adId) {
      debugPrint("视频恢复播放");
    }, onVideoReady: (adId) {
      debugPrint("视频准备就绪");
    }, onVideoPlayStart: (adId) {
      debugPrint("视频开始播放");
    }, onVideoPlayComplete: (adId) {
      debugPrint("视频播放完成");
    });

    AdOptions options = AdOptions(
        spaceId: '15295',
        adCount: 2,
        expressSize: [expressWidth, expressHeight]);
    _nativeAd = AMPSNativeAd(
        config: options,
        mCallBack: _adCallBack,
        mRenderCallBack: _renderCallBack,
        mInteractiveCallBack: _interactiveCallBack,
        mVideoPlayerCallBack: _videoPlayerCallBack);
    _nativeAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
          itemCount: feedList.length + feedAdList.length, // 列表项总数
          itemBuilder: (BuildContext context, int index) {
            int adIndex = index ~/ 5;
            int feedIndex = index - adIndex;
            if (index % 5 == 4 && adIndex < feedAdList.length) {
              String adId = feedAdList[adIndex];
              debugPrint(adId);
              return AMPSBuildNativeView(_nativeAd,
                  key: ValueKey(adId),
                  posId: adId,
                  width: expressWidth,
                  height: expressHeight);
            }
            return Center(
              child: Container(
                height: 128,
                width: 350,
                color: Colors.blueAccent,
                alignment: Alignment.centerLeft,
                child: Text('List item ${feedList[feedIndex]}'),
              ),
            );
          },
        ));
  }
}
