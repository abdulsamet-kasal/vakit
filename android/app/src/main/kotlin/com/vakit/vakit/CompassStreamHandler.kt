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

/**
 * Android için çok katmanlı, donanım bağımsız pusula sensör motoru.
 *
 * 1. Katman: `Sensor.TYPE_ROTATION_VECTOR` (Jiroskoplu cihazlarda en pürüzsüz füzyon).
 * 2. Katman: `Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR` (Jiroskopsuz Samsung Galaxy A / Xiaomi Redmi serisi).
 * 3. Katman: `Sensor.TYPE_ORIENTATION` (Tüm Android sürümlerinde doğrudan donanımsal azimut).
 * 4. Katman: `Sensor.TYPE_ACCELEROMETER` + `Sensor.TYPE_MAGNETIC_FIELD` (Klasik matris füzyonu).
 */
@Suppress("DEPRECATION")
class CompassStreamHandler(private val context: Context) : EventChannel.StreamHandler, SensorEventListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private var eventSink: EventChannel.EventSink? = null

    // Sensör referansları
    private var rotationVectorSensor: Sensor? = null
    private var geomagneticVectorSensor: Sensor? = null
    private var legacyOrientationSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null
    private var magneticSensor: Sensor? = null

    // Matris tamponları
    private val rotationMatrix = FloatArray(9)
    private val remappedMatrix = FloatArray(9)
    private val orientationAngles = FloatArray(3)

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
        geomagneticVectorSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
        legacyOrientationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ORIENTATION)
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magneticSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        var registeredCount = 0

        rotationVectorSensor?.let {
            if (sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)) registeredCount++
        }
        geomagneticVectorSensor?.let {
            if (sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)) registeredCount++
        }
        legacyOrientationSensor?.let {
            if (sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)) registeredCount++
        }
        accelerometerSensor?.let {
            if (sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)) registeredCount++
        }
        magneticSensor?.let {
            if (sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)) registeredCount++
        }

        if (registeredCount == 0) {
            events?.error("NO_SENSORS", "Cihazda pusula sensörü bulunamadı", null)
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
        val accuracy = event.accuracy

        when (event.sensor.type) {
            Sensor.TYPE_ROTATION_VECTOR, Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR -> {
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
                computedHeading = calculateHeadingFromMatrix(rotationMatrix)
            }
            Sensor.TYPE_ORIENTATION -> {
                // event.values[0] doğrudan manyetik kuzeye göre azimut açısıdır (0..360)
                var rawAzimuth = event.values[0].toDouble()
                val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
                val rotation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    try { context.display?.rotation ?: Surface.ROTATION_0 } catch (_: Exception) { Surface.ROTATION_0 }
                } else {
                    windowManager?.defaultDisplay?.rotation ?: Surface.ROTATION_0
                }
                when (rotation) {
                    Surface.ROTATION_90 -> rawAzimuth += 90.0
                    Surface.ROTATION_180 -> rawAzimuth += 180.0
                    Surface.ROTATION_270 -> rawAzimuth += 270.0
                }
                computedHeading = (rawAzimuth + 360.0) % 360.0
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
            // 30 FPS hızında akıcı bildirim (33 ms)
            if (now - lastEmitTime >= 33 || kotlin.math.abs(computedHeading - lastHeadingDegrees) > 0.4) {
                lastHeadingDegrees = computedHeading
                lastEmitTime = now

                val payload = HashMap<String, Any>()
                payload["heading"] = computedHeading
                payload["accuracy"] = accuracy
                sink.success(payload)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun calculateHeadingFromMatrix(rMatrix: FloatArray): Double {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
        val rotation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                context.display?.rotation ?: Surface.ROTATION_0
            } catch (_: Exception) {
                Surface.ROTATION_0
            }
        } else {
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

        azimuthDeg = (azimuthDeg + 360.0) % 360.0
        return azimuthDeg
    }
}
