import 'package:flutter/foundation.dart';
import 'package:stonecarve_manager_mobile/models/cart.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  ShippingAddress? _shippingAddress;
  bool _paymentReady = false;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  double get shippingCost => 0.0; // Free shipping for now
  double get tax => subtotal * 0.075; // 7.5% tax
  double get total => subtotal + shippingCost + tax;

  ShippingAddress? get shippingAddress => _shippingAddress;
  bool get hasShippingAddress => _shippingAddress != null;
  bool get paymentReady => _paymentReady;

  void addItem(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          productId: product.id!,
          productName: product.name ?? 'Unknown Product',
          price: product.price ?? 0.0,
          imageUrl: product.images?.isNotEmpty == true
              ? product.images!.first.imageUrl
              : null,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _shippingAddress = null;
    _paymentReady = false;
    notifyListeners();
  }

  void setShippingAddress(ShippingAddress address) {
    _shippingAddress = address;
    notifyListeners();
  }

  void setPaymentReady(bool ready) {
    _paymentReady = ready;
    notifyListeners();
  }
}
