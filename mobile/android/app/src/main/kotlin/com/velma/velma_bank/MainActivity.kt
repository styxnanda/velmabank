package com.velma.velma_bank

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Bundle
import android.os.Debug
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel
    private var pendingLocation: MethodChannel.Result? = null
    private var locationListener: LocationListener? = null
    private val handler = Handler(Looper.getMainLooper())
    private var locationTimeout: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.velma.bank/lab")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "diagnostics" -> result.success(diagnostics())
                "secureWindow" -> {
                    if (call.arguments == true) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "location" -> {
                    if (pendingLocation != null) result.error("BUSY", "Location request in progress", null)
                    else {
                        pendingLocation = result
                        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                            requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), 401)
                        } else readLocation()
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun diagnostics(): Map<String, Any?> {
        val cm = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.getNetworkCapabilities(cm.activeNetwork)
        val signatures = if (Build.VERSION.SDK_INT >= 28) packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo?.apkContentsSigners
            else packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES).signatures
        return mapOf(
            "package" to packageName, "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL, "androidApi" to Build.VERSION.SDK_INT,
            "abis" to Build.SUPPORTED_ABIS.toList(),
            "debuggable" to (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0),
            "debuggerAttached" to Debug.isDebuggerConnected(),
            "developerOptionsEnabled" to (Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1),
            "adbEnabled" to (Settings.Global.getInt(contentResolver, Settings.Global.ADB_ENABLED, 0) == 1),
            "vpnTransport" to (network?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true),
            "httpProxy" to cm.defaultProxy?.toString(),
            "defaultKeyboard" to Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD),
            "signerSha256" to signatures?.map { signature -> MessageDigest.getInstance("SHA-256").digest(signature.toByteArray()).joinToString("") { "%02x".format(it) } },
            "raspIntegrated" to false
        )
    }

    @Suppress("DEPRECATION", "MissingPermission")
    private fun readLocation() {
        val manager = getSystemService(LOCATION_SERVICE) as LocationManager
        val providers = manager.getProviders(true).filter { it == LocationManager.GPS_PROVIDER || it == LocationManager.NETWORK_PROVIDER }
        if (providers.isEmpty()) { finishLocation(mapOf("status" to "Enable device location, then retry")); return }
        val listener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                finishLocation(mapOf("latitude" to location.latitude, "longitude" to location.longitude,
                    "isMock" to if (Build.VERSION.SDK_INT >= 31) location.isMock else location.isFromMockProvider,
                    "provider" to location.provider, "fixTimeMs" to location.time,
                    "policy" to "Observation only; SDK enforces mock-location policy"))
            }
            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {}
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }
        locationListener = listener
        try {
            for (provider in providers) manager.requestLocationUpdates(provider, 0L, 0f, listener, Looper.getMainLooper())
            val timeout = Runnable { finishLocation(mapOf("status" to "No fresh fix within 12 seconds. Configure emulator location or a mock provider and retry.")) }
            locationTimeout = timeout
            handler.postDelayed(timeout, 12000)
        } catch (e: SecurityException) { finishLocation(mapOf("status" to "Location permission is required")) }
    }

    private fun finishLocation(value: Map<String, Any?>) {
        locationListener?.let { (getSystemService(LOCATION_SERVICE) as LocationManager).removeUpdates(it) }
        locationListener = null
        locationTimeout?.let { handler.removeCallbacks(it) }
        locationTimeout = null
        pendingLocation?.success(value)
        pendingLocation = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 401) {
            if (grantResults.any { it == PackageManager.PERMISSION_GRANTED }) readLocation()
            else finishLocation(mapOf("status" to "Permission denied"))
        }
    }

    override fun onDestroy() {
        finishLocation(mapOf("status" to "Activity closed"))
        super.onDestroy()
    }

    // Future vendor callback adapter. Call only with sanitized, non-secret evidence.
    fun publishRaspEvent(category: String, action: String, detail: String) {
        runOnUiThread { channel.invokeMethod("raspEvent", mapOf("category" to category, "action" to action, "detail" to detail)) }
    }
}
