import 'dart:io';

import 'package:breath/breath.dart';
import 'package:super_annotations/super_annotations.dart';

class SerializableAnnotation extends ClassAnnotation {
  const SerializableAnnotation();

  int getTypeId(String componentName) {
    final file = File('id_generator.txt');
    if (!file.existsSync()) {
      file.createSync();
    }

    final lines = file.readAsLinesSync();
    if (!lines.contains(componentName)) {
      file.writeAsStringSync(
        '$componentName${Platform.lineTerminator}',
        mode: FileMode.append,
        flush: true,
      );
    }

    return lines.indexOf(componentName);
  }

  @override
  void apply(Class target, LibraryBuilder output) {
    final typeId = getTypeId(target.name);

    final byteMaps = target.fields
        .where((field) =>
            field.resolvedAnnotationsOfType<DataProtocol>().isNotEmpty)
        .map(
          (field) => (
            field.resolvedAnnotationsOfType<DataProtocol>().first.dataType,
            field
          ),
        );

    final typeParameter = (target.extend! as TypeReference).types.first;

    // TODO remove unnecessary type parameters
    final className = target.name.substring(1);

    output.body.add(Class((e) => e
      ..name = className
      ..extend = refer(target.name)
      ..fields.add(
        Field(
          (f) => f
            ..name = 'builder'
            ..static = true
            ..type = refer('NetBuilder<$className>')
            ..assignment = refer('NetBuilder<$className>').newInstance([], {
              'typeId': literalNum(typeId),
              'add': Method(
                (b) => b
                  ..requiredParameters.add(
                    Parameter((p) => p..name = 'entity'),
                  )
                  ..body = refer('entity')
                      .property('add<$className, ${typeParameter.symbol}>')
                      .call([]).code,
              ).closure,
              'get': Method(
                (b) => b
                  ..requiredParameters.add(
                    Parameter((p) => p..name = 'entity'),
                  )
                  ..body = refer('entity').property('get<$className>()!').code,
              ).closure
            }).code,
        ),
      )
      ..methods.addAll([
        Method(
          (m) => m
            ..name = 'typeId'
            ..type = MethodType.getter
            ..returns = refer('int')
            ..annotations.add(refer('override'))
            ..body = literalNum(typeId).code,
        ),
        Method.returnsVoid(
          (m) => m
            ..name = 'writeBytes'
            ..annotations.add(refer('override'))
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'writer'
                  ..type = refer('ByteBufferWriter'),
              ),
            )
            ..body = Block.of(
              [
                for (final entry in byteMaps)
                  switch (entry.$1) {
                    DataType.int8 => entry.$2.type?.symbol == 'double'
                        ? refer('writer.writeInt8').call([
                            refer(entry.$2.name).property('toInt').call([])
                          ]).statement
                        : refer('writer.writeInt8')
                            .call([refer(entry.$2.name)]).statement,
                    DataType.int16 => entry.$2.type?.symbol == 'double'
                        ? refer('writer.writeInt16').call([
                            refer(entry.$2.name).property('toInt').call([])
                          ]).statement
                        : refer('writer.writeInt16')
                            .call([refer(entry.$2.name)]).statement,
                    DataType.bool => refer('writer.writeBooleans')
                        .call([refer(entry.$2.name)]).statement
                  },
              ],
            ),
        ),
        Method.returnsVoid((m) => m
          ..name = 'readBytes'
          ..annotations.add(refer('override'))
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = 'reader'
                ..type = refer('ByteBufferReader'),
            ),
          )
          ..body = Block.of([
            for (final entry in byteMaps)
              switch (entry.$1) {
                DataType.int8 => entry.$2.type?.symbol == 'double'
                    ? refer(entry.$2.name)
                        .assign(refer('reader.readInt8')
                            .call([])
                            .property('toDouble')
                            .call([]))
                        .statement
                    : refer(entry.$2.name)
                        .assign(refer('reader.readInt8').call([]))
                        .statement,
                DataType.int16 => entry.$2.type?.symbol == 'double'
                    ? refer(entry.$2.name)
                        .assign(refer('reader.readInt16')
                            .call([])
                            .property('toDouble')
                            .call([]))
                        .statement
                    : refer(entry.$2.name)
                        .assign(refer('reader.readInt16').call([]))
                        .statement,
                DataType.bool => refer(entry.$2.name)
                    .assign(
                        refer('reader.readBooleans').call([]).property(r'$1'))
                    .statement,
              }
          ]))
      ])));
  }
}
