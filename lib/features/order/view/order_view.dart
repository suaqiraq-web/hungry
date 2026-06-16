import 'package:flutter/material.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/widgets/Guest_view.dart';
import 'package:hungry/features/CheckOut/data/order_model.dart';
import 'package:hungry/features/CheckOut/data/order_repo.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/auth/data/user_model.dart';
import 'package:hungry/features/order/data/order_item_view.dart';
import 'package:hungry/shared/custom_snack.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with AutomaticKeepAliveClientMixin {
  bool _firstTime = true;
  GetOrderResponse? getOrderResponse;
  OrderRepo orderRepo = OrderRepo();
  List<OrderData> orders = [];
  bool isLoading = true;
  bool isGuest = true;
  // Get order
  Future<void> getOrder() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);
      final res = await orderRepo.getOrderDetails();
      if (!mounted) return;
      if (res == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(customSnackBarerror("No orders found"));
        return;
      }
      setState(() {
        orders = res.orders;
        isLoading = false;
      });
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarerror(e.toString()));
    }
  }

  UserModel? userModel;
  AuthRepo authRepo = AuthRepo();
  // auto login
  Future<void> autoLogin() async {
    if (!mounted) return;
    final user = await authRepo.autoLogin();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      isGuest = authRepo.isGuest;
      userModel = user;
      isLoading = false;
    });
    if (user != null) {}
  }

  @override
  void initState() {
    if (_firstTime) {
      _firstTime = false;
      autoLogin();
      getOrder();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!isGuest) {
      return RefreshIndicator(
        onRefresh: getOrder,
        child: Skeletonizer(
          enabled: isLoading,
          child: RefreshIndicator(
            onRefresh: getOrder,
            child: Scaffold(
              backgroundColor: Appcolors.surface,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Orders",
                      style: TextStyle(
                        color: Appcolors.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: OrderItemView(
                            orderImage: order.product_image,
                            orderCreatedAt: order.created_at.substring(0, 10),
                            orderStatus: order.status,
                            orderTotalPrice: order.totalPrice.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Skeletonizer(
      enabled: isLoading,
      child: GuestView(
        title: "Order",
        description: "Login to view your orders",
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
