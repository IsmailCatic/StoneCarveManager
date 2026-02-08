import 'package:flutter/material.dart';

class ProductStateChip extends StatelessWidget {
  final String? state;

  const ProductStateChip({Key? key, this.state}) : super(key: key);

  Color _getStateColor() {
    switch (state?.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'service':
        return Colors.blue;
      case 'portfolio':
        return Colors.purple;
      case 'hidden':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStateIcon() {
    switch (state?.toLowerCase()) {
      case 'draft':
        return Icons.edit;
      case 'active':
        return Icons.check_circle;
      case 'service':
        return Icons.build;
      case 'portfolio':
        return Icons.star;
      case 'hidden':
        return Icons.visibility_off;
      default:
        return Icons.help;
    }
  }

  String _getStateLabel() {
    switch (state?.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'active':
        return 'Aktivan';
      case 'service':
        return 'Usluga';
      case 'portfolio':
        return 'Portfolio';
      case 'hidden':
        return 'Sakriven';
      default:
        return state ?? 'Nepoznato';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStateColor();

    return Chip(
      avatar: Icon(_getStateIcon(), color: Colors.white, size: 18),
      label: Text(
        _getStateLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      elevation: 2,
    );
  }
}
