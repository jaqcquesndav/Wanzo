import 'package:hive/hive.dart';
import '../models/adha_message.dart';

/// Adaptateur Hive pour AdhaMessage
class AdhaMessageAdapter extends TypeAdapter<AdhaMessage> {
  @override
  final int typeId = 100;

  @override
  AdhaMessage read(BinaryReader reader) {
    final id = reader.readString();
    final content = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final isUserMessage = reader.readBool();
    final typeIndex = reader.readInt();
    
    return AdhaMessage(
      id: id,
      content: content,
      timestamp: timestamp,
      isUserMessage: isUserMessage,
      type: AdhaMessageType.values[typeIndex],
    );
  }

  @override
  void write(BinaryWriter writer, AdhaMessage obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isUserMessage);
    writer.writeInt(obj.type.index);
  }
}

/// Adaptateur Hive pour AdhaMessageType
class AdhaMessageTypeAdapter extends TypeAdapter<AdhaMessageType> {
  @override
  final int typeId = 101;

  @override
  AdhaMessageType read(BinaryReader reader) {
    return AdhaMessageType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, AdhaMessageType obj) {
    writer.writeInt(obj.index);
  }
}

/// Adaptateur Hive pour AdhaConversation
class AdhaConversationAdapter extends TypeAdapter<AdhaConversation> {
  @override
  final int typeId = 102;

  @override
  AdhaConversation read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final messagesLength = reader.readInt();
    
    final messages = <AdhaMessage>[];
    for (var i = 0; i < messagesLength; i++) {
      messages.add(reader.read() as AdhaMessage);
    }
    
    return AdhaConversation(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messages: messages,
    );
  }

  @override
  void write(BinaryWriter writer, AdhaConversation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeInt(obj.messages.length);
    
    for (var message in obj.messages) {
      writer.write(message);
    }
  }
}
