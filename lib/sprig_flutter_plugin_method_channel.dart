import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sprig_flutter_plugin_platform_interface.dart';
import 'package:sprig_flutter_plugin/sprig_types.dart';

/// An implementation of [SprigFlutterPluginPlatform] that uses method channels.
class MethodChannelSprigFlutterPlugin extends SprigFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sprig_flutter_plugin');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('sprig_flutter_plugin/events');

  final Map<SprigLifecycleEvent, List<Function(Map<Object?, Object?>)>>
  _eventCallbacks = {};
  StreamSubscription? _eventSubscription;
  bool _isListening = false;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String?> sdkVersion() async {
    final sdkVersion = await methodChannel.invokeMethod<String>('sdkVersion');
    return sdkVersion;
  }

  @override
  Future<String?> visitorIdentifierString() async {
    final visitorIdentifierString = await methodChannel.invokeMethod<String>(
      'visitorIdentifierString',
    );
    return visitorIdentifierString;
  }

  @override
  Future<void> configure({
    required String environment,
    Map<String, String>? configuration,
  }) async {
    await methodChannel.invokeMethod<void>('configure', {
      'environment': environment,
      'configuration': configuration,
    });
  }

  @override
  Future<void> presentSurvey({required int surveyId}) async {
    await methodChannel.invokeMethod<void>('presentSurvey', {
      'surveyId': surveyId,
    });
  }

  @override
  Future<void> present() async {
    await methodChannel.invokeMethod<void>('present');
  }

  @override
  Future<void> setPreviewKey({required String previewKey}) async {
    await methodChannel.invokeMethod<void>('setPreviewKey', {
      'previewKey': previewKey,
    });
  }

  @override
  @override
  Future<void> registerEventListener({
    required SprigLifecycleEvent eventType,
    required Function(Map<Object?, Object?>) onCompletion,
  }) async {
    _eventCallbacks.putIfAbsent(eventType, () => []).add(onCompletion);
    if (!_isListening) {
      _startListening();
    }
    try {
      await methodChannel.invokeMethod('registerEventListener', {
        'eventType': eventType.value,
      });
    } catch (e) {
      debugPrint('Failed to register event listener in native SDK: $e');
    }
  }

  void _startListening() {
    _isListening = true;

    _eventSubscription = eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final eventType = event['eventType'] as String?;
          if (eventType != null) {
            final sprigEvent = _eventTypeFromString(eventType);
            final callbacks = _eventCallbacks[sprigEvent];

            if (callbacks != null && callbacks.isNotEmpty) {
              final eventData = <Object?, Object?>{
                'type': sprigEvent.value,
                'eventType': eventType,
              };
              event.forEach((key, value) {
                eventData[key.toString()] = value;
              });
              for (var callback in callbacks) {
                try {
                  callback(eventData);
                } catch (e) {
                  debugPrint('Error in event callback: $e');
                }
              }
            }
          }
        }
      },
      onError: (error) {
        debugPrint('Error in Sprig event stream: $error');
      },
    );
  }

  SprigLifecycleEvent _eventTypeFromString(String eventType) {
    return SprigLifecycleEvent.values.firstWhere(
      (e) => e.value == eventType,
      orElse: () => SprigLifecycleEvent.none,
    );
  }

  @override
  Future<void> setEmailAddress({required String emailAddress}) async {
    await methodChannel.invokeMethod<void>('setEmailAddress', {
      'emailAddress': emailAddress,
    });
  }

  @override
  Future<void> setVisitorAttribute({
    required String key,
    required String value,
  }) async {
    await methodChannel.invokeMethod<void>('setVisitorAttribute', {
      'key': key,
      'value': value,
    });
  }

  @override
  Future<void> setVisitorAttributesAndIdentify({
    required Map<String, String> attributes,
    required String userId,
    String? partnerAnonymousId,
  }) async {
    await methodChannel.invokeMethod<void>('setVisitorAttributesAndIdentify', {
      'attributes': attributes,
      'userId': userId,
      'partnerAnonymousId': partnerAnonymousId,
    });
  }

  @override
  Future<void> removeVisitorAttributes({
    required List<String> attributes,
  }) async {
    await methodChannel.invokeMethod<void>('removeVisitorAttributes', {
      'attributes': attributes,
    });
  }

  @override
  Future<void> setUserIdentifier({required String identifier}) async {
    await methodChannel.invokeMethod<void>('setUserIdentifier', {
      'identifier': identifier,
    });
  }

  @override
  Future<void> logout() async {
    await methodChannel.invokeMethod<void>('logout');
  }

  @override
  Future<void> trackAndPresent({required String eventName}) async {
    await methodChannel.invokeMethod<void>('trackAndPresent', {
      'eventName': eventName,
    });
  }

  @override
  Future<void> trackIdentifyAndPresent({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
  }) async {
    await methodChannel.invokeMethod<void>('trackIdentifyAndPresent', {
      'eventName': eventName,
      'userId': userId,
      'partnerAnonymousId': partnerAnonymousId,
    });
  }

  @override
  Future<void> track({
    required String eventName,
    required Function(SprigSurveyState) onCompletion,
  }) async {
    try {
      final int result = await methodChannel.invokeMethod('track', {
        'eventName': eventName,
      });
      onCompletion(SprigSurveyState.fromRawValue(result));
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke iOS method: '${e.message}'.");
    }
  }

  @override
  Future<void> trackWithProperties({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
    required Map<String, dynamic> properties,
    required Function(SprigSurveyState) onCompletion,
  }) async {
    try {
      final int result = await methodChannel
          .invokeMethod('trackWithProperties', {
            'eventName': eventName,
            'userId': userId,
            'partnerAnonymousId': partnerAnonymousId,
            'properties': properties,
          });
      onCompletion(SprigSurveyState.fromRawValue(result));
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke iOS method: '${e.message}'.");
    }
  }

  @override
  Future<void> trackAndIdentify({
    required String eventName,
    required String userId,
    required String partnerAnonymousId,
    required Function(SprigSurveyState) onCompletion,
  }) async {
    try {
      final int result = await methodChannel.invokeMethod('trackAndIdentify', {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      });
      onCompletion(SprigSurveyState.fromRawValue(result));
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke iOS method: '${e.message}'.");
    }
  }
}
