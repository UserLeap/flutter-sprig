# Change Log

<!-- add: A new feature -->
<!-- fix: A bug fix -->
<!-- chore: Changes to the build process or auxiliary tools and libraries -->
<!-- breaking: A change that requires action from consumers -->

### 0.10.0
- chore: Update iOS SDK to v4.35.0.
- chore: Update Android SDK to v2.29.0.
- add: Refactor of the survey lifecycle events for better accuracy with the addition of the new surveyReturned event, the removal of surveyWillPresent, a change to when the surveyAppeared emits and the addition of the new surveyDidNotAppear event.
- add: Passing the surveyId of the previous survey when a previousSurveyReady state is returned.
- Released on 08/31/26

### 0.9.1
- chore: Update iOS SDK to v4.33.1.
- chore: Update Android SDK to v2.27.2.
- Released on 07/31/26

### 0.9.0
- breaking: Migrated the iOS SDK integration from CocoaPods to Swift Package Manager.  
- chore: Validated against Flutter 3.41.
- chore: Update Android SDK to v2.27.1.
- Released on 07/22/26

### 0.8.0
- chore: Update iOS SDK to v4.33.0.
- chore: Update Android SDK to v2.27.0.
- Released on 07/15/26

### 0.7.1
- chore: Update iOS SDK to v4.32.3.
- chore: Update Android SDK to v2.26.2.
- Released on 06/16/26 

### 0.7.0
- chore: Update iOS SDK to v4.32.2.
- chore: Update Android SDK to v2.26.1.
- Released on 06/11/26

### 0.6.0
- chore: Update iOS SDK to v4.30.0.
- chore: Update Android SDK to v2.24.0.
- Released on 04/27/26

### 0.5.0
- chore: Update iOS SDK to v4.29.0.
- chore: Update Android SDK to v2.23.0.
- Released on 04/8/26

### 0.4.0
- chore: Update Android SDK to v2.22.1.
- chore: Update iOS SDK to v4.27.3.
- Released on 03/18/26

### 0.3.3
- chore: Update Android SDK to v2.21.2.
- Released on 02/17/26

### 0.3.2
- chore: Update iOS SDK to v4.26.2.
- Released on 02/12/26

### 0.3.1
- chore: Update iOS SDK to v4.26.1.
- chore: Update Android SDK to v2.21.0.
- Released on 02/10/26

### 0.3.0
- chore: Update iOS SDK to v4.26.0.
- chore: Update Android SDK to v2.20.0.
- add: Added ability to pause and unpause surveys.
- Released on 02/4/26

### 0.2.1
- fix: Aligned iOS version to 16.0 for the example app and .podspec.
- Released on 01/16/26

### 0.2.0
- add: Added ability to programmatically dismiss the active survey.
- Released on 01/15/26

### 0.1.4
- chore: Update iOS SDK to v4.25.2.
- chore: Update Android SDK to v2.19.5.
- Released on 12/29/25

### 0.1.3
- chore: Update iOS SDK to v4.25.1.
- fix: Fix for trackWithProperties call failing to show survey. 
- Released on 11/5/25

### 0.1.2
- add: Android support.
- Released on 11/3/25

### 0.1.1
- fix: Fix for issue with registered lifecycle events. 
- Released on 10/10/25

### 0.1.0
- add: Initial release of the Sprig Flutter plugin.
- Released on 09/25/25