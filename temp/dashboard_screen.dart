import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ignore: avoid_relative_lib_imports
import '../lib/constants/constants.dart';
import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';

/// Écran principal du tableau de bord
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      currentIndex: 0, // Dashboard = index 0
      title: 'Tableau de bord',
      body: _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Afficher un menu d'actions rapides
          _showQuickActionsMenu(context);
        },
        backgroundColor: WanzoColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// Afficher le menu d'actions rapides
  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(WanzoSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: WanzoTypography.fontSizeLg,
                    fontWeight: WanzoTypography.fontWeightBold,
                  ),
                ),
                const SizedBox(height: WanzoSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.shopping_cart_checkout,
                      label: 'Nouvelle vente',
                      color: WanzoColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/sales/add');
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_shopping_cart,
                      label: 'Nouveau produit',
                      color: WanzoColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/inventory/add');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: WanzoSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.person_add,
                      label: 'Nouveau client',
                      color: WanzoColors.info,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementer la création de client
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Création de client sera bientôt disponible')),
                        );
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.attach_money,
                      label: 'Dépense',
                      color: WanzoColors.warning,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementer l'ajout de dépense
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajout de dépense sera bientôt disponible')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Construire une action rapide
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WanzoBorderRadius.lg),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(WanzoSpacing.md),
              decoration: BoxDecoration(
                color: color.withAlpha(26), // Fixed: Changed from withOpacity(0.1)
                borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: WanzoSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: WanzoTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le contenu du tableau de bord
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(WanzoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec les statistiques principales
          _buildHeaderStats(),
          const SizedBox(height: WanzoSpacing.lg),
          
          // Graphique des ventes récentes
          _buildSalesChart(),
          const SizedBox(height: WanzoSpacing.lg),
          
          // Dernières ventes et produits faibles en stock
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildRecentSales(),
              ),
              const SizedBox(width: WanzoSpacing.md),
              Expanded(
                flex: 2,
                child: _buildLowStockProducts(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit les statistiques d'en-tête
  Widget _buildHeaderStats() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: WanzoSpacing.md,
      mainAxisSpacing: WanzoSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Ventes du jour',
          value: '150.000 FC',
          icon: Icons.insert_chart,
          color: WanzoColors.primary,
          increase: '+8% vs hier',
        ),
        _buildStatCard(
          title: 'Clients servis',
          value: '24',
          icon: Icons.people,
          color: WanzoColors.info,
          increase: '+3 vs hier',
        ),
        _buildStatCard(
          title: 'Produits faibles',
          value: '8',
          icon: Icons.warning_amber,
          color: WanzoColors.warning,
        ),
        _buildStatCard(
          title: 'À recevoir',
          value: '450.000 FC',
          icon: Icons.account_balance_wallet,
          color: WanzoColors.success,
        ),
      ],
    );
  }

  /// Construit une carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? increase,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: WanzoTypography.fontSizeSm,
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: WanzoTypography.fontSizeLg,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            if (increase != null)
              Text(
                increase,
                style: TextStyle(
                  fontSize: WanzoTypography.fontSizeXs,
                  color: increase.contains('+') ? WanzoColors.success : WanzoColors.error,
                  fontWeight: WanzoTypography.fontWeightMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit un graphique des ventes récentes (placeholder)
  Widget _buildSalesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperçu des ventes',
              style: TextStyle(
                fontSize: WanzoTypography.fontSizeLg,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: WanzoSpacing.md),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Graphique à implémenter',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la liste des ventes récentes
  Widget _buildRecentSales() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dernières ventes',
              style: TextStyle(
                fontSize: WanzoTypography.fontSizeMd,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: WanzoSpacing.md),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Vente #${1000 + index}'),
                  subtitle: Text('${(index + 1) * 15000} FC - ${DateTime.now().subtract(Duration(hours: index)).hour}:00'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Ouvrir le détail de la vente
                  },
                );
              },
            ),
            const SizedBox(height: WanzoSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () {
                  // Naviguer vers l'écran des ventes
                  context.push('/sales');
                },
                child: const Text('Voir toutes les ventes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la liste des produits faibles en stock
  Widget _buildLowStockProducts() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock faible',
              style: TextStyle(
                fontSize: WanzoTypography.fontSizeMd,
                fontWeight: WanzoTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: WanzoSpacing.md),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final products = [
                  'Farine de maïs',
                  'Huile végétale',
                  'Sucre',
                  'Riz',
                  'Savon'
                ];
                final quantities = [5, 3, 8, 2, 4];
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(products[index]),
                  subtitle: Text('Reste: ${quantities[index]} unités'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Naviguer vers l'écran d'inventaire
                      context.push('/inventory');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WanzoColors.warning,
                      padding: const EdgeInsets.symmetric(
                        horizontal: WanzoSpacing.md,
                        vertical: WanzoSpacing.xs,
                      ),
                    ),
                    child: const Text('Commander'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Classe représentant un élément de navigation
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}
