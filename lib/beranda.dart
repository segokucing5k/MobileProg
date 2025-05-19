import 'package:flutter/material.dart';

// Model for shopping items
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

// Model for cart items
class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, required this.quantity});
  
  double get totalPrice => product.price * quantity;
}

// Shopping cart
class Cart {
  final List<CartItem> items = [];
  
  double get totalPrice => 
    items.fold(0, (sum, item) => sum + item.totalPrice);
    
  int get itemCount =>
    items.fold(0, (sum, item) => sum + item.quantity);
  
  void addItem(Product product) {
    final existingItemIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );
    
    if (existingItemIndex >= 0) {
      items[existingItemIndex].quantity++;
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
  }
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({Key? key}) : super(key: key);

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final Cart _cart = Cart();
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Expectorant',
      price: 30.999,
      imageUrl: 'actifed.jpg',
    ),
    Product(
      id: 2,
      name: 'Mucohexin',
      price: 29.999,
      imageUrl: 'mucohexin.jpg',
    ),
    Product(
      id: 3,
      name: 'Mecobalamin',
      price: 114.999,
      imageUrl: 'mecobalamin.jpg',
    ),
    Product(
      id: 4,
      name: 'Alaxan',
      price: 80.299,
      imageUrl: 'alaxan.jpg',
    ),
  ];
  
  void _addToCart(Product product) {
    setState(() {
      _cart.addItem(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _viewCart() {
    showModalBottomSheet(
      context: context, 
      builder: (context) => CartBottomSheet(cart: _cart),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping App'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _viewCart,
              ),
              if (_cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cart.itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _products.length,
        itemBuilder: (ctx, i) => ProductItem(
          product: _products[i],
          addToCart: _addToCart,
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final Function(Product) addToCart;
  
  const ProductItem({
    Key? key,
    required this.product,
    required this.addToCart,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 50),
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp${product.price.toStringAsFixed(2)}'),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () => addToCart(product),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartBottomSheet extends StatelessWidget {
  final Cart cart;
  
  const CartBottomSheet({Key? key, required this.cart}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Keranjang Belanja',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          cart.items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Keranjang belanja kosong'),
              )
            : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(cart.items[i].product.imageUrl),
                    ),
                    title: Text(cart.items[i].product.name),
                    subtitle: Text('Rp${cart.items[i].product.price.toStringAsFixed(2)}'),
                    trailing: Text('${cart.items[i].quantity}x'),
                  ),
                ),
              ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Rp${cart.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: cart.items.isEmpty ? null : () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Checkout berhasil'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Checkout'),
          ),
        ],
      ),
    );
  }
}