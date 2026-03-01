import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/models/cart.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/utils/location_data.dart';

class CheckoutShippingScreen extends StatefulWidget {
  const CheckoutShippingScreen({super.key});

  @override
  State<CheckoutShippingScreen> createState() => _CheckoutShippingScreenState();
}

class _CheckoutShippingScreenState extends State<CheckoutShippingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityOtherController =
      TextEditingController(); // used when city == 'Other'

  String _selectedCountry = 'Bosnia and Herzegovina';
  String? _selectedCity; // null until user picks

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _cityOtherController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_formKey.currentState!.validate()) {
      final city = _selectedCity == 'Other'
          ? _cityOtherController.text.trim()
          : (_selectedCity ?? '');
      final address = ShippingAddress(
        fullName: _fullNameController.text,
        email: _emailController.text,
        address: _addressController.text,
        city: city,
        country: _selectedCountry,
        state: '',
        zipCode: _zipCodeController.text,
      );

      context.read<CartProvider>().setShippingAddress(address);
      Navigator.pushNamed(context, '/checkout-payment');
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
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                  _buildStep(1, 'Shipping', true),
                  Expanded(
                    child: Container(height: 2, color: Colors.grey[300]),
                  ),
                  _buildStep(2, '', false),
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
                      'The address your order will ship to',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    _buildLabel('Full name'),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('e.g. John Smith'),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel('Email'),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('email@example.com'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Email is required';
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim()))
                          return 'Please enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _buildLabel('Address'),
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration('e.g. 123 Main Street'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // City — dropdown driven by selected country
                    _buildLabel('City'),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: _inputDecoration(''),
                      hint: const Text('Select city'),
                      items: LocationData.citiesFor(_selectedCountry)
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          if (value != 'Other') _cityOtherController.clear();
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Please select a city' : null,
                    ),
                    if (_selectedCity == 'Other') ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityOtherController,
                        decoration: _inputDecoration('Enter your city'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your city'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Country
                    _buildLabel('Country'),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: _inputDecoration(''),
                      items: LocationData.countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                          _selectedCity =
                              null; // reset city when country changes
                          _cityOtherController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Zip Code
                    _buildLabel('Zip Code'),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: _inputDecoration('10000'),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      buildCounter:
                          (
                            _, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToPayment,
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
                              'Proceed to payment',
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
                  fontSize: 12,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
