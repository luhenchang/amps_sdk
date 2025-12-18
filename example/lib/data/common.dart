
import 'dart:io';

var appId = Platform.isIOS ? "12391" : "12379";
var splashSpaceId = Platform.isIOS ? '15285' : "15288";
var interstitialSpaceId = Platform.isIOS ? '111499' : "111502";
var nativeSpaceId = Platform.isIOS ? '15292' : "15295";
var unifiedSpaceId = Platform.isIOS ? '124302' : "124302";
var timeOut = 5000;//广告请求超时时长，建议5000毫秒,该参数单位为ms