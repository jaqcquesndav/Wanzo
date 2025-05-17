import 'package:equatable/equatable.dart';

/// Modèle représentant un secteur d'activité pour une entreprise
class BusinessSector extends Equatable {
  /// Identifiant unique du secteur
  final String id;
  
  /// Nom du secteur d'activité
  final String name;
  
  /// Description du secteur
  final String description;
  
  /// Icône représentant le secteur
  final String icon;
  
  /// Constructeur
  const BusinessSector({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'business',
  });
  
  @override
  List<Object?> get props => [id, name, description, icon];
}

/// Liste des secteurs d'activité courants en Afrique
final List<BusinessSector> africanBusinessSectors = [
  const BusinessSector(
    id: 'agriculture',
    name: 'Agriculture et agroalimentaire',
    description: 'Production agricole, transformation alimentaire, élevage',
    icon: 'agriculture',
  ),
  const BusinessSector(
    id: 'commerce',
    name: 'Commerce et distribution',
    description: 'Vente au détail, distribution, import-export',
    icon: 'store',
  ),
  const BusinessSector(
    id: 'services',
    name: 'Services',
    description: 'Services aux entreprises et aux particuliers',
    icon: 'business_center',
  ),
  const BusinessSector(
    id: 'technology',
    name: 'Technologies et innovation',
    description: 'Développement informatique, télécommunications, fintech',
    icon: 'computer',
  ),
  const BusinessSector(
    id: 'manufacturing',
    name: 'Manufacture et industrie',
    description: 'Production industrielle, artisanat, textile',
    icon: 'factory',
  ),
  const BusinessSector(
    id: 'construction',
    name: 'Construction et immobilier',
    description: 'BTP, promotion immobilière, architecture',
    icon: 'construction',
  ),
  const BusinessSector(
    id: 'transportation',
    name: 'Transport et logistique',
    description: 'Transport de marchandises, logistique, entreposage',
    icon: 'local_shipping',
  ),
  const BusinessSector(
    id: 'energy',
    name: 'Énergie et ressources naturelles',
    description: 'Production d\'énergie, mines, eau',
    icon: 'bolt',
  ),
  const BusinessSector(
    id: 'tourism',
    name: 'Tourisme et hôtellerie',
    description: 'Hôtellerie, restauration, tourisme',
    icon: 'hotel',
  ),
  const BusinessSector(
    id: 'education',
    name: 'Éducation et formation',
    description: 'Enseignement, formation professionnelle',
    icon: 'school',
  ),
  const BusinessSector(
    id: 'health',
    name: 'Santé et services médicaux',
    description: 'Soins médicaux, pharmacie, équipements médicaux',
    icon: 'local_hospital',
  ),
  const BusinessSector(
    id: 'finance',
    name: 'Services financiers',
    description: 'Banque, assurance, microfinance',
    icon: 'account_balance',
  ),
  const BusinessSector(
    id: 'other',
    name: 'Autre',
    description: 'Autres secteurs d\'activité',
    icon: 'category',
  ),
];
