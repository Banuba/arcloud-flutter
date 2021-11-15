import 'package:banuba_arcloud/src/network_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Check network URIs', () {
    void _testUriList(List<String> uriList, bool expected) {
      for (final String uri in uriList) {
        final actual = isNetworkUri(uri);
        expect(actual, expected);
      }
    }

    test('Check network URI', () {
      const uriList = [
        'https://stackoverflow.com/',
        'https://pub.dev/packages/provider',
        'https://github.com/flutter/flutter/blob/master/README.md',
      ];

      _testUriList(uriList, true);
    });

    test('Check local URI', () {
      const uriList = [
        'file:///mnt/sdcard/myPicture.jpg',
        'file:///sdcard/media/audio/ringtones/GetupGetOut.mp3',
      ];

      _testUriList(uriList, false);
    });

    test('Check invalid URI', () {
      const uriList = [
        '',
      ];

      _testUriList(uriList, false);
    });
  });
}
