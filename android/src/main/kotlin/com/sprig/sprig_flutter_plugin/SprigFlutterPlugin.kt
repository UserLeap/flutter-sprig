package com.sprig.sprig_flutter_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

import com.userleap.Sprig
import com.userleap.EventPayload
import com.userleap.EventListener
import com.userleap.EventName
import com.userleap.SurveyState
import com.userleap.SprigSurveyResult
import com.userleap.SprigUserInterfaceMode

import android.app.Activity
import android.util.Log
import android.os.Handler
import android.os.Looper
import org.json.JSONObject
import org.json.JSONArray

/** SprigFlutterPlugin */
class SprigFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val TAG = "SprigLogger"
    private var activity: Activity? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    
    // Store registered event listeners
    private val eventListeners = mutableMapOf<EventName, EventListener>()
    
    // EventChannel sink for sending events to Flutter
    private var eventSink: EventChannel.EventSink? = null

    // Map of method names to their handler functions
    private val methodHandlers: Map<String, (MethodCall, Result) -> Unit> = mapOf(
        "getPlatformVersion" to ::handleGetPlatformVersion,
        "sdkVersion" to ::handleSdkVersion,
        "visitorIdentifierString" to ::handleVisitorIdentifierString,
        "configure" to ::handleConfigure,
        "presentSurvey" to ::handlePresentSurvey,
        "present" to ::handlePresent,
        "setPreviewKey" to ::handleSetPreviewKey,
        "registerEventListener" to ::handleRegisterEventListener,
        "setEmailAddress" to ::handleSetEmailAddress,
        "setVisitorAttribute" to ::handleSetVisitorAttribute,
        "setVisitorAttributesAndIdentify" to ::handleSetVisitorAttributesAndIdentify,
        "removeVisitorAttributes" to ::handleRemoveVisitorAttributes,
        "setUserIdentifier" to ::handleSetUserIdentifier,
        "logout" to ::handleLogout,
        "trackAndPresent" to ::handleTrackAndPresent,
        "trackIdentifyAndPresent" to ::handleTrackIdentifyAndPresent,
        "track" to ::handleTrack,
        "trackWithProperties" to ::handleTrackWithProperties,
        "trackAndIdentify" to ::handleTrackAndIdentify,
        "dismissActiveSurvey" to ::handleDismissActiveSurvey,
        "pauseDisplayingSurveys" to ::handlePauseDisplayingSurveys,
        "unpauseDisplayingSurveys" to ::handleUnpauseDisplayingSurveys,
        "overrideUserInterfaceMode" to ::handleOverrideUserInterfaceMode
    )

    /**
     * Convert Flutter's camelCase event names to UPPER_SNAKE_CASE for EventName enum
     * Examples: "sdkReady" -> "SDK_READY", "surveyWillPresent" -> "SURVEY_WILL_PRESENT"
     */
    private fun convertFlutterEventName(camelCase: String): EventName? {
        val snakeCase = camelCase.replace(Regex("(?<=[a-z])(?=[A-Z])"), "_").uppercase()
        return normalizedEventNameOf(snakeCase)
    }

    /**
    * Normalizes the lifecycle event name if needed, from any version of the names that may be used
    * by the Web SDK or other sources that don't match what the native SDK uses for those names.
    */
    private fun normalizedEventNameOf(name: String): EventName? =
    runCatching {
        enumValueOf<EventName>(when (name) {
            "SET_HEIGHT" -> "SURVEY_HEIGHT"
            else -> name
        })
    }.getOrNull()

    /**
     * Convert UPPER_SNAKE_CASE to camelCase for Flutter
     * Examples: "SDK_READY" -> "sdkReady", "SURVEY_WILL_PRESENT" -> "surveyWillPresent"
     */
    private fun convertToFlutterEventName(snakeCase: String): String {
        val parts = snakeCase.split('_')
        if (parts.isEmpty()) return snakeCase.lowercase()
        
        return parts.mapIndexed { index, part ->
            if (index == 0) {
                part.lowercase()
            } else {
                part.lowercase().replaceFirstChar { it.uppercase() }
            }
        }.joinToString("")
    }

    /**
     * Convert any JSON value to a Flutter-compatible type
     */
    private fun convertJsonValue(value: Any?): Any? {
        return when (value) {
            is JSONObject -> jsonToMap(value)
            is JSONArray -> jsonArrayToList(value)
            JSONObject.NULL -> null
            else -> value
        }
    }

    /**
     * Convert JSONArray to a List that Flutter can understand
     */
    private fun jsonArrayToList(jsonArray: JSONArray): List<Any?> {
        val list = mutableListOf<Any?>()
        for (i in 0 until jsonArray.length()) {
            list.add(convertJsonValue(jsonArray.get(i)))
        }
        return list
    }

    /**
     * Convert JSONObject to a Map that Flutter can understand
     */
    private fun jsonToMap(json: JSONObject?): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        json?.let {
            it.keys().forEach { key ->
                map[key] = convertJsonValue(it.get(key))
            }
        }
        return map
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "sprig_flutter_plugin")
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "sprig_flutter_plugin/events")
        eventChannel.setStreamHandler(this)
        
        Log.d(TAG, "Plugin attached to engine")
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "EventChannel listener attached")
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "EventChannel listener cancelled")
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method called: ${call.method} - ${call.arguments ?: "{}"}")
        val handler = methodHandlers[call.method]
        if (handler != null) {
            handler(call, result)
        } else {
            result.notImplemented()
        }
    }

    // ActivityAware implementation
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "Activity attached")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        Log.d(TAG, "Activity detached for config changes")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(TAG, "Activity reattached for config changes")
    }

    override fun onDetachedFromActivity() {
        activity = null
        Log.d(TAG, "Activity detached")
    }

    @Suppress("UNUSED_PARAMETER")
    private fun handleGetPlatformVersion(call: MethodCall, result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    @Suppress("UNUSED_PARAMETER")
    private fun handleSdkVersion(call: MethodCall, result: Result) {
        result.success(Sprig.sdkVersion)
    }

    @Suppress("UNUSED_PARAMETER")
    private fun handleVisitorIdentifierString(call: MethodCall, result: Result) {
        result.success(Sprig.visitorIdentifierString)
    }

    private fun handleConfigure(call: MethodCall, result: Result) {
        val environment = call.argument<String>("environment")
        
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }
        
        if (environment == null) {
            result.error("INVALID_ARGS", "Environment is required", null)
            return
        }
        
        activity?.let { act -> 
            Sprig.configure(act, environment, call.argument<Map<String, String>>("configuration"), null)
        }
        
        result.success(null)
    }

    private fun handlePresentSurvey(call: MethodCall, result: Result) {
        call.argument<Int>("surveyId")?.let {
            Sprig.presentSurveyWithId(it.toString())
        }
        result.success(null)
    }

    @Suppress("UNUSED_PARAMETER")
    private fun handlePresent(call: MethodCall, result: Result) {
        activity?.let { 
            Sprig.presentSurvey(it)
        }
        result.success(null)
    }

    private fun handleSetPreviewKey(call: MethodCall, result: Result) {
        call.argument<String>("previewKey")?.let {
            Sprig.setPreviewKey(it)
        }
        result.success(null)
    }

    private fun handleRegisterEventListener(call: MethodCall, result: Result) {
        val eventType = call.argument<String>("eventType")
        
        if (eventType == null) {
            Log.e(TAG, "Event listener registration failed: Event type is required")
            result.error("INVALID_ARGS", "Event type is required", null)
            return
        }
        
        Log.d(TAG, "Attempting to register event listener for: $eventType")
        
        // Convert the Flutter camelCase event type to EventName enum
        val eventName = convertFlutterEventName(eventType)
        if (eventName == null) {
            Log.e(TAG, "Event listener registration failed: Unknown event type: $eventType")
            result.error("INVALID_EVENT_TYPE", "Unknown event type: $eventType", null)
            return
        }
        
        // Remove any existing listener for this event type
        eventListeners[eventName]?.let { oldListener ->
            Log.d(TAG, "Removing existing listener for event: ${eventName.value}")
            Sprig.removeEventListener(eventName, oldListener)
        }
        
        // Create a listener that forwards events to Flutter via EventChannel
        val listener = EventListener { event ->
            Log.d(TAG, "Native event received: ${event.name.name}, data: ${event.data?.toString() ?: "null"}")
            
            // Convert the event name back to camelCase for Flutter
            val flutterEventName = convertToFlutterEventName(event.name.name)
            
            // Prepare the event data to send to Flutter
            var eventData = mutableMapOf<String, Any?>(
                "eventType" to flutterEventName
            )
            
            // Parse and include the JSON data fields
            event.data?.let { jsonData ->
                val dataMap = jsonToMap(jsonData)
                eventData.putAll(dataMap)
            }

            // Normalize the difference between how Android and iOS package the message for logging events
            if (eventData["eventType"] == "loggingEvent") {
                eventData["message"] = eventData["log.message"]
                eventData.remove("log.message")
            }

            Log.d(TAG, "Prepared event data for Flutter: $eventData")
            
            // Send the event through EventChannel
            mainHandler.post {
                try {
                    eventSink?.let { sink ->
                        Log.d(TAG, "Sending event through EventChannel: $flutterEventName")
                        sink.success(eventData)
                        Log.d(TAG, "Event successfully sent to Flutter: $flutterEventName")
                    } ?: run {
                        Log.w(TAG, "EventSink is null, cannot send event: $flutterEventName")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending event to Flutter: ${e.message}", e)
                }
            }
        }
        
        // Store and register the listener
        eventListeners[eventName] = listener
        Sprig.addEventListener(eventName, listener)
        
        Log.d(TAG, "Event listener registered successfully for: ${eventName.value} (total listeners: ${eventListeners.size})")
        result.success(null)
    }

    private fun handleSetEmailAddress(call: MethodCall, result: Result) {
        call.argument<String>("emailAddress")?.let {
            Sprig.setEmailAddress(it)
        }
        result.success(null)
    }

    private fun handleSetVisitorAttribute(call: MethodCall, result: Result) {
        call.argument<String>("key")?.let { key  ->
            call.argument<String>("value")?.let { value  ->
                Sprig.setVisitorAttribute(key, value)
            }
        }
        result.success(null)
    }

    private fun handleSetVisitorAttributesAndIdentify(call: MethodCall, result: Result) {
        call.argument<Map<String, String>>("attributes")?.let { attributes  ->
            val userId = call.argument<String>("userId")
            val partnerAnonymousId = call.argument<String?>("partnerAnonymousId")
            Sprig.setVisitorAttributes(attributes, userId, partnerAnonymousId)
        }
        result.success(null)
    }

    private fun handleRemoveVisitorAttributes(call: MethodCall, result: Result) {
        call.argument<List<String>>("attributes")?.let {
            Sprig.removeVisitorAttributes(it)
        }
        result.success(null)
    }

    private fun handleSetUserIdentifier(call: MethodCall, result: Result) {
        call.argument<String>("identifier")?.let { identifier  ->
            Sprig.setUserIdentifier(identifier)
        }
        result.success(null)
    }

    @Suppress("UNUSED_PARAMETER")
    private fun handleLogout(call: MethodCall, result: Result) {
        Sprig.logout()
        result.success(null)
    }

    private fun handleTrackAndPresent(call: MethodCall, result: Result) {
        call.argument<String>("eventName")?.let { eventName  ->
            activity?.let { activity -> 
                Sprig.trackAndPresent(EventPayload(eventName), activity)
            }
        }
        result.success(null)
    }

    private fun handleTrackIdentifyAndPresent(call: MethodCall, result: Result) {
        val eventName = call.argument<String>("eventName")
        val userId = call.argument<String?>("userId")
        val partnerAnonymousId = call.argument<String?>("partnerAnonymousId")
        activity?.let { activity -> 
            eventName?.let { eventName -> 
                userId?.let { userId -> 
                    partnerAnonymousId?.let { partnerAnonymousId -> 
                        val payload = EventPayload(eventName, userId, partnerAnonymousId)
                        Sprig.trackAndPresent(payload, activity)
                    }
                }
            }
        }
        result.success(null)
    }

    private fun handleTrack(call: MethodCall, result: Result) {
        call.argument<String>("eventName")?.let {
           val resultCallback = { surveyResult: SprigSurveyResult ->
                mainHandler.post {
                    result.success(mapOf(
                        "surveyState" to surveyResult.surveyState.ordinal,
                        "surveyId" to (surveyResult.surveyId ?: 0)
                    ))
                }
                Unit
            }
            Sprig.track(EventPayload(event = it, resultCallback = resultCallback))
        } ?: mainHandler.post {
            result.success(mapOf("surveyState" to SurveyState.NO_SURVEY.ordinal, "surveyId" to null))
        }
    }

    private fun handleTrackWithProperties(call: MethodCall, result: Result) {
        val eventName = call.argument<String>("eventName")
        val userId = call.argument<String?>("userId")
        val partnerAnonymousId = call.argument<String?>("partnerAnonymousId")
        val properties = call.argument<Map<String, Any>>("properties")
        eventName?.let { eventName -> 
            properties?.let { properties -> 
                val payload = EventPayload(eventName, userId, partnerAnonymousId, properties)
                Sprig.track(payload)
            }
        }
        result.success(0)
    }

    private fun handleTrackAndIdentify(call: MethodCall, result: Result) {
        val eventName = call.argument<String>("eventName")
        val userId = call.argument<String>("userId")
        val partnerAnonymousId = call.argument<String>("partnerAnonymousId")
        eventName?.let { eventName -> 
            userId?.let { userId -> 
                partnerAnonymousId?.let { partnerAnonymousId -> 
                    val payload = EventPayload(eventName, userId, partnerAnonymousId)
                    Sprig.track(payload)
                }
            }
        }
        result.success(0)
    }

    private fun handleDismissActiveSurvey(call: MethodCall, result: Result) {
        Sprig.dismissActiveSurvey()
        result.success(0)
    }

    private fun handlePauseDisplayingSurveys(call: MethodCall, result: Result) {
        Sprig.pauseDisplayingSurveys()
        result.success(0)
    }

    private fun handleUnpauseDisplayingSurveys(call: MethodCall, result: Result) {
        Sprig.unpauseDisplayingSurveys()
        result.success(0)
    }

    private fun handleOverrideUserInterfaceMode(call: MethodCall, result: Result) {
        val modeIndex = call.argument<Int>("mode")
        if (modeIndex == null) {
            result.error("MISSING_ARGUMENT", "Missing mode parameter for overrideUserInterfaceMode", null)
            return
        }
        val mode = SprigUserInterfaceMode.values().firstOrNull { it.value == modeIndex }
        if (mode == null) {
            result.error("INVALID_ARGUMENT", "Invalid mode value: $modeIndex", null)
            return
        }
        Sprig.overrideUserInterfaceMode(mode)
        result.success(null)
    }

    override fun onDetachedFromEngine(_binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Detaching from engine, cleaning up ${eventListeners.size} event listeners")
        
        // Clean up all registered listeners
        eventListeners.forEach { (eventName, listener) ->
            Log.d(TAG, "Removing event listener for: ${eventName.value}")
            Sprig.removeEventListener(eventName, listener)
        }
        eventListeners.clear()
        
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        
        Log.d(TAG, "All event listeners cleaned up")
    }
}