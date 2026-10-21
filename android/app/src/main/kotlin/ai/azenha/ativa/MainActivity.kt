package ai.azenha.ativa

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        HeadingBridge.register(flutterEngine, applicationContext)
    }
}

/**
 * Device attitude for the orienteering compass, from Cosmolabe's bridge.
 * TYPE_ROTATION_VECTOR is the platform's own fusion of gyroscope,
 * accelerometer and magnetometer, already in East-North-Up and referenced to
 * magnetic north, which is what an orienteering map is drawn to.
 */
class HeadingBridge(context: Context) : EventChannel.StreamHandler, SensorEventListener {
    companion object {
        const val CHANNEL = "ativa/heading"
        fun register(engine: FlutterEngine, context: Context) {
            val bridge = HeadingBridge(context)
            val messenger = engine.dartExecutor.binaryMessenger
            EventChannel(messenger, CHANNEL).setStreamHandler(bridge)
            MethodChannel(messenger, "$CHANNEL/control").setMethodCallHandler { call, result ->
                if (call.method == "isAvailable") result.success(bridge.sensor() != null)
                else result.notImplemented()
            }
        }
    }

    private val sm = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private var sink: EventChannel.EventSink? = null
    private val q = FloatArray(4)
    private var accuracy = 180.0

    private fun sensor(): Sensor? =
        sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: sm.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        val s = sensor()
        if (s == null) {
            events?.error("unavailable", "No rotation sensor", null)
            return
        }
        sm.registerListener(this, s, SensorManager.SENSOR_DELAY_GAME)
        sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)?.let {
            sm.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun onCancel(arguments: Any?) {
        sm.unregisterListener(this)
        sink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val out = sink ?: return
        if (event == null) return
        if (event.sensor.type != Sensor.TYPE_ROTATION_VECTOR &&
            event.sensor.type != Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR) return
        SensorManager.getQuaternionFromVector(q, event.values)
        out.success(mapOf(
            "w" to q[0].toDouble(), "x" to q[1].toDouble(),
            "y" to q[2].toDouble(), "z" to q[3].toDouble(),
            "accuracy" to accuracy,
        ))
    }

    override fun onAccuracyChanged(sensor: Sensor?, acc: Int) {
        if (sensor?.type != Sensor.TYPE_MAGNETIC_FIELD) return
        accuracy = when (acc) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 5.0
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 15.0
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 35.0
            else -> 180.0
        }
    }
}
