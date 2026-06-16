import 'package:flutter/material.dart';
import 'package:hungry/core/network/api_error.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/theme/custom_text.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/auth/data/user_model.dart';
import 'package:hungry/features/home/data/model/product_model.dart';
import 'package:hungry/features/home/data/repo/product_repo.dart';
import 'package:hungry/features/home/widget/Home_Appbar_View.dart';
import 'package:hungry/features/home/data/Search_Items_View.dart';
import 'package:hungry/features/home/data/items_view.dart';
import 'package:hungry/features/home/widget/section_view.dart';
import 'package:hungry/features/product/view/product_detils_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  bool _firstTime = true;
  final ProductRepo productRepo = ProductRepo();
  List<ProductModel>? products;
  List<ProductModel>? allproducts;
  bool isLoading = true;
  UserModel? userModel;
  AuthRepo authRepo = AuthRepo();

  /// get profile data
  Future<void> getProfileData() async {
    try {
      final user = await authRepo.getProfileData();
      if (!mounted) return;
      setState(() {
        userModel = user;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      String errorMsg = e.toString();

      if (e is ApiError) {
        errorMsg = e.message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: CustomText(errorMsg)));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Get products
  Future<void> getProducts() async {
    final res = await productRepo.getProducts();
    if (!mounted) return;
    setState(() {
      products = res;
      allproducts = res;
    });
  }

  @override
  void initState() {
    super.initState();
    if (_firstTime) {
      _firstTime = false;
      getProfileData();
      getProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: getProfileData,
      child: Skeletonizer(
        enabled:
            products == null && userModel?.image == null && userModel == null,
        child: Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: 260,
                  toolbarHeight: 260,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: const Color(0xffF8F8F8),
                  flexibleSpace: HomeAppbarView(
                    userImage: userModel?.image,
                    userAddress: userModel?.address ?? "Iraq, Baghdad",
                    onChane: (v) {
                      setState(() {
                        final search = searchController.text.toLowerCase();
                        products = allproducts
                            ?.where((element) => element.name
                                .toLowerCase()
                                .contains(search))
                            .toList();
                      });
                    },
                    search: searchController,
                  ),
                ),

                SliverToBoxAdapter(child: HomeAppbar()),

                SliverToBoxAdapter(
                  child: Section(
                    title: "Popular",
                    action: products == null ? "Loading..." : "See all",
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
                  sliver: products == null
                      ? SliverToBoxAdapter(
                          child: SizedBox(
                            height: 260,
                            child: Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Appcolors.background,
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products![index];

                            return ViewItems(
                              name: product.name,
                              desc: product.desc,
                              image: product.image,
                              rate: product.rating,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetilsView(
                                    image: product.image,
                                    productId: product.id,
                                    name: product.name,
                                    desc: product.desc,
                                    totalprice: product.price,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: products!.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 18,
                                childAspectRatio: 0.55,
                              ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
