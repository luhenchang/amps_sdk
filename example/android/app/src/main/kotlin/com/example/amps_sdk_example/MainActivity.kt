package com.example.amps_sdk_example

import androidx.core.view.WindowCompat
import com.example.amps_sdk.AMPSSplashViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("biz.beizi.adn/splash_view_id", AMPSSplashViewFactory(this))
    }
}