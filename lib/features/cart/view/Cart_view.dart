import 'package:flutter/material.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/theme/app_text_style.dart';
import 'package:hungry/core/theme/custom_text.dart';
import 'package:hungry/core/widgets/Guest_view.dart';
import 'package:hungry/features/CheckOut/view/checkOut_view.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/cart/data/Cart_item_view.dart';
import 'package:hungry/features/cart/data/cart_model.dart';
import 'package:hungry/features/cart/data/cart_repo.dart';
import 'package:hungry/features/cart/widget/buttom_Check_view.dart';
import 'package:hungry/shared/custom_snack.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool isGuest = true;
  bool isLoadingRemove = false;
  bool isLoading = true;
  List<int> quantity = [];
  AuthRepo authRepo = AuthRepo();

  // auto Login
  Future<void> autoLogin() async {
    if (!mounted) return;
    final user = await authRepo.autoLogin();
    if (!mounted) return;
    setState(() => isGuest = authRepo.isGuest);
    if (authRepo.isGuest) {
      setState(() {
        isGuest = true;
        isLoading = false;
      });
      return;
    }
    if (!mounted) return;
    if (user != null) {
      setState(() {
        isGuest = false;
        isLoading = false;
      });
    }
    if (!mounted) return;
    await getCartData();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  //Remove Item From Cart
  Future<void> removeFromCart(int itemId) async {
    try {
      setState(() => isLoadingRemove = true);
      await cartRepo.removeFromCart(itemId);
      await getCartData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarSuccess("Removed From Cart Successfully"));
      setState(() => isLoadingRemove = false);
    } catch (e) {
      isLoadingRemove = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarerror(e.toString()));
    }
  }

  //Get Cart Data
  GetcardResponse? cartResponse;
  CartRepo cartRepo = CartRepo();
  Future<void> getCartData() async {
    try {
      final res = await cartRepo.GetCartData();
      if (!mounted) return;
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBarerror("Failed to load cart. Please try again."),
        );
        return;
      }
      setState(() {
        cartResponse = res;
        quantity = List.generate(res.cartData.items.length, (_) => 1);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarerror(e.toString()));
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void onAdd(int index) {
    setState(() {
      quantity[index]++;
    });
  }

  void onMun(int index) {
    setState(() {
      if (quantity[index] > 1) {
        quantity[index]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isGuest) {
      return RefreshIndicator(
        onRefresh: getCartData,
        child: Skeletonizer(
          enabled: isLoading,
          child: Scaffold(
            extendBody: true,
            backgroundColor: Appcolors.surface,
            appBar: AppBar(
              backgroundColor: Appcolors.surface,
              toolbarHeight: 0,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 54),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                    itemCount: cartResponse?.cartData.items.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = cartResponse!.cartData.items[index];
                      return CartItemView(
                        image: item.image,
                        name: item.name,
                        description: "Spicy:${item.spicy}",
                        number: quantity[index],
                        onAdd: () => onAdd(index),
                        onMun: () => onMun(index),
                        onRemove: () => removeFromCart(item.item_Id),
                        isLoading: isLoadingRemove,
                      );
                    },
                  ),
                ),
                Container(
                  height: 86,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  decoration: BoxDecoration(
                    color: Appcolors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Appcolors.black.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "Total",
                            style: Textstyle.text14bold.copyWith(
                              color: Appcolors.textSecondary,
                            ),
                          ),
                          CustomText(
                            "\$ ${cartResponse?.cartData.TotalPrice ?? "0.00"}",
                            style: Textstyle.text20bold.copyWith(
                              color: Appcolors.textDark,
                            ),
                          ),
                        ],
                      ),
                      ButtomCheckView(
                        text: "Check Out",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutView(
                              order: cartResponse!.cartData.TotalPrice
                                  .toString(),
                              totalPrice: cartResponse!.cartData.TotalPrice
                                  .toString(),
                              productId:
                                  cartResponse!.cartData.items[0].product_id,
                              quantity:
                                  cartResponse!.cartData.items[0].quantity,
                              Options: [],
                              Topping: [],
                              Spicy: double.parse(
                                cartResponse!.cartData.items[0].spicy,
                              ),
                            ),
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
    return Skeletonizer(enabled: isLoading, child: GuestView());
  }
}
