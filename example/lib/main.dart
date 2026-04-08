import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sprig_flutter_plugin/sprig_flutter_plugin.dart';
import 'package:sprig_flutter_plugin/sprig_types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _unknownText = "(unknown)";
  String? _message;
  String _platformVersion = _unknownText;
  String _sdkVersion = _unknownText;
  String _visitorIdentifierString = _unknownText;
  final _sprigFlutterPlugin = SprigFlutterPlugin();

  // Set these values for testing features in the example app
  final String _defaultEnvironment =
      "<your_environment_id>"; // Change to your Environment ID
  final String _defaultEventName =
      "<your_event_name>"; // Change to your event name
  final int _defaultSurveyId = 0; // Change to your survey ID
  final String _defaultPreviewKey =
      "<your_preview_key>"; //  Change to your preview key
  final String _defaultEmailAddress =
      "<your_email_address>"; // Change to your email address
  final String _defaultVisitorAttributeKey =
      "<your_visitor_attribute_key>"; // Change to your visitor attribute key
  final String _defaultVisitorAttributeValue =
      "<your_visitor_attribute_value>"; // Change to your visitor attribute value
  final Map<String, String> _defaultVisitorAttributes = {
    "<your_visitor_attribute_key1>": "<your_visitor_attribute_value1>",
    "<your_visitor_attribute_key2>": "<your_visitor_attribute_value2>",
  }; // Change to your visitor attributes map
  final String _defaultUserId = "<your_user_id>"; // Change to your user ID
  final String _defaultPartnerAnonymousId =
      "<your_partner_anonymous_id>"; // Change to your partner anonymous ID
  final List<String> _defaultAttributesToRemove = [
    "<your_visitor_attribute_key1>",
    "<your_visitor_attribute_key2>",
  ]; // Change to your visitor attributes to remove
  final Map<String, dynamic> _defaultProperties = {
    "<property_key1>": "<property_value1>",
    "<property_key2>": 2,
    "<property_key3>": true,
  }; // Change to your properties map

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = _unknownText;
    String sdkVersion = _unknownText;
    String? platformExceptionMsg;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    try {
      _sprigFlutterPlugin.configure(
        environment: _defaultEnvironment,
        configuration: null,
      );
      registerForSprigEvents();
      platformVersion =
          await _sprigFlutterPlugin.getPlatformVersion() ?? _unknownText;
      sdkVersion = await _sprigFlutterPlugin.sdkVersion() ?? _unknownText;
    } on PlatformException catch (e) {
      platformExceptionMsg = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _message = platformExceptionMsg;
      _platformVersion = platformVersion;
      _sdkVersion = sdkVersion;
    });
  }

  void registerForSprigEvents() {
    // Example: Register for all events
    // In production, only register for the events you need
    for (var event in SprigLifecycleEvent.values) {
      if (event == SprigLifecycleEvent.none) {
        continue; // Skip the 'none' event
      }
      _sprigFlutterPlugin.registerEventListener(event, (eventData) {
        processSprigEvent(eventData);
      });
    }
  }

  void processSprigEvent(Map<Object?, Object?> eventData) async {
    if (eventData["type"] case var eventTypeString?) {
      SprigLifecycleEvent eventType = SprigLifecycleEvent.values.firstWhere(
        (e) => e.value == eventTypeString,
        orElse: () => SprigLifecycleEvent.none,
      );
      switch (eventType) {
        case SprigLifecycleEvent.sdkReady:
          debugPrint("SDK is ready");
        case SprigLifecycleEvent.visitorIdUpdated:
          setState(() {
            _visitorIdentifierString =
                eventData["visitorId"]?.toString() ?? _unknownText;
          });
          debugPrint("Visitor ID updated to $_visitorIdentifierString");
        case SprigLifecycleEvent.surveyHeight:
          debugPrint("Survey height updated");
        case SprigLifecycleEvent.surveyWillPresent:
          debugPrint("Survey will present");
        case SprigLifecycleEvent.surveyPresented:
          debugPrint("Survey presented");
        case SprigLifecycleEvent.surveyAppeared:
          debugPrint("Survey appeared");
        case SprigLifecycleEvent.surveyCloseRequested:
          debugPrint("Survey close requested");
        case SprigLifecycleEvent.surveyWillClose:
          debugPrint("Survey will close");
        case SprigLifecycleEvent.surveyClosed:
          debugPrint("Survey closed");
        case SprigLifecycleEvent.replayCapture:
          debugPrint("Replay capture event");
        case SprigLifecycleEvent.replayCaptureStarted:
          debugPrint("Replay capture started");
        case SprigLifecycleEvent.replayCaptureStopped:
          debugPrint("Replay capture stopped");
        case SprigLifecycleEvent.replayCaptureCompleted:
          debugPrint("Replay capture completed");
        case SprigLifecycleEvent.replayRenderingCompleted:
          debugPrint("Replay rendering completed");
        case SprigLifecycleEvent.replayUploadCompleted:
          debugPrint("Replay upload completed");
        case SprigLifecycleEvent.replayEventsUploadCompleted:
          debugPrint("Replay events upload completed");
        case SprigLifecycleEvent.loggingEvent:
          if (eventData["message"] case var message?) {
            debugPrint("Logging Event: $message");
          }
        case SprigLifecycleEvent.surveyCompleted:
          debugPrint("Lifecycle Event: Survey completed with data: $eventData");  
        case SprigLifecycleEvent.surveyStateReturned:
          debugPrint("Lifecycle Event: Survey state returned with data: $eventData");
        case SprigLifecycleEvent.none:
          debugPrint("Unknown event type ${eventTypeString}");
      }
    } else {
      debugPrint("Event type is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Container(
          margin: const EdgeInsets.only(left: 16.0),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Text('OS version: $_platformVersion'),
              Text('Sprig SDK version: $_sdkVersion'),
              Text('Visitor Identifier String: $_visitorIdentifierString\n'),
              if (_message != null) Text('$_message'),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.presentSurvey(
                      surveyId: _defaultSurveyId,
                    );
                  },
                  child: const Text('Launch Survey'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.setPreviewKey(
                      previewKey: _defaultPreviewKey,
                    );
                  },
                  child: const Text('Set Preview Key'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.setEmailAddress(
                      emailAddress: _defaultEmailAddress,
                    );
                  },
                  child: const Text('Set Email Address'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.setVisitorAttribute(
                      key: _defaultVisitorAttributeKey,
                      value: _defaultVisitorAttributeValue,
                    );
                  },
                  child: const Text('Set Visitor Attribute'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.setVisitorAttributesAndIdentify(
                      attributes: _defaultVisitorAttributes,
                      userId: _defaultUserId,
                      partnerAnonymousId: _defaultPartnerAnonymousId,
                    );
                  },
                  child: const Text('Set Visitor Attributes and Identify'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.removeVisitorAttributes(
                      attributes: _defaultAttributesToRemove,
                    );
                  },
                  child: const Text('Remove Visitor Attributes'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.setUserIdentifier(
                      identifier: _defaultUserId,
                    );
                  },
                  child: const Text('Set User Identifier'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.logout();
                  },
                  child: const Text('Logout'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.trackAndPresent(
                      eventName: _defaultEventName,
                    );
                  },
                  child: const Text('Track and Present'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.trackIdentifyAndPresent(
                      eventName: _defaultEventName,
                      userId: _defaultUserId,
                      partnerAnonymousId: _defaultPartnerAnonymousId,
                    );
                  },
                  child: const Text('Track Identify and Present'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.track(
                      eventName: _defaultEventName,
                      onCompletion: (surveyState) {
                        setState(() {
                          _message =
                              "Track completed with survey state: $surveyState";
                        });
                        debugPrint(
                          "Track completed with survey state: $surveyState",
                        );
                      },
                    );
                  },
                  child: const Text('Track with callback'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.trackWithProperties(
                      eventName: _defaultEventName,
                      userId: _defaultUserId,
                      partnerAnonymousId: _defaultPartnerAnonymousId,
                      properties: _defaultProperties,
                      onCompletion: (surveyState) {
                        setState(() {
                          _message =
                              "TrackWithProperties completed with survey state: $surveyState";
                        });
                        debugPrint(
                          "TrackWithProperties completed with survey state: $surveyState",
                        );
                      },
                    );
                  },
                  child: const Text('TrackWithProperties with callback'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _sprigFlutterPlugin.trackAndIdentify(
                      eventName: _defaultEventName,
                      userId: _defaultUserId,
                      partnerAnonymousId: _defaultPartnerAnonymousId,
                      onCompletion: (surveyState) {
                        setState(() {
                          _message =
                              "TrackAndIdentify completed with survey state: $surveyState";
                        });
                        debugPrint(
                          "TrackAndIdentify completed with survey state: $surveyState",
                        );
                      },
                    );
                  },
                  child: const Text('TrackAndIdentify with callback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
