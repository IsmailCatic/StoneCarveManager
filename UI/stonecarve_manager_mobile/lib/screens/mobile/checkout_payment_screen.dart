import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  CardFieldInputDetails? _cardDetails;
  bool _cardComplete = false;
  bool _useSameAddress = true;

  @override
  void dispose() {
    super.dispose();
  }

  void _proceedToConfirmation() {
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your card details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Store card completion status in cart provider for next screen
    final cart = context.read<CartProvider>();
    cart.setPaymentReady(true);

    Navigator.pushNamed(context, '/checkout-confirmation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'StoneCarve Manager',
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress Steps
              Row(
                children: [
                  _buildStep(1, '', true),
                  Expanded(child: Container(height: 2, color: Colors.blue)),
                  _buildStep(2, 'Payment', true),
                  Expanded(
                    child: Container(height: 2, color: Colors.grey[300]),
                  ),
                  _buildStep(3, '', false),
                ],
              ),
              const SizedBox(height: 30),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your payment information',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Stripe Card Field Widget
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _cardComplete
                              ? Colors.blue
                              : Colors.grey[300]!,
                          width: _cardComplete ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: CardField(
                        onCardChanged: (card) {
                          setState(() {
                            _cardDetails = card;
                            _cardComplete = card?.complete ?? false;
                          });
                        },
                        enablePostalCode: true,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Card information',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Info text
                    Row(
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Your payment information is secure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test cards: 4242 4242 4242 4242 (any future date, any CVC)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Checkbox
                    CheckboxListTile(
                      value: _useSameAddress,
                      onChanged: (value) {
                        setState(() => _useSameAddress = value ?? true);
                      },
                      title: const Text(
                        'Use my shipping address for billing',
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(height: 32),

                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Proceed to confirmation',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Note
                    Text(
                      "Note: Your card won't be billed until confirmation",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
