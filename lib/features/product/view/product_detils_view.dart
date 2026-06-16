import 'package:flutter/material.dart';
import 'package:hungry/core/network/api_error.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/theme/app_text_style.dart';
import 'package:hungry/core/theme/custom_text.dart';
import 'package:hungry/core/widgets/Appbar_back.dart';
import 'package:hungry/core/widgets/Guest_view.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/cart/data/cart_model.dart';
import 'package:hungry/features/cart/data/cart_repo.dart';
import 'package:hungry/features/cart/widget/buttom_Check_view.dart';
import 'package:hungry/features/home/data/model/topping_model.dart';
import 'package:hungry/features/home/data/repo/product_repo.dart';
import 'package:hungry/features/product/data/Side_options_List_view.dart';
import 'package:hungry/features/product/data/Toppings_List_View.dart';
import 'package:hungry/features/product/widget/card_product_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductDetilsView extends StatefulWidget {
  const ProductDetilsView({
    super.key,
    required this.image,
    required this.productId,
    required this.name,
    required this.desc,
    required this.totalprice,
  });
  final String? name;
  final String? desc;
  final String? image;
  final String totalprice;
  final int productId;
  @override
  State<ProductDetilsView> createState() => _ProductDetilsViewState();
}

class _ProductDetilsViewState extends State<ProductDetilsView> {
  bool isGuest = true;
  bool isLoading = true;
  bool isLoadingGuest = true;
  bool isLoadingcheck = false;
  double spicyLevel = 0.5;
  List<int> isSelectedOption = [];
  List<int> isSelectedTopping = [];
  ProductRepo productRepo = ProductRepo();
  List<ToppingModel>? toppings = [];
  List<ToppingModel>? options = [];
  AuthRepo authRepo = AuthRepo();

  // get Options
  Future<void> getOptions() async {
    final res = await productRepo.getSideOptions();
    if (!mounted) return;
    setState(() => options = res);
  }

  // get Toppings

  Future<void> getToppings() async {
    final res = await productRepo.getToppings();
    if (!mounted) return;
    setState(() => toppings = res);
  }

  // add to cart
  CartRepo cartRepo = CartRepo();
  Future<void> addToCart() async {
    try {
      if (!mounted) return;
      setState(() => isLoadingcheck = true);
      final cartItem = CartModel(
        productid: widget.productId,
        Spicy: spicyLevel,
        Toppings: isSelectedTopping,
        sideOptions: isSelectedOption,
        quantity: 1,
      );
      await cartRepo.addToCart(CartRequestModel(items: [cartItem]));
      setState(() => isLoadingcheck = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1200),
          content: Text("🎉 Added to Cart Successfully"),
          backgroundColor: Appcolors.background,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() => isLoadingcheck = false);
      throw ApiError(message: e.toString());
    }
  }

  // auto Login
  Future<void> autoLogin() async {
    final user = await authRepo.autoLogin();
    if (!mounted) return;
    setState(() => isGuest = authRepo.isGuest);
    if (authRepo.isGuest) {
      setState(() {
        isGuest = true;
        isLoadingGuest = false;
      });
      return;
    }
    if (user != null) {
      setState(() {
        isGuest = false;
        isLoadingGuest = false;
      });
    }
    await getToppings();
    await getOptions();
    if (!mounted) return;
    setState(() {
      isLoadingGuest = false;
    });
  }

  @override
  void initState() {
    autoLogin();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest == false) {
      return Skeletonizer(
        enabled: isLoading,
        child: Scaffold(
          backgroundColor: Appcolors.surface,
          bottomNavigationBar: Container(
            height: 96,
            decoration: BoxDecoration(
              color: Appcolors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Appcolors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      "Total",
                      style: Textstyle.text14bold.copyWith(
                        color: Appcolors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      "\$ ${widget.totalprice}",
                      style: Textstyle.text20bold.copyWith(
                        color: Appcolors.textDark,
                      ),
                    ),
                  ],
                ),
                ButtomCheckView(
                  isLoading: isLoadingcheck,
                  text: "Add to Cart",
                  onTap: () => addToCart(),
                ),
              ],
            ),
          ),
          appBar: AppbarBack(
            background: Appcolors.surface,
            onTap: () => Navigator.pop(context),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardProductView(
                        name: widget.name,
                        desc: widget.desc,
                        image: widget.image,
                        valueSpicy: spicyLevel,
                        onChangeSpicy: (value) =>
                            setState(() => spicyLevel = value),
                      ),
                      const SizedBox(height: 26),
                      CustomText(
                        "Toppings",
                        style: Textstyle.text18bold.copyWith(
                          color: Appcolors.textDark,
                        ),
                      ),
                      SizedBox(
                        height: 142,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 18,
                          ),
                          itemCount: toppings?.length,
                          itemBuilder: (context, index) {
                            final topping = toppings?[index];
                            final id = topping?.id ?? 0;
                            final isSelected = isSelectedTopping.contains(id);
                            return ToppingsListView(
                              name: topping?.name ?? "",
                              image: topping?.image ?? "",
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    isSelectedTopping.removeAt(id);
                                  } else {
                                    isSelectedTopping.add(id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomText(
                        "Side Options",
                        style: Textstyle.text18bold.copyWith(
                          color: Appcolors.textDark,
                        ),
                      ),
                      SizedBox(
                        height: 142,
                        child: options == null
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 18,
                                ),
                                itemCount: options?.length,
                                itemBuilder: (context, index) {
                                  final option = options?[index];
                                  final id = option?.id ?? 0;
                                  final isSelected = isSelectedOption.contains(
                                    id,
                                  );
                                  return SideOptionsListView(
                                    name: option!.name,
                                    image: option.image,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          isSelectedOption.removeAt(id);
                                        } else {
                                          isSelectedOption.add(id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isGuest == true) {
      return Skeletonizer(enabled: isLoadingGuest, child: GuestView());
    }
    return Container();
  }
}
