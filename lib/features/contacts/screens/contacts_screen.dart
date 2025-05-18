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

    return WanzoScaffold(
      currentIndex: contactsPageIndex,
      title: 'Contacts',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Clients'),
              Tab(icon: Icon(Icons.business), text: 'Fournisseurs'),
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
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'Ajouter un client' : 'Ajouter un fournisseur',
      ),
    );
  }
}
