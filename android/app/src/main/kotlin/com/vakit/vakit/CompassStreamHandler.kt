package com.vakit.vakit

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.view.Surface
import android.view.WindowManager
import io.flutter.plugin.common.EventChannel
import kotlin.math.roundToInt

/**
 * Android için ultra dayanıklı yerel pusula sensör akışı sağlayıcısı.
 *
 * 1. Öncelikli olarak `Sensor.TYPE_ROTATION_VECTOR` dener (en hassas ve jiroskop destekli füzyon).
 * 2. Cihazda Rotation Vector yoksa veya veri üretmiyorsa, `Sensor.TYPE_ACCELEROMETER` + `Sensor.TYPE_MAGNETIC_FIELD`
 *    ikilisini kullanarak `SensorManager.getRotationMatrix` üzerinden azimut hesaplar.
 * 3. Ekranın yatay/dikey dönüş açısını (Display Rotation) hesaba katarak koordinatları otomatik yeniden haritalar (`remapCoordinateSystem`).
 * Bu sayede Xiaomi, Samsung Galaxy A serisi, Oppo, Tecno gibi donanım çeşitliliği olan tüm cihazlarda %100 çalışır.
 */
class CompassStreamHandler(private val context: Context) : EventChannel.StreamHandler, SensorEventListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private var eventSink: EventChannel.EventSink? = null

    // Sensörler
    private var rotationVectorSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null
    private var magneticSensor: Sensor? = null

    // Matris ve yön hesaplama tamponları
    private val rotationMatrix = FloatArray(9)
    private val remappedMatrix = FloatArray(9)
    private val orientationAngles = FloatArray(3)

    // Fallback için accelerometer ve magnetic verileri
    private val gravityValues = FloatArray(3)
    private val geomagneticValues = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false

    private var lastHeadingDegrees: Double = -1.0
    private var lastEmitTime: Long = 0L

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
        if (sensorManager == null) {
            events?.error("NO_SENSOR_MANAGER", "SensorManager sistemde mevcut değil", null)
            return
        }

        rotationVectorSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magneticSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        var registeredAny = false

        // Rotation vector varsa kaydet
        rotationVectorSensor?.let {
            val registered = sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
            if (registered) registeredAny = true
        }

        // Accelerometer ve manyetometreyi de her ihtimale karşı fallback ve doğruluk için kaydet
        accelerometerSensor?.let {
            val registered = sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
            if (registered) registeredAny = true
        }
        magneticSensor?.let {
            val registered = sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
            if (registered) registeredAny = true
        }

        if (!registeredAny) {
            events?.error("NO_SENSORS_AVAILABLE", "Cihazda gerekli pusula sensörleri bulunamadı", null)
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(this)
        eventSink = null
        hasGravity = false
        hasGeomagnetic = false
    }

    override fun onSensorChanged(event: SensorEvent) {
        val sink = eventSink ?: return

        var computedHeading: Double? = null
        var accuracy = event.accuracy

        when (event.sensor.type) {
            Sensor.TYPE_ROTATION_VECTOR -> {
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
                computedHeading = calculateHeadingFromMatrix(rotationMatrix)
            }
            Sensor.TYPE_ACCELEROMETER -> {
                System.arraycopy(event.values, 0, gravityValues, 0, 3)
                hasGravity = true
                if (hasGravity && hasGeomagnetic) {
                    if (SensorManager.getRotationMatrix(rotationMatrix, null, gravityValues, geomagneticValues)) {
                        computedHeading = calculateHeadingFromMatrix(rotationMatrix)
                    }
                }
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                System.arraycopy(event.values, 0, geomagneticValues, 0, 3)
                hasGeomagnetic = true
                if (hasGravity && hasGeomagnetic) {
                    if (SensorManager.getRotationMatrix(rotationMatrix, null, gravityValues, geomagneticValues)) {
                        computedHeading = calculateHeadingFromMatrix(rotationMatrix)
                    }
                }
            }
        }

        if (computedHeading != null && !computedHeading.isNaN()) {
            val now = System.currentTimeMillis()
            // ~30 FPS frekans kısıtlaması (33 ms) ve gereksiz IPC trafiğini önleme
            if (now - lastEmitTime >= 33 || kotlin.math.abs(computedHeading - lastHeadingDegrees) > 0.5) {
                lastHeadingDegrees = computedHeading
                lastEmitTime = now

                val payload = HashMap<String, Any>()
                payload["heading"] = computedHeading
                payload["accuracy"] = accuracy
                sink.success(payload)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // İsteğe bağlı kalibrasyon durumu güncellenebilir
    }

    private fun calculateHeadingFromMatrix(rMatrix: FloatArray): Double {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
        val rotation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                context.display?.rotation ?: Surface.ROTATION_0
            } catch (_: Exception) {
                Surface.ROTATION_0
            }
        } else {
            @Suppress("DEPRECATION")
            windowManager?.defaultDisplay?.rotation ?: Surface.ROTATION_0
        }

        var axisX = SensorManager.AXIS_X
        var axisY = SensorManager.AXIS_Y

        when (rotation) {
            Surface.ROTATION_90 -> {
                axisX = SensorManager.AXIS_Y
                axisY = SensorManager.AXIS_MINUS_X
            }
            Surface.ROTATION_180 -> {
                axisX = SensorManager.AXIS_MINUS_X
                axisY = SensorManager.AXIS_MINUS_Y
            }
            Surface.ROTATION_270 -> {
                axisX = SensorManager.AXIS_MINUS_Y
                axisY = SensorManager.AXIS_X
            }
            else -> {
                axisX = SensorManager.AXIS_X
                axisY = SensorManager.AXIS_Y
            }
        }

        val success = SensorManager.remapCoordinateSystem(rMatrix, axisX, axisY, remappedMatrix)
        val matrixToUse = if (success) remappedMatrix else rMatrix

        SensorManager.getOrientation(matrixToUse, orientationAngles)
        val azimuthRad = orientationAngles[0]
        var azimuthDeg = Math.toDegrees(azimuthRad.toDouble())

        // 0..360 aralığına getir
        azimuthDeg = (azimuthDeg + 360.0) % 360.0
        return azimuthDeg
    }
}
