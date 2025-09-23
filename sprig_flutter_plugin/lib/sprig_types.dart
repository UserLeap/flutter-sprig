
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
  none("none");

  final String value;
  const SprigLifecycleEvent(this.value);
}

enum SprigSurveyState {
    /// There is no survey to be displayed.
    noSurvey,
    /// A survey is ready to be displayed.
    ready,
    /// The survey request has been disabled.
    disabled;

    static SprigSurveyState fromRawValue(int value) {
      switch (value) {
        case 0:
          return SprigSurveyState.noSurvey;
        case 1:
          return SprigSurveyState.ready;
        case 2:
          return SprigSurveyState.disabled;
        default:
          return SprigSurveyState.noSurvey;
      }
    }
}