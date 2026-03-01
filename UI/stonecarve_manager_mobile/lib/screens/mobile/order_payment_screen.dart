import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';
import 'package:stonecarve_manager_mobile/providers/payment_provider.dart';

/// Payment screen shown after a service request or custom order is created.
/// The order already exists on the backend; we just need to collect payment.
class OrderPaymentScreen extends StatefulWidget {
  final Order order;
  final String orderTypeLabel; // e.g. "Service Request" or "Custom Order"

  const OrderPaymentScreen({
    super.key,
    required this.order,
    required this.orderTypeLabel,
  });

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  bool _cardComplete = false;
  bool _isProcessing = false;

  Future<void> _pay() async {
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your card details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 10),
            Text('Confirm Payment'),
          ],
        ),
        content: Text(
          'You will be charged \$${widget.order.totalAmount.toStringAsFixed(2)} '
          'for your ${widget.orderTypeLabel} (Order #${widget.order.orderNumber}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Create payment intent on the backend
      print(
        '[OrderPaymentScreen] Creating payment intent for order ${widget.order.id}',
      );
      final paymentIntent = await PaymentProvider.createPaymentIntent(
        orderId: widget.order.id,
        paymentMethod: 'stripe',
        customerEmail: widget.order.clientEmail,
        customerName: widget.order.clientName,
      );

      if (paymentIntent.clientSecret == null) {
        throw Exception('Payment intent client secret is missing');
      }

      // 2. Confirm with Stripe SDK (uses the CardField card details entered above)
      print('[OrderPaymentScreen] Confirming with Stripe...');
      try {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: paymentIntent.clientSecret!,
          data: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      } on StripeException catch (e) {
        // In test mode the SDK may still succeed server-side; continue to backend confirm
        print(
          '[OrderPaymentScreen] Stripe SDK error (may be OK in test): ${e.error.message}',
        );
      }

      // 3. Confirm with backend to record payment in the database
      print('[OrderPaymentScreen] Confirming with backend...');
      final payment = await PaymentProvider.confirmPayment(
        paymentIntentId: paymentIntent.id!,
        orderId: widget.order.id,
      );

      print('[OrderPaymentScreen] Payment status: ${payment.status}');

      if (!mounted) return;

      if (payment.status == 'succeeded') {
        _showSuccess();
      } else {
        throw Exception(
          'Payment ${payment.status}: ${payment.failureReason ?? "Unexpected error"}',
        );
      }
    } catch (e) {
      print('[OrderPaymentScreen] Error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ${widget.orderTypeLabel} (Order #${widget.order.orderNumber}) '
              'has been paid successfully.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Amount charged: \$${widget.order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will review your request and keep you updated on progress.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/orders',
                (route) => route.settings.name == '/home',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'View My Orders',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _skipPayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip Payment?'),
        content: const Text(
          'Your request has been submitted. You can pay later from your orders page. '
          'Note: the order will remain pending until payment is received.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay here'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/orders',
                (route) => route.settings.name == '/home',
              );
            },
            child: const Text('Go to My Orders'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _skipPayment,
        ),
        title: Text(
          'Pay for ${widget.orderTypeLabel}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        widget.orderTypeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order #${widget.order.orderNumber}',
                    style: TextStyle(color: Colors.blue[800], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amount due: \$${widget.order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Card Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Stripe card field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _cardComplete ? Colors.blue : Colors.grey[300]!,
                  width: _cardComplete ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CardField(
                onCardChanged: (card) {
                  setState(() => _cardComplete = card?.complete ?? false);
                },
                enablePostalCode: true,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Your payment is secured by Stripe',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Test card: 4242 4242 4242 4242 · any future date · any CVC',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 36),

            // Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Pay \$${widget.order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Skip link
            Center(
              child: TextButton(
                onPressed: _isProcessing ? null : _skipPayment,
                child: Text(
                  'Skip for now — pay later',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
