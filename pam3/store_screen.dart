import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'store_cubit.dart';
import 'product.dart';
import 'product_card.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        final cubit = context.read<StoreCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  'WELCOME TO',
                  style: TextStyle(fontSize: 10, letterSpacing: 2),
                ),
                Text(
                  state.storeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Refresh data',
                onPressed: cubit.loadStore,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _tab == 1
              ? _favoritesView(context, state)
              : _tab == 2
                  ? _cartView(context, state)
                  : _homeView(context, state),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) {
              setState(() => _tab = value);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: state.favoriteIds.isEmpty
                    ? 'Favorites'
                    : 'Favorites (${state.favoriteIds.length})',
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_bag_outlined),
                selectedIcon: const Icon(Icons.shopping_bag),
                label: state.cartIds.isEmpty
                    ? 'Cart'
                    : 'Cart (${state.cartIds.length})',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _homeView(BuildContext context, StoreState state) {
    if (state.status == StoreStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == StoreStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'An error occurred.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: context.read<StoreCubit>().loadStore,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == StoreStatus.empty || state.allProducts.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    final products = state.visibleProducts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1200&q=80',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0x55000000),
                BlendMode.darken,
              ),
            ),
          ),
          child: const Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'AUTUMN COLLECTION\nFind your everyday style',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: context.read<StoreCubit>().search,
          decoration: InputDecoration(
            hintText: 'Search products',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _categoryChip(
                context,
                'All',
                'all',
                state.selectedCategory,
              ),
              ...state.categories.map(
                (category) => _categoryChip(
                  context,
                  category['name']?.toString() ?? 'Category',
                  category['id']?.toString() ?? '',
                  state.selectedCategory,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Featured products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButton<String>(
              value: state.sortBy,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 'Featured',
                  child: Text('Featured'),
                ),
                DropdownMenuItem(
                  value: 'Price: low to high',
                  child: Text('Price ↑'),
                ),
                DropdownMenuItem(
                  value: 'Price: high to low',
                  child: Text('Price ↓'),
                ),
                DropdownMenuItem(
                  value: 'Name: A to Z',
                  child: Text('Name A–Z'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<StoreCubit>().sort(value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(
              child: Text('No products match your search or filter.'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return ProductCard(
                product: product,
                isFavorite: state.favoriteIds.contains(product.id),
                onFavorite: () {
                  context.read<StoreCubit>().toggleFavorite(product.id);
                },
                onTap: () => _openDetails(context, product),
              );
            },
          ),
      ],
    );
  }

  Widget _categoryChip(
    BuildContext context,
    String label,
    String id,
    String selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: id == selected,
        onSelected: (_) {
          context.read<StoreCubit>().selectCategory(id);
        },
      ),
    );
  }

  Widget _favoritesView(BuildContext context, StoreState state) {
    final products = state.allProducts
        .where((product) => state.favoriteIds.contains(product.id))
        .toList();

    if (products.isEmpty) {
      return const Center(
        child: Text('You have no favorite products yet.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          isFavorite: true,
          onFavorite: () {
            context.read<StoreCubit>().toggleFavorite(product.id);
          },
          onTap: () => _openDetails(context, product),
        );
      },
    );
  }

  Widget _cartView(BuildContext context, StoreState state) {
    final products = state.allProducts
        .where((product) => state.cartIds.contains(product.id))
        .toList();

    if (products.isEmpty) {
      return const Center(child: Text('Your cart is empty.'));
    }

    final total = products.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...products.map(
          (product) => ListTile(
            leading: Image.network(
              product.imageUrl,
              width: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.checkroom),
            ),
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                context.read<StoreCubit>().toggleCart(product.id);
              },
            ),
          ),
        ),
        const Divider(),
        Text(
          'Total: \$${total.toStringAsFixed(2)}',
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  String? _selectedColor;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    _selectedSize =
        widget.product.sizes.isEmpty ? null : widget.product.sizes.last;

    _selectedColor = widget.product.colors.isEmpty
        ? null
        : widget.product.colors.first['id']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        final favorite = state.favoriteIds.contains(product.id);
        final inCart = state.cartIds.contains(product.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product details'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 0.9,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFECE9E5),
                      child: Center(
                        child: Icon(Icons.checkroom, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<StoreCubit>().toggleFavorite(product.id);
                    },
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: favorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${product.price.toStringAsFixed(2)} ${product.currency}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (product.rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '★ ${product.rating.toStringAsFixed(1)}'
                  '  •  ${product.reviewCount} reviews',
                ),
              ],
              const SizedBox(height: 16),
              Text(
                product.description,
                maxLines: _expanded ? null : 3,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              TextButton(
                onPressed: () {
                  setState(() => _expanded = !_expanded);
                },
                child: Text(_expanded ? 'Show less' : 'Read more'),
              ),
              if (product.colors.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 10,
                  children: product.colors.map((color) {
                    final id = color['id']?.toString() ?? '';
                    final name = color['name']?.toString() ?? id;

                    return ChoiceChip(
                      label: Text(name),
                      selected: _selectedColor == id,
                      onSelected: (_) {
                        setState(() => _selectedColor = id);
                      },
                    );
                  }).toList(),
                ),
              ],
              if (product.sizes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Size',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: product.sizes.map((size) {
                    return ChoiceChip(
                      label: Text(size),
                      selected: _selectedSize == size,
                      onSelected: (_) {
                        setState(() => _selectedSize = size);
                      },
                    );
                  }).toList(),
                ),
              ],
              if (product.reviews.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Customer reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...product.reviews.map((review) {
                  final rating = review['rating'] as num?;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      review['author']?.toString() ?? 'Customer',
                    ),
                    subtitle: Text(
                      review['text']?.toString() ?? '',
                    ),
                    trailing: Text(
                      '★ ${rating?.toStringAsFixed(0) ?? '5'}',
                    ),
                  );
                }),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  context.read<StoreCubit>().toggleCart(product.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        inCart ? 'Removed from cart' : 'Added to cart',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  inCart
                      ? Icons.remove_shopping_cart
                      : Icons.shopping_bag_outlined,
                ),
                label: Text(
                  inCart ? 'Remove from Cart' : 'Add To Cart',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
