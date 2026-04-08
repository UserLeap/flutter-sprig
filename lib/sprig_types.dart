
enum SprigLifecycleEvent {
  sdkReady("sdkReady"),
  visitorIdUpdated("visitorIdUpdated"),
  surveyHeight("setHeight"),
  surveyWillPresent("surveyWillPresent"),
  surveyPresented("surveyPresented"),
  surveyAppeared("surveyAppeared"),
  surveyCloseRequested("surveyCloseRequested"),
  surveyWillClose("surveyWillClose"),
  surveyClosed("surveyClosed"),
  replayCapture("replayCapture"),
  replayCaptureStarted("replayCaptureStarted"),
  replayCaptureStopped("replayCaptureStopped"),
  replayCaptureCompleted("replayCaptureCompleted"),
  replayRenderingCompleted("replayRenderingCompleted"),
  replayUploadCompleted("replayUploadCompleted"),
  replayEventsUploadCompleted("replayEventsUploadCompleted"),
  loggingEvent("loggingEvent"),
  surveyCompleted("surveyCompleted"),
  surveyStateReturned("surveyStateReturned"),
  none("none");

  final String value;
  const SprigLifecycleEvent(this.value);
}

class SprigSurveyResult {
  final SprigSurveyState surveyState;
  final int surveyId;

  SprigSurveyResult({
    required this.surveyState,
    required this.surveyId,
  });
}

enum SprigSurveyState {
    /// There is no survey to be displayed.
    noSurvey,
    /// A survey is ready to be displayed.
    ready,
    /// The survey request has been disabled.
    disabled,
    /// A previous survey is ready to be displayed.
    previousSurveyReady;

    static SprigSurveyState fromRawValue(int value) {
      switch (value) {
        case 0:
          return SprigSurveyState.noSurvey;
        case 1:
          return SprigSurveyState.ready;
        case 2:
          return SprigSurveyState.disabled;
        case 3:
          return SprigSurveyState.previousSurveyReady;
        default:
          return SprigSurveyState.noSurvey;
      }
    }
}