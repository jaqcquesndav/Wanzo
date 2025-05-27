import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanzo/core/shared_widgets/wanzo_scaffold.dart';
import 'package:wanzo/features/customer/bloc/customer_bloc.dart';
import 'package:wanzo/features/customer/bloc/customer_event.dart';
import 'package:wanzo/features/customer/screens/customers_screen.dart';
import 'package:wanzo/features/supplier/bloc/supplier_bloc.dart';
import 'package:wanzo/features/supplier/bloc/supplier_event.dart';
import 'package:wanzo/features/supplier/screens/suppliers_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wanzo/l10n/generated/app_localizations.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VoidCallback? _tabListener;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    context.read<CustomerBloc>().add(const LoadCustomers());
    context.read<SupplierBloc>().add(const LoadSuppliers());

    _tabListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _tabController.addListener(_tabListener!);
  }

  @override
  void dispose() {
    if (_tabListener != null) {
      _tabController.removeListener(_tabListener!);
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int contactsPageIndex = 3; 
    final localizations = AppLocalizations.of(context)!;

    return WanzoScaffold(
      currentIndex: contactsPageIndex,
      title: localizations.contactsScreenTitle,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: const Icon(Icons.person), text: localizations.contactsScreenClientsTab),
              Tab(icon: const Icon(Icons.business), text: localizations.contactsScreenSuppliersTab),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CustomersScreen(isEmbedded: true),
                SuppliersScreen(isEmbedded: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            context.push('/customers/add');
          } else {
            context.push('/suppliers/add');
          }
        },
        tooltip: _tabController.index == 0 ? localizations.contactsScreenAddClientTooltip : localizations.contactsScreenAddSupplierTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
