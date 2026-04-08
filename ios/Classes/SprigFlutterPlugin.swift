import Flutter
import UIKit
import UserLeapKit

public class SprigFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var registeredEvents = Set<String>()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "sprig_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = SprigFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        let eventChannel = FlutterEventChannel(name: "sprig_flutter_plugin/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        registeredEvents.removeAll()
        return nil
    }
        
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argDict = call.arguments as? [String: Any]
        switch call.method {
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
        case "sdkVersion":
            result(Sprig.shared.sdkVersion)
        case "visitorIdentifierString":
            result(Sprig.shared.visitorIdentifierString)
        case "configure":
            guard let argDict, let env = argDict["environment"] as? String else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'environment' parameter", details: nil))
                return
            }
            Sprig.shared.configure(withEnvironment: env)
            result(nil)
        case "registerEventListener":
            guard let argDict, let eventType = argDict["eventType"] as? String,
                  let lifecycleEvent = LifecycleEvent.fromString(eventType)
            else {
                result(FlutterError(code: "INVALID_EVENT", message: "Invalid event type", details: nil))
                return
            }
            registerEventListener(for: lifecycleEvent)
            result("Listener registered for \(eventType)")
        case "setPreviewKey":
            guard let argDict, let previewKey = argDict["previewKey"] as? String
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'previewKey' parameter", details: nil))
                return
            }
            Sprig.shared.setPreviewKey(previewKey)
            result(nil)
        case "logout":
            Sprig.shared.logout()
            result(nil)
        case "setEmailAddress":
            guard let argDict, let emailAddress = argDict["emailAddress"] as? String
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'emailAddress' parameter", details: nil))
                return
            }
            Sprig.shared.setEmailAddress(emailAddress)
            result(nil)
        case "setVisitorAttribute":
            guard let argDict,
                  let value = argDict["value"] as? String,
                  let key = argDict["key"] as? String
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing parameters for setVisitorAttribute", details: nil))
                return
            }
            Sprig.shared.setVisitorAttribute(key: key, value: value)
            result(nil)
        case "setVisitorAttributesAndIdentify":
            guard let argDict,
                  let attributes = argDict["attributes"] as? [String: String]
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'attributes' parameter", details: nil))
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            Sprig.shared.setVisitorAttributes(attributes, userId: userId, partnerAnonymousId: partnerAnonymousId)
            result(nil)
        case "removeVisitorAttributes":
            guard let argDict,
                  let attributes = argDict["attributes"] as? [String]
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'attributes' parameter", details: nil))
                return
            }
            Sprig.shared.removeVisitorAttributes(attributes)
            result(nil)
        case "setUserIdentifier":
            guard let argDict,
                  let identifier = argDict["identifier"] as? String
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'identifier' parameter", details: nil))
                return
            }
            Sprig.shared.setUserIdentifier(identifier)
            result(nil)
        case "presentSurvey":
            guard let argDict, let surveyId = argDict["surveyId"] as? Int else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'surveyId' parameter", details: nil))
                return
            }
            guard let viewController = getRootViewController() else {
                Sprig.shared.dismissActiveSurvey()
                print("Sprig Plugin: Failed to get root view controller for presentSurvey")
                return
            }
            Sprig.shared.presentSurvey(withId: surveyId, from: viewController)
            result(nil)
        case "present":
            guard let viewController = getRootViewController() else {
                Sprig.shared.dismissActiveSurvey()
                print("Sprig Plugin: Failed to get root view controller for present")
                return
            }
            Sprig.shared.presentSurvey(from: viewController)
            result(nil)
        case "trackAndPresent":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'eventName' parameter for trackAndPresent", details: nil))
                return
            }
            guard let rootViewController = getRootViewController() else {
                Sprig.shared.dismissActiveSurvey()
                print("Sprig Plugin: Failed to get root view controller for trackAndPresent")
                return
            }
            let payload = EventPayload(eventName: eventName)
            Sprig.shared.trackAndPresent(payload: payload, from: rootViewController)
            result(nil)
        case "trackIdentifyAndPresent":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'eventName' parameter for trackIdentifyAndPresent", details: nil))
                return
            }
            guard let rootViewController = getRootViewController() else {
                Sprig.shared.dismissActiveSurvey()
                print("Sprig Plugin: Failed to get root view controller for trackIdentifyAndPresent")
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId)
            Sprig.shared.trackAndPresent(payload: payload, from: rootViewController)
            result(nil)
        case "track":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing 'eventName' parameter for track", details: nil))
                return
            }
            let payload = EventPayload(eventName: eventName)
            payload.resultHandler = { surveyResult in
                let resultDict = [
                    "surveyState": surveyResult.surveyState.rawValue,
                    "surveyId": surveyResult.surveyId
                ]
                result(resultDict)
            }
            Sprig.shared.track(payload: payload)
        case "trackWithProperties":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String,
                  let properties = argDict["properties"] as? [String: Any] else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing parameters for trackWithProperties", details: nil))
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId, properties: properties)
            payload.resultHandler = { surveyResult in
                let resultDict = [
                    "surveyState": surveyResult.surveyState.rawValue,
                    "surveyId": surveyResult.surveyId
                ]
                result(resultDict)
            }
            Sprig.shared.track(payload: payload)
            
        case "trackAndIdentify":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String,
                  let userId = argDict["userId"] as? String,
                  let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            else {
                result(FlutterError(code: "MISSING_ARGUMENT", message: "Missing parameters for trackAndIdentify", details: nil))
                return
            }
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId)
            payload.resultHandler = { surveyResult in
                let resultDict = [
                    "surveyState": surveyResult.surveyState.rawValue,
                    "surveyId": surveyResult.surveyId
                ]
                result(resultDict)
            }
            Sprig.shared.track(payload: payload)
        case "dismissActiveSurvey":
            Sprig.shared.dismissActiveSurvey()
            result(nil)
        case "pauseDisplayingSurveys":
            Sprig.shared.pauseDisplayingSurveys()
            result(nil)
        case "unpauseDisplayingSurveys":
            Sprig.shared.unpauseDisplayingSurveys()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerEventListener(for lifecycleEvent: LifecycleEvent) {
        let eventKey = lifecycleEvent.stringValue
        let eventTypeKeyOut = "eventType"
        let eventTypeKeyIn = "type"
        let dataKey = "data"
        
        guard !registeredEvents.contains(eventKey) else {
            print("Sprig Plugin: Listener for \(eventKey) already registered, skipping.")
            return
        }

        Sprig.shared.registerEventListener(for: lifecycleEvent) {[weak self] eventData in
            guard let self, let eventSink else { return} 
            guard let eventType = eventData[eventTypeKeyIn] as? String else { 
                print("Sprig Plugin: Could not parse event type from event data: \(eventData)")
                return 
            }
            
            var flutterEventData: [String: Any] = [
                eventTypeKeyOut: eventType
            ]
            
            if let eventDict = eventData as? [String: Any] {
                for (key, value) in eventDict {
                    flutterEventData[key] = value
                }
            } else if eventData != nil {
                flutterEventData[dataKey] = eventData
            }
            
            DispatchQueue.main.async {
                eventSink(flutterEventData)
            }
        }
        
        registeredEvents.insert(eventKey)
    }
    
    private func getRootViewController() -> UIViewController? {
        // Try multiple methods to get the root view controller
        var viewController: UIViewController?
        
        // Method 1: Try scene-based approach (iOS 13+)
        if #available(iOS 13.0, *) {
            viewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        }
        
        // Method 2: Fallback to traditional approach
        if viewController == nil {
            viewController = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        // Method 3: Last resort - try all windows
        if viewController == nil {
            viewController = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        }
        
        guard let viewController = viewController else {          
            print("Sprig Plugin: Could not find a root view controller.")
            return nil
        }
        return viewController
    }
}
