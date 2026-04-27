import 'sprig_flutter_plugin_platform_interface.dart';
import 'package:sprig_flutter_plugin/sprig_types.dart';

class SprigFlutterPlugin {
  Future<String?> getPlatformVersion() {
    return SprigFlutterPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> sdkVersion() {
    return SprigFlutterPluginPlatform.instance.sdkVersion();
  }

  Future<String?> visitorIdentifierString() {
    return SprigFlutterPluginPlatform.instance.visitorIdentifierString();
  }

  Future<void> configure({
    required String environment,
    Map<String, String>? configuration,
  }) {
    return SprigFlutterPluginPlatform.instance.configure(
      environment: environment,
      configuration: configuration,
    );
  }

  Future<void> presentSurvey({required int surveyId}) {
    return SprigFlutterPluginPlatform.instance.presentSurvey(
      surveyId: surveyId,
    );
  }

  Future<void> registerEventListener(
    SprigLifecycleEvent eventType,
    Function(Map<Object?, Object?>) onCompletion,
  ) {
    return SprigFlutterPluginPlatform.instance.registerEventListener(
      eventType: eventType,
      onCompletion: onCompletion,
    );
  }

  Future<void> setPreviewKey({required String previewKey}) {
    return SprigFlutterPluginPlatform.instance.setPreviewKey(
      previewKey: previewKey,
    );
  }

  Future<void> setEmailAddress({required String emailAddress}) {
    return SprigFlutterPluginPlatform.instance.setEmailAddress(
      emailAddress: emailAddress,
    );
  }

  Future<void> setVisitorAttribute({
    required String key,
    required String value,
  }) {
    return SprigFlutterPluginPlatform.instance.setVisitorAttribute(
      key: key,
      value: value,
    );
  }

  Future<void> setVisitorAttributesAndIdentify({
    required Map<String, String> attributes,
    required String userId,
    String? partnerAnonymousId,
  }) {
    return SprigFlutterPluginPlatform.instance.setVisitorAttributesAndIdentify(
      attributes: attributes,
      userId: userId,
      partnerAnonymousId: partnerAnonymousId,
    );
  }

  Future<void> removeVisitorAttributes({required List<String> attributes}) {
    return SprigFlutterPluginPlatform.instance.removeVisitorAttributes(
      attributes: attributes,
    );
  }

  Future<void> setUserIdentifier({required String identifier}) {
    return SprigFlutterPluginPlatform.instance.setUserIdentifier(
      identifier: identifier,
    );
  }

  Future<void> logout() {
    return SprigFlutterPluginPlatform.instance.logout();
  }

  Future<void> trackAndPresent({required String eventName}) {
    return SprigFlutterPluginPlatform.instance.trackAndPresent(
      eventName: eventName,
    );
  }

  Future<void> trackIdentifyAndPresent({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
  }) {
    return SprigFlutterPluginPlatform.instance.trackIdentifyAndPresent(
      eventName: eventName,
      userId: userId,
      partnerAnonymousId: partnerAnonymousId,
    );
  }

  Future<void> track({
    required String eventName,
    @Deprecated('Use onResultCompletion instead') Function(SprigSurveyState)? onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) {
    return SprigFlutterPluginPlatform.instance.track(
      eventName: eventName,
      onCompletion: onCompletion,
      onResultCompletion: onResultCompletion,
    );
  }

  Future<void> trackWithProperties({
    required String eventName,
    String? userId,
    String? partnerAnonymousId,
    required Map<String, dynamic> properties,
    @Deprecated('Use onResultCompletion instead') required Function(SprigSurveyState) onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) {
    return SprigFlutterPluginPlatform.instance.trackWithProperties(
      eventName: eventName,
      userId: userId,
      partnerAnonymousId: partnerAnonymousId,
      properties: properties,
      onCompletion: onCompletion,
      onResultCompletion: onResultCompletion,
    );
  }

  Future<void> trackAndIdentify({
    required String eventName,
    required String userId,
    required String partnerAnonymousId,
    @Deprecated('Use onResultCompletion instead') Function(SprigSurveyState)? onCompletion,
    Function(SprigSurveyResult)? onResultCompletion,
  }) {
    return SprigFlutterPluginPlatform.instance.trackAndIdentify(
      eventName: eventName,
      userId: userId,
      partnerAnonymousId: partnerAnonymousId,
      onCompletion: onCompletion,
      onResultCompletion: onResultCompletion,
    );
  }

  Future<void> present() {
    return SprigFlutterPluginPlatform.instance.present();
  }

  Future<void> dismissActiveSurvey() {
    return SprigFlutterPluginPlatform.instance.dismissActiveSurvey();
  }

  Future<void> pauseDisplayingSurveys() {
    return SprigFlutterPluginPlatform.instance.pauseDisplayingSurveys();
  }

  Future<void> unpauseDisplayingSurveys() {
    return SprigFlutterPluginPlatform.instance.unpauseDisplayingSurveys();
  }

  Future<void> overrideUserInterfaceMode(SprigUserInterfaceMode mode) {
    return SprigFlutterPluginPlatform.instance.overrideUserInterfaceMode(mode);
  }
}
