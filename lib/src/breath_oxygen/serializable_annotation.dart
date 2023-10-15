import 'package:breath/breath.dart';
import 'package:super_annotations/super_annotations.dart';

class SerializableAnnotation extends ClassAnnotation {
  const SerializableAnnotation();
  @override
  void apply(Class target, LibraryBuilder output) {
    final byteMaps = target.fields
        .where((field) =>
            field.resolvedAnnotationsOfType<DataProtocol>().isNotEmpty)
        .map(
          (field) => (
            field.resolvedAnnotationsOfType<DataProtocol>().first.dataType,
            field
          ),
        );

    output.body.addAll(
      [
        Extension(
          (e) => e
            ..name = '${target.name}Extension'
            ..on = refer(target.name)
            ..methods.addAll(
              [
                Method.returnsVoid(
                  (m) => m
                    ..name = 'writeBytes'
                    ..requiredParameters.add(
                      Parameter(
                        (p) => p
                          ..name = 'buffer'
                          ..type = refer('ByteBufferWriter'),
                      ),
                    )
                    ..body = Block.of(
                      [
                        for (final entry in byteMaps)
                          switch (entry.$1) {
                            DataType.int8 => entry.$2.type?.symbol == 'int'
                                ? refer('buffer.writeInt8')
                                    .call([refer(entry.$2.name)]).statement
                                : throw 'Not an integer > ${entry.$2.type?.symbol}',
                            DataType.int16 => entry.$2.type?.symbol == 'int'
                                ? refer('buffer.writeInt16')
                                    .call([refer(entry.$2.name)]).statement
                                : throw 'Not an integer > ${entry.$2.type?.symbol}',
                            DataType.bool => entry.$2.type?.symbol == 'bool'
                                ? refer('buffer.writeBooleans')
                                    .call([refer(entry.$2.name)]).statement
                                : throw 'Not a bool > ${entry.$2.type?.symbol}',
                          },
                      ],
                    ),
                ),
                Method.returnsVoid(
                  (m) => m
                    ..name = 'readBytes'
                    ..requiredParameters.add(
                      Parameter(
                        (p) => p
                          ..name = 'buffer'
                          ..type = refer('ByteBufferReader'),
                      ),
                    )
                    ..body = Block.of(
                      [
                        for (final entry in byteMaps)
                          switch (entry.$1) {
                            DataType.int8 => refer(entry.$2.name)
                                .assign(refer('buffer.readInt8').call([]))
                                .statement,
                            DataType.int16 => refer(entry.$2.name)
                                .assign(refer('buffer.readInt16').call([]))
                                .statement,
                            DataType.bool => refer(entry.$2.name)
                                .assign(refer('buffer.readBooleans')
                                    .call([]).property(r'$1'))
                                .statement,
                          },
                      ],
                    ),
                ),
              ],
            ),
        ),
      ],
    );
  }
}
