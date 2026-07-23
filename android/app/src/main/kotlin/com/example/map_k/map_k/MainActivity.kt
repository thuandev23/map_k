package com.example.map_k.map_k

import android.Manifest
import androidx.annotation.RequiresPermission
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mapk/location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCurrentLocation" -> getCurrentLocation(result)
                    else -> result.notImplemented()
                }
            }
    }

    @RequiresPermission(allOf = [Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION])
    private fun getCurrentLocation(result: MethodChannel.Result) {
        try {
            val fusedClient = LocationServices.getFusedLocationProviderClient(this)
            fusedClient.lastLocation.addOnSuccessListener { location ->
                if (location != null) {
                    result.success(mapOf("lat" to location.latitude, "lng" to location.longitude))
                } else {
                    result.success(mapOf("lat" to 10.776889, "lng" to 106.700806))
                }
            }.addOnFailureListener {
                result.success(mapOf("lat" to 10.776889, "lng" to 106.700806))
            }
        } catch (e: Exception) {
            result.success(mapOf("lat" to 10.776889, "lng" to 106.700806))
        }
    }
}
