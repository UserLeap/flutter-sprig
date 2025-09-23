import Flutter
import UIKit
import UserLeapKit

public class SprigFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sprig_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = SprigFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argDict = call.arguments as? [String: Any]
        switch call.method {
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
        case "sdkVersion":
            result(Sprig.shared.sdkVersion)
        case "visitorIdentifierString":
            print("visitorIdentifierString \(Sprig.shared.visitorIdentifierString ?? "(none)")")
            result(Sprig.shared.visitorIdentifierString)
        case "configure":
            guard let argDict, let env = argDict["environment"] as? String else {
                logParsingIssue(argNames: "environment", functionName: "configure", arguments: argDict)
                return
            }
            Sprig.shared.configure(withEnvironment: env)
        case "registerEventListener":
            guard let argDict, let eventType = argDict["eventType"] as? String,
                  let lifecycleEvent = LifecycleEvent.fromString(eventType)
            else {
                logParsingIssue(argNames: "eventType", functionName: "registerEventListener", arguments: argDict)
                return
            }
            Sprig.shared.registerEventListener(for: lifecycleEvent) { eventData in
                result(eventData)
            }
        case "setPreviewKey":
            guard let argDict, let previewKey = argDict["previewKey"] as? String
            else {
                logParsingIssue(argNames: "previewKey", functionName: "setPreviewKey", arguments: argDict)
                return
            }
            Sprig.shared.setPreviewKey(previewKey)
        case "logout":
            Sprig.shared.logout()
        case "setEmailAddress":
            guard let argDict, let emailAddress = argDict["emailAddress"] as? String
            else {
                logParsingIssue(argNames: "emailAddress", functionName: "setEmailAddress", arguments: argDict)
                return
            }
            Sprig.shared.setEmailAddress(emailAddress)
        case "setVisitorAttribute":
            guard let argDict,
                  let value = argDict["value"] as? String,
                  let key = argDict["key"] as? String
            else {
                logParsingIssue(argNames: "visitorAttribute", functionName: "setVisitorAttribute", arguments: argDict)
                return
            }
            Sprig.shared.setVisitorAttribute(key: key, value: value)
        case "setVisitorAttributesAndIdentify":
            guard let argDict,
                  let attributes = argDict["attributes"] as? [String: String]
            else {
                logParsingIssue(argNames: "attributes", functionName: "setVisitorAttributesAndIdentify", arguments: argDict)
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            Sprig.shared.setVisitorAttributes(attributes, userId: userId, partnerAnonymousId: partnerAnonymousId)
        case "removeVisitorAttributes":
            guard let argDict,
                  let attributes = argDict["attributes"] as? [String]
            else {
                logParsingIssue(argNames: "attributes", functionName: "removeVisitorAttributes", arguments: argDict)
                return
            }
            Sprig.shared.removeVisitorAttributes(attributes)
        case "setUserIdentifier":
            guard let argDict,
                  let identifier = argDict["identifier"] as? String
            else {
                logParsingIssue(argNames: "identifier", functionName: "setUserIdentifier", arguments: argDict)
                return
            }
            Sprig.shared.setUserIdentifier(identifier)
        case "presentSurvey":
            guard let argDict, let surveyId = argDict["surveyId"] as? Int else {
                logParsingIssue(argNames: "surveyId", functionName: "presentSurvey", arguments: argDict)
                return
            }
            guard let viewController = getRootViewController() else {
                print("Failed to get root view controller for presentSurvey")
                return
            }
            Sprig.shared.presentSurvey(withId: surveyId, from: viewController)
        case "present":
        guard let viewController = getRootViewController() else {
                print("Failed to get root view controller for presentSurvey")
                return
            }
            Sprig.shared.presentSurvey(from: viewController)
        case "trackAndPresent":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                logParsingIssue(argNames: "eventName", functionName: "trackAndPresent", arguments: argDict)
                return
            }
            guard let rootViewController = getRootViewController() else {
                print("Could not get root view controller for trackAndPresent")
                return
            }
            let payload = EventPayload(eventName: eventName)
            Sprig.shared.trackAndPresent(payload: payload, from: rootViewController)
        case "trackIdentifyAndPresent":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                logParsingIssue(argNames: "eventName", functionName: "trackIdentifyAndPresent", arguments: argDict)
                return
            }
            guard let rootViewController = getRootViewController() else {
                print("Could not get root view controller for trackIdentifyAndPresent")
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId)
            Sprig.shared.trackAndPresent(payload: payload, from: rootViewController)
        case "track":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String else {
                logParsingIssue(argNames: "eventName", functionName: "track", arguments: argDict)
                return
            }
            let payload = EventPayload(eventName: eventName)
            payload.handler = { surveyState in
                result(surveyState.rawValue)
            }
            Sprig.shared.track(payload: payload)
        case "trackWithProperties":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String,
                  let properties = argDict["properties"] as? [String: Any] else {
                logParsingIssue(argNames: "eventName, properties", functionName: "trackWithProperties", arguments: argDict)
                return
            }
            let userId = argDict["userId"] as? String
            let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId, properties: properties)
            payload.handler = { surveyState in
                result(surveyState.rawValue)
            }
            Sprig.shared.track(payload: payload)
            
        case "trackAndIdentify":
            guard let argDict,
                  let eventName = argDict["eventName"] as? String,
                  let userId = argDict["userId"] as? String,
                  let partnerAnonymousId = argDict["partnerAnonymousId"] as? String
            else {
                logParsingIssue(argNames: "eventName, userId, partnerAnonymousId", functionName: "trackAndIdentify", arguments: argDict)
                return
            }
            let payload = EventPayload(eventName: eventName, userId: userId, partnerAnonymousId: partnerAnonymousId)
            payload.handler = { surveyState in
                result(surveyState.rawValue)
            }
            Sprig.shared.track(payload: payload)
        default:
            result(FlutterMethodNotImplemented)
        }
   }
    
    private func logParsingIssue(argNames: String, functionName: String, arguments: [String: Any]?) {
        print("Failed parsing \(argNames) in \(functionName) call from arguments: \(arguments ?? [:])")
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController) else {
            print("Could not get root view controller")
            return nil
        }
        return viewController
    }
}
