# sprig_flutter_plugin_example

This example Flutter application demonstrates how to use the Sprig Flutter plugin (sprig_flutter_plugin).

Refer to [our Plugin documentation](https://docs.sprig.com/docs/flutter-plugin) for more details about Sprig and the Sprig Flutter plugin.

## Getting Started

Use this example Flutter application as a reference when integrating Sprig into your own Flutter application.

Follow the steps below in order to run the example app. 

In a CLI that has a path to your installed Flutter SDK, navigate to the root of this repository and then type the following commands:

    flutter pub get 
    cd ios
    pod repo update
    pod install
    
Once the pods are installed, you should be able to open the workspace file (Runner.xcworkspace) in Xcode, which will be located in the same iOS directory. You should then be able to run the *Runner* target, with the app launching in the simulator. 

Alternatively, you can launch the app in a simulator from within Visual Studio Code by selecting the main.dart file in the project and tapping the debugger icon when it displays.

In order to get the SDK properly initialized and to display a survey, in the lib/main.dart file: 
- Replace the <your_environment_id> placeholder in the lib/main.dart file with your Sprig environment ID.
- Replace the <your_event_name> placeholder in order to trigger a survey by event.

Replace the other placeholders in the main.dart file to explore more functionality.
