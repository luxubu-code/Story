import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/subscription_service.dart';
import '../../../models/subscription.dart';

class VipManagementScreen extends StatefulWidget {
  const VipManagementScreen({Key? key}) : super(key: key);

  @override
  State<VipManagementScreen> createState() => _VipManagementScreenState();
}

class _VipManagementScreenState extends State<VipManagementScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  Subscription? _currentSubscription;
  List<Subscription> _subscriptionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      setState(() => _isLoading = true);

      // Load current subscription and history in parallel
      final results = await Future.wait([
        _subscriptionService.getCurrentSubscription(),
        _subscriptionService.getSubscriptionHistory(),
      ]);

      setState(() {
        _currentSubscription = results[0] as Subscription?;
        _subscriptionHistory = results[1] as List<Subscription>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading subscription data: ${e.toString()}')),
      );
    }
  }

  Widget _buildCurrentSubscription() {
    if (_currentSubscription == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No active subscription'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Subscription',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Package: ${_currentSubscription!.package!.name}'),
            Text('Status: ${_currentSubscription!.status}'),
            Text(
              'Valid until: ${DateFormat('dd/MM/yyyy').format(_currentSubscription!.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subscriptionHistory.length,
              itemBuilder: (context, index) {
                final subscription = _subscriptionHistory[index];
                return ListTile(
                  title: Text(subscription.package!.name),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(subscription.startDate)} - '
                    '${DateFormat('dd/MM/yyyy').format(subscription.endDate)}',
                  ),
                  trailing: Text(subscription.status),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscriptionData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSubscriptionData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentSubscription(),
                    const SizedBox(height: 16),
                    _buildSubscriptionHistory(),
                  ],
                ),
              ),
            ),
    );
  }
}
