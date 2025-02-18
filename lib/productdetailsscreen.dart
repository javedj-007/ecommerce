// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final List<CartItem> cartItems;
  final Function(Product) onRemoveFromCart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.cartItems,
    required this.onRemoveFromCart,
  });

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double getTotal() {
    return widget.cartItems.fold(
      0.0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          Stack(
            children: [
              if (widget.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8, 
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      widget.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(widget.product.imageUrl),
            SizedBox(height: 16),
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("\$${widget.product.price}"),
            SizedBox(height: 16),
            Text(widget.product.description),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onAddToCart(
                    widget.product); // Add product to cart using callback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${widget.product.name} added to cart')),
                );
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
