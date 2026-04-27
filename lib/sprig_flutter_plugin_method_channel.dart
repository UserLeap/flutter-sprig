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
    /// Safely converts an int value to SprigSurveyState enum.
    SprigSurveyState _surveyStateFromInt(dynamic value) {
      if (value is int) {
        try {
          return SprigSurveyState.fromRawValue(value);
        } catch (_) {
          debugPrint('Invalid surveyState int: $value');
        }
      }
      return SprigSurveyState.noSurvey;
    }
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String?> sdkVersion() async {
    try {
      final sdkVersion = await methodChannel.invokeMethod<String>('sdkVersion');
      return sdkVersion;
    } catch (e) {
      debugPrint("Failed to get SDK version: $e");
      return null;
    }
  }

  @override
  Future<String?> visitorIdentifierString() async {
    try {
      final visitorIdentifierString = await methodChannel.invokeMethod<String>(
        'visitorIdentifierString',
      );
      return visitorIdentifierString;
    } catch (e) {
      debugPrint("Failed to get visitor identifier string: $e");
      return null;
    }
  }

  @override
  Future<void> configure({
    required String environment,
    Map<String, String>? configuration,
  }) async {
    try {
      await methodChannel.invokeMethod<void>('configure', {
        'environment': environment,
        'configuration': configuration,
      });
    } catch (e) {
      debugPrint("Failed to configure Sprig SDK: $e");
    }
  }

  @override
  Future<void> presentSurvey({required int surveyId}) async {
    try {
      await methodChannel.invokeMethod<void>('presentSurvey', {
        'surveyId': surveyId,
      });
    } catch (e) {
      debugPrint("Failed to present survey: $e");
    }
  }

  @override
  Future<void> present() async {
    try {
      await methodChannel.invokeMethod<void>('present');
    } catch (e) {
      debugPrint("Failed to present survey: $e");
    }
  }

  @override
  Future<void> setPreviewKey({required String previewKey}) async {
    try {
      await methodChannel.invokeMethod<void>('setPreviewKey', {
        'previewKey': previewKey,
      });
    } catch (e) {
      debugPrint("Failed to set preview key: $e");
    }
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
    try{
      await methodChannel.invokeMethod<void>('setEmailAddress', {
        'emailAddress': emailAddress,
      });
    } catch (e) {
      debugPrint("Failed to set email address: $e");
    }
  }

  @override
  Future<void> setVisitorAttribute({
    required String key,
    required String value,
  }) async {
    try{
      await methodChannel.invokeMethod<void>('setVisitorAttribute', {
        'key': key,
        'value': value,
      });
    } catch (e) {
      debugPrint("Failed to set visitor attribute: $e");
    }
  }

  @override
  Future<void> setVisitorAttributesAndIdentify({
    required Map<String, String> attributes,
    required String userId,
    String? partnerAnonymousId,
  }) async {
    try{
      await methodChannel.invokeMethod<void>('setVisitorAttributesAndIdentify', {
        'attributes': attributes,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      });
    } catch (e) {
      debugPrint("Failed to set visitor attributes and identify: $e");
    }
  }

  @override
  Future<void> removeVisitorAttributes({
    required List<String> attributes,
  }) async {
    try{
      await methodChannel.invokeMethod<void>('removeVisitorAttributes', {
        'attributes': attributes,
      });
    } catch (e) {
      debugPrint("Failed to remove visitor attributes: $e");
    }
  }

  @override
  Future<void> setUserIdentifier({required String identifier}) async {
    try{
      await methodChannel.invokeMethod<void>('setUserIdentifier', {
        'identifier': identifier,
      });
    } catch (e) {
      debugPrint("Failed to set user identifier: $e");
    }
  }

  @override
  Future<void> logout() async {
    try{
      await methodChannel.invokeMethod<void>('logout');
    } catch (e) {
      debugPrint("Failed to logout: $e");
    }
  }

  @override
  Future<void> trackAndPresent({required String eventName}) async {
    try{
      await methodChannel.invokeMethod<void>('trackAndPresent', {
        'eventName': eventName,
      });
    } catch (e) {
      debugPrint("Failed to track and present: $e");
    }
  }

  @override
  Future<void> trackIdentifyAndPresent({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
  }) async {
    try{
      await methodChannel.invokeMethod<void>('trackIdentifyAndPresent', {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      });
    } catch (e) {
      debugPrint("Failed to track, identify, and present: $e");
    }
  }

  @override
  Future<void> track({
    required String eventName,
    Function(SprigSurveyState)? onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) async {
    try {
      final Map result = await methodChannel.invokeMethod('track', {
        'eventName': eventName,
      });

      SprigSurveyState surveyState = _surveyStateFromInt(result["surveyState"]);
      int surveyId = result["surveyId"] as int;

      if (onCompletion != null) {
        onCompletion(surveyState);
      }
      if (onResultCompletion != null) {
        onResultCompletion(SprigSurveyResult(surveyState: surveyState, surveyId: surveyId));
      }
    } catch (e) {
      debugPrint("Failed to track event: $e");
    }
  }

  @override
  Future<void> trackWithProperties({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
    required Map<String, dynamic> properties,
    Function(SprigSurveyState)? onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) async {
    try {
      final Map result = await methodChannel
          .invokeMethod('trackWithProperties', {
            'eventName': eventName,
            'userId': userId,
            'partnerAnonymousId': partnerAnonymousId,
            'properties': properties,
          });
      SprigSurveyState surveyState = _surveyStateFromInt(result["surveyState"]);
      int surveyId = result["surveyId"] as int;

      if (onCompletion != null) {
        onCompletion(surveyState);
      }
      if (onResultCompletion != null) {
        onResultCompletion(SprigSurveyResult(surveyState: surveyState, surveyId: surveyId));
      }
    } catch (e) {
      debugPrint("Failed to track event with properties: $e");
    }
  }

  @override
  Future<void> trackAndIdentify({
    required String eventName,
    required String userId,
    required String partnerAnonymousId,
    Function(SprigSurveyState)? onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) async {
    try {
      final Map result = await methodChannel.invokeMethod('trackAndIdentify', {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      });
      SprigSurveyState surveyState = _surveyStateFromInt(result["surveyState"]);
      int surveyId = result["surveyId"] as int;

      if (onCompletion != null) {
        onCompletion(surveyState);
      }
      if (onResultCompletion != null) {
        onResultCompletion(SprigSurveyResult(surveyState: surveyState, surveyId: surveyId));
      }
    } catch (e) {
      debugPrint("Failed to track and identify event: $e");
    }
  }

  @override
  Future<void> dismissActiveSurvey() async {
    try {
      await methodChannel.invokeMethod<void>('dismissActiveSurvey');
    } catch (e) {
      debugPrint("Failed to dismiss active survey: $e");
    }   
  }

  @override
  Future<void> pauseDisplayingSurveys() async {
    try {
      await methodChannel.invokeMethod<void>('pauseDisplayingSurveys');
    } catch (e) {
      debugPrint("Failed to pause displaying surveys: $e");
    }
  }

  @override
  Future<void> unpauseDisplayingSurveys() async {
    try {
      await methodChannel.invokeMethod<void>('unpauseDisplayingSurveys');
    } catch (e) {
      debugPrint("Failed to unpause displaying surveys: $e");
    }
  }

  @override
  Future<void> overrideUserInterfaceMode(SprigUserInterfaceMode mode) async {
    try {
      await methodChannel.invokeMethod<void>('overrideUserInterfaceMode', {
        'mode': mode.index,
      });
    } catch (e) {
      debugPrint("Failed to override user interface mode: $e");
    }
  }
}
