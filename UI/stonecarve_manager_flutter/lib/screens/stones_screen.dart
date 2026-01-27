import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/stone.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';

class StonesScreen extends StatefulWidget {
  const StonesScreen({super.key});

  @override
  State<StonesScreen> createState() => _StonesScreenState();
}

class _StonesScreenState extends State<StonesScreen> {
  final StoneProvider _stoneProvider = StoneProvider();
  List<Stone> _stones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStones();
  }

  Future<void> _loadStones() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _stoneProvider.get();
      setState(() {
        _stones = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stones: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Stones',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stone Inventory',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement add stone functionality
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Stone'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _stones.isEmpty
                  ? const Center(child: Text('No stones found'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _stones.length,
                      itemBuilder: (context, index) {
                        final stone = _stones[index];
                        return Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.terrain, size: 40),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        stone.name ?? 'Unknown Stone',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Type: ${stone.type ?? 'N/A'}'),
                                Text('Origin: ${stone.origin ?? 'N/A'}'),
                                Text('Color: ${stone.color ?? 'N/A'}'),
                                Text(
                                  'Price: \$${stone.pricePerUnit?.toStringAsFixed(2) ?? '0.00'}/${stone.unit ?? 'unit'}',
                                ),
                                Text(
                                  'Available: ${stone.availableQuantity ?? 0}',
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // TODO: Implement edit functionality
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // TODO: Implement delete functionality
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
