import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sprig_flutter_plugin_platform_interface.dart';
import 'package:sprig_flutter_plugin/sprig_types.dart';

/// An implementation of [SprigFlutterPluginPlatform] that uses method channels.
class MethodChannelSprigFlutterPlugin extends SprigFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sprig_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<String?> sdkVersion() async {
    final sdkVersion = await methodChannel.invokeMethod<String>('sdkVersion');
    return sdkVersion;
  }
  @override
  Future<String?> visitorIdentifierString() async {
    final visitorIdentifierString = await methodChannel.invokeMethod<String>('visitorIdentifierString');
    return visitorIdentifierString;
  }
  @override
  Future<void> configure({required String environment, Map<String, String>? configuration}) async {
    await methodChannel.invokeMethod<void>(
      'configure',
      {
        'environment': environment,
        'configuration': configuration,
      },
    );
  }
  @override
  Future<void> presentSurvey({required int surveyId}) async {
    await methodChannel.invokeMethod<void>(
      'presentSurvey',
      {
        'surveyId': surveyId,
      },
    );
  }
  @override
  Future<void> present() async {
    await methodChannel.invokeMethod<void>(
      'present'
    );
  }
  @override
  Future<void> setPreviewKey({required String previewKey}) async {
    await methodChannel.invokeMethod<void>(
      'setPreviewKey',
      {
        'previewKey': previewKey,
      },
    );
  }
  @override
  Future<void> registerEventListener({required SprigLifecycleEvent eventType, required Function(Map<Object?, Object?>) onCompletion}) async {
    try {
      final Map<Object?, Object?> result = await methodChannel.invokeMethod (
        'registerEventListener',
        {'eventType': eventType.value},
      );
      onCompletion(result); // Execute the Dart closure with the iOS result
    } on PlatformException catch (e) {
      print("Failed to invoke iOS method: '${e.message}'.");
    }
  }
  @override
  Future<void> setEmailAddress({required String emailAddress}) async {
    await methodChannel.invokeMethod<void>(
      'setEmailAddress',
      {
        'emailAddress': emailAddress,
      },
    );
  }
  @override
  Future<void> setVisitorAttribute({required String key, required String value}) async {
    await methodChannel.invokeMethod<void>(
      'setVisitorAttribute',
      {
        'key': key,
        'value': value,
      },
    );
  }
  @override
  Future<void> setVisitorAttributesAndIdentify({required Map<String, String> attributes, required String userId, String? partnerAnonymousId}) async {
    await methodChannel.invokeMethod<void>(
      'setVisitorAttributesAndIdentify',
      {
        'attributes': attributes,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      },
    );
  }
  @override
  Future<void> removeVisitorAttributes({required List<String> attributes}) async {
    await methodChannel.invokeMethod<void>(
      'removeVisitorAttributes',
      {
        'attributes': attributes,
      },
    );
  }
  @override
  Future<void> setUserIdentifier({required String identifier}) async {
    await methodChannel.invokeMethod<void>(
      'setUserIdentifier',
      {
        'identifier': identifier,
      },
    );
  }
  @override 
  Future<void> logout() async {
    await methodChannel.invokeMethod<void>(
      'logout',
    );
  }
  @override
  Future<void> trackAndPresent({required String eventName}) async {
    await methodChannel.invokeMethod<void>(
      'trackAndPresent',
      {'eventName': eventName,},
    );
  }
  @override
  Future<void> trackIdentifyAndPresent({required String eventName, String? userId, String? partnerAnonymousId}) async {
    await methodChannel.invokeMethod<void>(
      'trackIdentifyAndPresent',
      {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      },
    );
  }
  @override
  Future<void> track({required String eventName, required Function(SprigSurveyState) onCompletion}) async {
    try {
      final int result = await methodChannel.invokeMethod (
      'track',
      {'eventName': eventName},
      );
      onCompletion(SprigSurveyState.fromRawValue(result)); // Execute the Dart closure with the iOS result
    } on PlatformException catch (e) {
      print("Failed to invoke iOS method: '${e.message}'.");
    }
  }
  @override
  Future<void> trackWithProperties({required String eventName, String? userId, String? partnerAnonymousId, required Map<String, dynamic> properties, required Function(SprigSurveyState) onCompletion}) async {
    try {
      final int result = await methodChannel.invokeMethod (
      'trackWithProperties',
      {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
        'properties': properties,
      },
      );
      onCompletion(SprigSurveyState.fromRawValue(result)); // Execute the Dart closure with the iOS result
    } on PlatformException catch (e) {
      print("Failed to invoke iOS method: '${e.message}'.");
    }
  }
  @override
  Future<void> trackAndIdentify({required String eventName, required String userId, required String partnerAnonymousId, required Function(SprigSurveyState) onCompletion}) async {
    try {
      final int result = await methodChannel.invokeMethod (
      'trackAndIdentify',
      {
        'eventName': eventName,
        'userId': userId,
        'partnerAnonymousId': partnerAnonymousId,
      },
      );
      onCompletion(SprigSurveyState.fromRawValue(result)); // Execute the Dart closure with the iOS result
    } on PlatformException catch (e) {
      print("Failed to invoke iOS method: '${e.message}'.");
    }
  }
}
