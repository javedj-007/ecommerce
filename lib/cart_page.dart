// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'dart:convert';
import 'package:ecommerce_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class cart_page extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(Product) onRemoveFromCart;
  final Function() getTotal;

  const cart_page({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
    required this.getTotal,
  });

  @override
  _CartPageState createState() => _CartPageState();
}
class _CartPageState extends State<cart_page> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartData = _prefs.getString('cartItems');
    if (cartData != null && cartData.isNotEmpty) {
      List<dynamic> cartJson = json.decode(cartData);
      setState(() {
        widget.cartItems.clear();
        widget.cartItems.addAll(cartJson.map((item) => CartItem.fromJson(item)).toList());
      });
    }
  }

  Future<void> _saveCartItems() async {
    final cartData = json.encode(widget.cartItems.map((item) => item.toJson()).toList());
    await _prefs.setString('cartItems', cartData);
  }

  void addToCart(Product product) {
    setState(() {
      final existingItemIndex = widget.cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingItemIndex >= 0) {
        // If the product already exists in the cart, increase quantity
        widget.cartItems[existingItemIndex].quantity++;
      } else {
        // If product doesn't exist in cart, add it
        widget.cartItems.add(CartItem(product: product, quantity: 1));
      }
      _saveCartItems();  // Save updated cart to SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              item.product.imageUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text('Qty: ${item.quantity}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.onRemoveFromCart(item.product);
                              _saveCartItems();
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total: ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${widget.getTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout...'),
                              ),
                            );
                          },
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
