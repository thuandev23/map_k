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

    private fun getCurrentLocation(result: MethodChannel.Result) {
        try {
            val fusedClient = LocationServices.getFusedLocationProviderClient(this)
            fusedClient.lastLocation.addOnSuccessListener { location ->
                if (location != null) {
                    result.success(mapOf("lat" to location.latitude, "lng" to location.longitude))
                } else {
                    result.error("NO_LOCATION", "Location unavailable", null)
                }
            }.addOnFailureListener { exception ->
                result.error("LOCATION_ERROR", exception.message ?: "Failed to get location", null)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Location permission missing", e.message)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, null)
        }
    }
}
