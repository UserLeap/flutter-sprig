import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sprig_flutter_plugin_method_channel.dart';
import 'package:sprig_flutter_plugin/sprig_types.dart';

abstract class SprigFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a SprigFlutterPluginPlatform.
  SprigFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SprigFlutterPluginPlatform _instance = MethodChannelSprigFlutterPlugin();

  /// The default instance of [SprigFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSprigFlutterPlugin].
  static SprigFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SprigFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(SprigFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> sdkVersion() {
    throw UnimplementedError('sdkVersion() has not been implemented.');
  }
  Future<String?> visitorIdentifierString() {
    throw UnimplementedError('visitorIdentifierString() has not been implemented.');
  }
  Future<void> configure({required String environment, Map<String, String>? configuration}) {
    throw UnimplementedError('configure() has not been implemented.');
  }
  Future<void> presentSurvey({required int surveyId}) {
    throw UnimplementedError('presentSurvey() has not been implemented.');
  }
  Future<void> registerEventListener({required SprigLifecycleEvent eventType, required Function(Map<Object?, Object?>) onCompletion}) {
    throw UnimplementedError('registerEventListener() has not been implemented.');
  }
  Future<void> setPreviewKey({required String previewKey}) {
    throw UnimplementedError('setPreviewKey() has not been implemented.');
  }
  Future<void> setEmailAddress({required String emailAddress}) {
    throw UnimplementedError('setEmailAddress() has not been implemented.');
  }
  Future<void> setVisitorAttribute({required String key, required String value}) {
    throw UnimplementedError('setVisitorAttribute() has not been implemented.');
  }
  Future<void> setVisitorAttributesAndIdentify({required Map<String, String> attributes, required String userId, String? partnerAnonymousId}) async {
    throw UnimplementedError('setVisitorAttributesAndIdentify() has not been implemented.');
  }
  Future<void> removeVisitorAttributes({required List<String> attributes}) async {
    throw UnimplementedError('removeVisitorAttributes() has not been implemented.');
  }
  Future<void> setUserIdentifier({required String identifier}) async {
    throw UnimplementedError('setUserIdentifier() has not been implemented.');
  }
  Future<void> logout() async {
    throw UnimplementedError('logout() has not been implemented.');
  }
  Future<void> trackAndPresent({required String eventName}) async {
    throw UnimplementedError('trackAndPresent() has not been implemented.');
  }
  Future<void> trackIdentifyAndPresent({required String eventName, String? userId, String? partnerAnonymousId}) async {
    throw UnimplementedError('trackIdentifyAndPresent() has not been implemented.');
  } 
  Future<void> track({required String eventName, required Function(SprigSurveyState) onCompletion}) {
    throw UnimplementedError('track() has not been implemented.');
  }
  Future<void> trackWithProperties({required String eventName, String? userId, String? partnerAnonymousId, required Map<String, dynamic> properties, required Function(SprigSurveyState) onCompletion}) {
    throw UnimplementedError('trackWithProperties() has not been implemented.');
  }
  Future<void> trackAndIdentify({required String eventName,required String userId,required String partnerAnonymousId, required Function(SprigSurveyState) onCompletion}) {
    throw UnimplementedError('trackAndIdentify() has not been implemented.');
  }
  Future<void> present() {
    throw UnimplementedError('present() has not been implemented.');
  }
}
