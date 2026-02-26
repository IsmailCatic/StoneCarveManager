import 'package:flutter/material.dart';
import '../providers/product_provider.dart';

class ProductActionButtons extends StatefulWidget {
  final int productId;
  final String currentState;
  final VoidCallback onActionCompleted;

  const ProductActionButtons({
    Key? key,
    required this.productId,
    required this.currentState,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  State<ProductActionButtons> createState() => _ProductActionButtonsState();
}

class _ProductActionButtonsState extends State<ProductActionButtons> {
  List<String> _allowedActions = [];
  bool _loading = true;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadAllowedActions();
  }

  Future<void> _loadAllowedActions() async {
    try {
      final provider = ProductProvider();
      final actions = await provider.getAllowedActions(widget.productId);
      print('🎯 [ProductActionButtons] Product ID: ${widget.productId}');
      print('🎯 [ProductActionButtons] Current State: ${widget.currentState}');
      print('🎯 [ProductActionButtons] Allowed Actions: $actions');
      setState(() {
        _allowedActions = actions;
        _loading = false;
      });
    } catch (e) {
      print('❌ Error loading allowed actions: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _performAction(
    String action,
    Future<void> Function() apiCall,
  ) async {
    setState(() {
      _actionInProgress = true;
    });

    try {
      await apiCall();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onActionCompleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionInProgress = false;
        });
      }
    }
  }

  Widget _buildActionButton(String action, IconData icon, Color color) {
    final provider = ProductProvider();

    switch (action) {
      case 'Activate':
        return ElevatedButton.icon(
          onPressed: _actionInProgress
              ? null
              : () => _performAction(
                  'Activation',
                  () => provider.activateProduct(widget.productId),
                ),
          icon: Icon(icon),
          label: const Text('Activate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        );
      case 'Hide':
        return ElevatedButton.icon(
          onPressed: _actionInProgress
              ? null
              : () => _performAction(
                  'Hiding',
                  () => provider.hideProduct(widget.productId),
                ),
          icon: Icon(icon),
          label: const Text('Hide'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        );
      case 'MakeService':
        return ElevatedButton.icon(
          onPressed: _actionInProgress
              ? null
              : () => _performAction(
                  'Convert to Service',
                  () => provider.makeService(widget.productId),
                ),
          icon: Icon(icon),
          label: const Text('Make Service'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        );
      case 'AddToPortfolio':
        return ElevatedButton.icon(
          onPressed: _actionInProgress
              ? null
              : () => _performAction(
                  'Add to Portfolio',
                  () => provider.addToPortfolio(widget.productId),
                ),
          icon: Icon(icon),
          label: const Text('Add to Portfolio'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current State Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Current state: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    widget.currentState.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Available Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_allowedActions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No available actions for current state',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_allowedActions.contains('Activate'))
                    _buildActionButton(
                      'Activate',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  if (_allowedActions.contains('Hide'))
                    _buildActionButton(
                      'Hide',
                      Icons.visibility_off,
                      Colors.orange,
                    ),
                  if (_allowedActions.contains('MakeService'))
                    _buildActionButton('MakeService', Icons.build, Colors.blue),
                  if (_allowedActions.contains('AddToPortfolio'))
                    _buildActionButton(
                      'AddToPortfolio',
                      Icons.star,
                      Colors.purple,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
