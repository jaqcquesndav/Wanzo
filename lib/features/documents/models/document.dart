import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'document.g.dart';

/// Type de document
enum DocumentType {
  invoice,     // Facture
  receipt,     // Reçu
  quote,       // Devis
  contract,    // Contrat
  report,      // Rapport
  other,       // Autre
}

/// Modèle représentant un document
@HiveType(typeId: 31)
class Document extends Equatable {
  /// Identifiant unique du document
  @HiveField(0)
  final String id;
  
  /// Titre du document
  @HiveField(1)
  final String title;
  
  /// Type de document
  @HiveField(2)
  final DocumentType type;
  
  /// Date de création
  @HiveField(3)
  final DateTime creationDate;
  
  /// Chemin du fichier sur le disque
  @HiveField(4)
  final String filePath;
  
  /// Identifiant de l'entité associée (ex: ID de vente, ID de client, etc.)
  @HiveField(5)
  final String? relatedEntityId;
  
  /// Type de l'entité associée (ex: "sale", "customer", etc.)
  @HiveField(6)
  final String? relatedEntityType;
  
  /// Description du document
  @HiveField(7)
  final String? description;
  
  /// Taille du document en octets
  @HiveField(8)
  final int? fileSize;
  
  /// Constructeur
  const Document({
    required this.id,
    required this.title,
    required this.type,
    required this.creationDate,
    required this.filePath,
    this.relatedEntityId,
    this.relatedEntityType,
    this.description,
    this.fileSize,
  });
  
  /// Crée une copie de ce document avec les champs donnés remplacés par les nouvelles valeurs
  Document copyWith({
    String? id,
    String? title,
    DocumentType? type,
    DateTime? creationDate,
    String? filePath,
    String? relatedEntityId,
    String? relatedEntityType,
    String? description,
    int? fileSize,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      creationDate: creationDate ?? this.creationDate,
      filePath: filePath ?? this.filePath,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      description: description ?? this.description,
      fileSize: fileSize ?? this.fileSize,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    type,
    creationDate,
    filePath,
    relatedEntityId,
    relatedEntityType,
    description,
    fileSize,
  ];
}
