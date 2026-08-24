package com.mirame.mirame

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Plugin propio y no un paquete de pub: ninguno del ecosistema
        // implementa el camino de instalacion silenciosa de Android 12+.
        flutterEngine.plugins.add(MirameUpdater())
    }
}
