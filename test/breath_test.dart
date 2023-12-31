import 'package:breath/breath.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    group('Booleans', () {
      late ByteData byteData;

      setUp(() {
        byteData = ByteData(1024);
      });

      test('it returns passed & default values', () {
        final writer = ByteBufferWriter(byteData);
        writer.writeBooleans(true);

        final reader = ByteBufferReader(byteData);
        final booleans = reader.readBooleans();

        expect(
          booleans,
          (true, false, false, false, false, false, false, false),
        );
      });

      test('it returns passed values for all booleans', () {
        final writer = ByteBufferWriter(byteData);
        writer.writeBooleans(false, true, true, true, true, true, true, true);

        final reader = ByteBufferReader(byteData);
        final booleans = reader.readBooleans();

        expect(
          booleans,
          (false, true, true, true, true, true, true, true),
        );
      });
    });
  });
}
