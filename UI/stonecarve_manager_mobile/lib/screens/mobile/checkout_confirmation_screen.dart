import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/providers/payment_provider.dart';
import 'package:stonecarve_manager_mobile/providers/order_provider.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  bool _isProcessing = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndCompletePurchase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 10),
            Text('Confirm Purchase'),
          ],
        ),
        content: const Text(
          'Are you sure you want to complete this purchase? Your card will be charged and the order will be placed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Confirm & Pay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _completePurchase();
    }
  }

  Future<void> _completePurchase() async {
    setState(() => _isProcessing = true);

    try {
      final cartProvider = context.read<CartProvider>();

      if (cartProvider.items.isEmpty) {
        throw Exception('Cart is empty');
      }

      if (!cartProvider.hasShippingAddress) {
        throw Exception('Shipping address is required');
      }

      // 1. Create Order first
      // Note: userId is NOT sent - backend extracts it from JWT token in Authorization header
      final shippingAddress = cartProvider.shippingAddress!;
      final notes = _notesController.text.trim();
      final createOrderRequest = CreateOrderRequest(
        orderItems: cartProvider.items
            .map(
              (item) => CreateOrderItemRequest(
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.price,
              ),
            )
            .toList(),
        deliveryAddress: shippingAddress.address,
        deliveryCity: shippingAddress.city,
        deliveryZipCode: shippingAddress.zipCode,
        deliveryCountry: shippingAddress.country,
        deliveryState: shippingAddress.state,
        clientName: shippingAddress.fullName,
        clientEmail: shippingAddress.email,
        customerNotes: notes.isEmpty ? null : notes,
      );

      print('[Checkout] Creating order...');
      final order = await OrderProvider.createNewOrder(createOrderRequest);
      print('[Checkout] Order created with ID: ${order.id}');

      // 2. Create Payment Intent
      print('[Checkout] Creating payment intent...');
      final paymentIntent = await PaymentProvider.createPaymentIntent(
        orderId: order.id,
        paymentMethod: 'stripe',
        customerEmail: shippingAddress.email,
        customerName: shippingAddress.fullName,
      );

      print('[Checkout] Payment intent created: ${paymentIntent.id}');
      print(
        '[Checkout] Client secret received: ${paymentIntent.clientSecret?.substring(0, 20)}...',
      );

      if (paymentIntent.clientSecret == null) {
        throw Exception('Payment intent client secret is missing');
      }

      // 3. Confirm Payment with Stripe SDK
      // This is where the actual payment happens client-side
      print('[Checkout] Confirming payment with Stripe...');

      try {
        // Stripe SDK will use the card details entered in the CardField
        // on the previous screen (checkout_payment_screen.dart)
        final confirmedIntent = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: paymentIntent.clientSecret!,
          data: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );

        print(
          '[Checkout] Stripe confirmation successful: ${confirmedIntent.status}',
        );
      } on StripeException catch (e) {
        print('[Checkout] Stripe error: ${e.error.message}');

        // Even if Stripe SDK fails, the backend might auto-confirm in test mode
        // Let's still try to confirm with backend
        print(
          '[Checkout] Attempting backend confirmation despite Stripe error...',
        );
      }

      // 4. Confirm with backend to update database
      // The backend will check Stripe's payment intent status and update accordingly
      print('[Checkout] Confirming with backend...');
      final payment = await PaymentProvider.confirmPayment(
        paymentIntentId: paymentIntent.id!,
        orderId: order.id,
      );

      print(
        '[Checkout] Backend confirmation complete. Payment status: ${payment.status}',
      );

      if (payment.status == 'succeeded') {
        // Payment successful!
        cartProvider.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Purchase completed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to order success screen or home
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        // Payment failed or pending
        throw Exception(
          'Payment ${payment.status}: ${payment.failureReason ?? "Unknown error"}',
        );
      }
    } catch (e) {
      print('[Checkout] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Steps
                  Row(
                    children: [
                      _buildStep(1, '', true),
                      Expanded(child: Container(height: 2, color: Colors.blue)),
                      _buildStep(2, '', true),
                      Expanded(child: Container(height: 2, color: Colors.blue)),
                      _buildStep(3, 'Confirmation', true),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Cart Items
                  ...cart.items.map((item) => _buildCartItem(item)).toList(),

                  const Divider(height: 40),

                  // Customer Notes
                  const Text(
                    'Order Notes (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Any special instructions or requests...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Summary
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'VAT (17%)',
                    '\$${(cart.subtotal * 0.17).toStringAsFixed(2)}',
                    isVat: true,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total (incl. VAT)',
                    '\$${(cart.subtotal * 1.17).toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 40),

                  // Complete Purchase Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : _confirmAndCompletePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Complete purchase',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey[400]);
                      },
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Quantity and Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity} →',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isVat = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isVat ? Colors.grey[600] : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? Colors.blue
                : (isVat ? Colors.grey[600] : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
      child: Center(
        child: label.isNotEmpty
            ? Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
            : Text(
                number.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
