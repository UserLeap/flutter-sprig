import 'package:flutter_test/flutter_test.dart';
import 'package:sprig_flutter_plugin/sprig_flutter_plugin.dart';
import 'package:sprig_flutter_plugin/sprig_flutter_plugin_platform_interface.dart';
import 'package:sprig_flutter_plugin/sprig_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSprigFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements SprigFlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SprigFlutterPluginPlatform initialPlatform = SprigFlutterPluginPlatform.instance;

  test('$MethodChannelSprigFlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSprigFlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    SprigFlutterPlugin sprigFlutterPlugin = SprigFlutterPlugin();
    MockSprigFlutterPluginPlatform fakePlatform = MockSprigFlutterPluginPlatform();
    SprigFlutterPluginPlatform.instance = fakePlatform;

    expect(await sprigFlutterPlugin.getPlatformVersion(), '42');
  });
}
