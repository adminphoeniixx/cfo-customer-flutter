import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/wishlist_service.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/product_card.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final _repo = Get.find<AccountRepository>();
  final _wishlist = Get.find<WishlistService>();
  List<ProductCardModel> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = products.isEmpty);
    try {
      products = await _repo.wishlist();
      // Keep the app-wide membership set in sync with what the server has,
      // so hearts elsewhere (Home, Results, Product detail) agree with this list.
      _wishlist.ids
        ..clear()
        ..addAll(products.map((p) => p.id));
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _remove(ProductCardModel p) async {
    await _wishlist.toggle(p.id);
    setState(() => products.removeWhere((e) => e.id == p.id));
    CfoToast.success('Removed from your wishlist');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Wishlist'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              message: 'Tap the heart on any product to save it here.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpace.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpace.sm,
                  crossAxisSpacing: AppSpace.sm,
                  mainAxisExtent: 240,
                ),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  return ProductCard(
                    product: p,
                    onTap: () => Get.toNamed(
                      AppRoutes.productDetail,
                      arguments: {'idOrSlug': p.slug},
                    ),
                    onWishlistTap: () => _remove(p),
                  );
                },
              ),
            ),
    );
  }
}
