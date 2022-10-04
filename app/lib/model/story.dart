import 'dart:convert';

import 'package:mnmn/ui/all.dart';

class Story {
  const Story(
    this.items, {
    this.position,
  });

  factory Story.fromMap(Map<String, dynamic> story) {
    final items = <StoryItem>[
      for (final Map<dynamic, dynamic> item in story['items'])
        StoryItem(
          type: StoryItemTypeStringExtension.fromString(item['type'] as String),
          value: item['value'] as String?,
        )
          ..image = item['imageUrl'] == null ? null : uploadedImage(item['imageUrl'] as String)
          ..imageUrl = item['imageUrl'] as String?
          ..position = Offset(
            ((item['position'] as List<dynamic>)[0] as num).toDouble(),
            ((item['position'] as List<dynamic>)[1] as num).toDouble(),
          )
          ..scale = (item['scale'] as num).toDouble()
          ..rotation = (item['rotation'] as num).toDouble()
          ..color = item['color'] == null
              ? null
              : ColorHexExtension.fromHex(item['color'] as String)
          ..textStyle = item['textStyle'] as int?
          ..fontSize = (item['fontSize'] as num?)?.toDouble()
          ..fontFamily = (item['fontFamily'] as int?)
    ];

    return Story(items);
  }

  final List<StoryItem> items;
  final LatLng? position;

  Map<String, dynamic> _serializeItem(StoryItem item) {
    return <String, dynamic>{
      'position': [item.position.dx, item.position.dy],
      'scale': item.scale,
      'rotation': item.rotation,
      'type': item.type.asString(),
      if (item.imageUrl != null) 'imageUrl': item.imageUrl,
      if (item.imageBytes != null) 'imageBytes': base64Encode(item.imageBytes!),
      if (item.value != null) 'value': item.value,
      if (item.color != null) 'color': item.color!.toHex(),
      if (item.textStyle != null) 'textStyle': item.textStyle,
      if (item.fontSize != null) 'fontSize': item.fontSize,
      if (item.fontFamily != null) 'fontFamily': item.fontFamily,
    };
  }

  List<Map<String, dynamic>> serializeItems() {
    return items.map(_serializeItem).toList();
  }
}
