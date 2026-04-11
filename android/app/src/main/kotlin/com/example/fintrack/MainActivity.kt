package com.example.fintrack

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onResume() {
        super.onResume()
        crearCanalNotificaciones()
    }

    private fun crearCanalNotificaciones() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "Notificaciones FinTrack",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones de ingresos y gastos"
                enableLights(true)
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}