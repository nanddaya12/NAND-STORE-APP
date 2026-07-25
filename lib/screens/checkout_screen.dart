import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../core/utils/location_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping controllers
  final _nameController = TextEditingController(text: 'Nand Kishore');
  final _emailController = TextEditingController(text: 'nand@example.com');
  final _phoneController = TextEditingController(text: '+91 99887 76655');
  final _addressController = TextEditingController(text: '123 Tech Park Lane');
  final _cityController = TextEditingController(text: 'Bangalore');
  final _zipController = TextEditingController(text: '560001');

  // Billing controllers
  bool _billingSame = true;
  final _billingNameController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingZipController = TextEditingController();

  // Delivery configuration
  String _deliveryMethod = 'Standard';
  
  // Payment Method configuration
  String _paymentMethod = 'Credit Card';
  final _cardController = TextEditingController(text: '4532 9988 1234 5678');
  final _expiryController = TextEditingController(text: '12/29');
  final _cvvController = TextEditingController(text: '412');

  // Notes
  final _notesController = TextEditingController();

  // Transaction States
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _confirmedOrderId = '';
  double _finalOrderTotal = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _billingNameController.dispose();
    _billingAddressController.dispose();
    _billingCityController.dispose();
    _billingZipController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(StoreProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    // Simulate Credit Card transaction processing errors
    if (_paymentMethod == 'Credit Card' && _cardController.text.replaceAll(' ', '').startsWith('0000')) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Transaction Failed'),
          content: const Text('Gateway Error: Insufficient funds. Please check your credit details or select PayPal/COD.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF000613))),
            )
          ],
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulated network processing delay
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final billingText = _billingSame
        ? '${_nameController.text}, ${_addressController.text}, ${_cityController.text}, ${_zipController.text}'
        : '${_billingNameController.text}, ${_billingAddressController.text}, ${_billingCityController.text}, ${_billingZipController.text}';

    _finalOrderTotal = provider.cartTotal;
    final orderId = provider.checkout(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      zip: _zipController.text,
      billingAddress: billingText,
      deliveryMethod: '$_deliveryMethod (\$${provider.estimatedShipping.toStringAsFixed(2)})',
      paymentMethod: _paymentMethod,
      orderNotes: _notesController.text,
    );

    setState(() {
      _confirmedOrderId = orderId;
      _isProcessing = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    if (_isProcessing) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF000613), strokeWidth: 4),
                const SizedBox(height: 24),
                const Text(
                  'Processing Payment...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF000613)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Validating details with banking network. Please do not close or refresh this page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF43474E), fontSize: 12, height: 1.4),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_isSuccess) {
      return _buildReceiptScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Checkout Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Details Title
              const Text('Shipping Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613))),
              const SizedBox(height: 12),
              _buildField(controller: _nameController, label: 'Full Name', icon: Icons.person),
              const SizedBox(height: 10),
              _buildField(controller: _emailController, label: 'Email Address', icon: Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField(controller: _addressController, label: 'Street Address', icon: Icons.home),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Color(0xFF000613)),
                    onPressed: () async {
                      final position = await LocationService.getCurrentLocation();
                      if (position != null) {
                        final address = await LocationService.getAddressFromCoordinates(position);
                        if (address != null && context.mounted) {
                          setState(() {
                            _addressController.text = address;
                          });
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not fetch location.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildField(controller: _cityController, label: 'City', icon: Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(controller: _zipController, label: 'ZIP Code', icon: Icons.pin_drop, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),

              // Billing Address Same Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Billing address is the same as shipping', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF000613))),
                value: _billingSame,
                activeColor: const Color(0xFF000613),
                onChanged: (val) {
                  setState(() {
                    _billingSame = val ?? true;
                  });
                },
              ),

              // Billing Address Fields (Animate Visible if not same)
              if (!_billingSame) ...[
                const SizedBox(height: 10),
                const Text('Billing Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613))),
                const SizedBox(height: 12),
                _buildField(controller: _billingNameController, label: 'Billing Name', icon: Icons.person),
                const SizedBox(height: 10),
                _buildField(controller: _billingAddressController, label: 'Billing Address', icon: Icons.home),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField(controller: _billingCityController, label: 'City', icon: Icons.location_city)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(controller: _billingZipController, label: 'ZIP Code', icon: Icons.pin_drop, keyboardType: TextInputType.number)),
                  ],
                ),
              ],
              const Divider(height: 32, color: Color(0xFFC4C6CF)),

              // Delivery Method Selector
              const Text('Delivery Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613))),
              const SizedBox(height: 12),
              _buildDeliveryCards(storeProvider),
              const Divider(height: 32, color: Color(0xFFC4C6CF)),

              // Payment Method Selector
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613))),
              const SizedBox(height: 12),
              _buildPaymentSelector(),
              const SizedBox(height: 16),

              // Credit Card details form if Card selected
              if (_paymentMethod == 'Credit Card') ...[
                _buildField(controller: _cardController, label: 'Card Number', icon: Icons.credit_card, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField(controller: _expiryController, label: 'Expiry (MM/YY)', icon: Icons.date_range, keyboardType: TextInputType.datetime)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(controller: _cvvController, label: 'CVV', icon: Icons.lock, keyboardType: TextInputType.number)),
                  ],
                ),
              ],
              const Divider(height: 32, color: Color(0xFFC4C6CF)),

              // Order Notes Area
              const Text('Order Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613))),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add instructions for courier (gate codes, delivery notes)...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF000613)),
                  ),
                ),
              ),
              const Divider(height: 32, color: Color(0xFFC4C6CF)),

              // Summaries Billing Details card
              const Text('Billing Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613))),
              const SizedBox(height: 12),
              _buildOrderSummaryCard(storeProvider),
              const SizedBox(height: 24),

              // Checkout confirm CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000613),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => _submit(storeProvider),
                  child: const Text('Confirm & Place Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF000613), size: 18),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF000613), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDeliveryCards(StoreProvider provider) {
    final sub = provider.cartSubtotal;
    final stdCost = sub >= 100.0 ? 0.0 : 9.99;

    final deliveryOptions = [
      {'label': 'Standard', 'cost': stdCost, 'time': '3-5 business days'},
      {'label': 'Express', 'cost': 19.99, 'time': '1-2 business days'},
      {'label': 'Next Day', 'cost': 29.99, 'time': '24 Hours Delivery'},
    ];

    return Column(
      children: deliveryOptions.map((opt) {
        final label = opt['label'] as String;
        final cost = opt['cost'] as double;
        final time = opt['time'] as String;
        final selected = _deliveryMethod == label;

        return GestureDetector(
          onTap: () {
            setState(() {
              _deliveryMethod = label;
            });
            // Update provider selected delivery cost
            provider.setDeliveryCost(cost);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: const Color(0xFF000613),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613))),
                      const SizedBox(height: 2),
                      Text(time, style: const TextStyle(color: Color(0xFF43474E), fontSize: 10)),
                    ],
                  ),
                ),
                Text(
                  cost == 0.0 ? 'FREE' : '\$${cost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: cost == 0.0 ? const Color(0xFF10B981) : const Color(0xFF7F5700),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSelector() {
    final methods = ['Credit Card', 'PayPal', 'Cash on Delivery'];
    return Row(
      children: methods.map((method) {
        final selected = _paymentMethod == method;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _paymentMethod = method;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF000613) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: Column(
                children: [
                  Icon(
                    method == 'Credit Card' ? Icons.credit_card :
                    method == 'PayPal' ? Icons.payment : Icons.money,
                    color: selected ? Colors.white : const Color(0xFF000613),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : const Color(0xFF000613),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummaryCard(StoreProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text('\$${provider.cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          if (provider.discountAmount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount Amount', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                Text('-\$${provider.discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text(
                provider.estimatedShipping == 0.0 ? 'FREE' : '\$${provider.estimatedShipping.toStringAsFixed(2)}',
                style: TextStyle(
                  color: provider.estimatedShipping == 0.0 ? const Color(0xFF10B981) : const Color(0xFF7F5700),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes (8%)', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text('\$${provider.cartTax.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFC4C6CF)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total due', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613), fontSize: 14)),
              Text('\$${provider.cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F5700), fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptScreen() {
    final pointsEarned = (_finalOrderTotal / 10).floor();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Confirmed!',
                style: TextStyle(color: Color(0xFF000613), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Receipt: $_confirmedOrderId',
                style: const TextStyle(color: Color(0xFF7F5700), fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFC4C6CF))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paid Amount:', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                          Text('\$${_finalOrderTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rewards Earned:', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                          Text('+$pointsEarned Points', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Method:', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                          Text(_deliveryMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Method:', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                          Text(_paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank you for shopping at NAND STORE! Your order has been placed successfully and is being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000613),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
