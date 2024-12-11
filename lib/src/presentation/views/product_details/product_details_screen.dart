import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/account_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/keep_shopping_for/cubit/keep_shopping_for_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/wish_list/wish_list_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/cart/cart_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/home_blocs/carousel_bloc/carousel_image_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/product_details/averageRating/average_rating_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/product_details/user_rating/user_rating_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/shop/shop_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/user_cubit/user_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_app_bar.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_elevated_button.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/divider_with_sizedbox.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/stars.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/home/custom_carousel_slider.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/home/dots_indicator.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/customer_ratings.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/product_features.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/product_quality_icons.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/you_might_also_like.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final String deliveryDate;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CarouselImageBloc>(context).add(ResetCarouselEvent());
    BlocProvider.of<UserRatingCubit>(context).userRating(product);
    BlocProvider.of<AverageRatingCubit>(context)
        .getProductAverageRating(productId: product.id!);
    BlocProvider.of<WishListCubit>(context).wishList(product: product);
    BlocProvider.of<KeepShoppingForCubit>(context)
        .addToKeepShoppingFor(product: product);
    final CarouselController controller = CarouselController();

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60), child: CustomAppBar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    const SizedBox(height: 10),
                    BlocBuilder<CarouselImageBloc, CarouselImageState>(
                      builder: (context, state) {
                        if (state is CarouselImageChangeState) {
                          return CarouselWidget(
                              product: product,
                              controller: controller,
                              currentIndex: state.index);
                        } else {
                          return CarouselWidget(
                              product: product,
                              controller: controller,
                              currentIndex: 0);
                        }
                      },
                    ),
                    Positioned(
                      bottom: 30,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: BlocBuilder<WishListCubit, WishListState>(
                          builder: (context, state) {
                            if (state is GetWishListLoadingS) {
                              return const SizedBox();
                            }

                            if (state is NotAddedToWishListS) {
                              return WishListIcon(
                                iconColor: Colors.grey,
                                product: product,
                                onPressed: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('x-auth-token');
                                  if (token == null || token.isEmpty) {
                                    context.pushNamed(
                                        AppRouteConstants.authRoute.name);
                                    return;
                                  }
                                  context
                                      .read<WishListCubit>()
                                      .addToWishList(product: product);
                                },
                              );
                            }
                            if (state is AddedToWishListS) {
                              return WishListIcon(
                                iconColor: Colors.red,
                                product: product,
                                onPressed: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('x-auth-token');
                                  if (token == null || token.isEmpty) return;
                                  context
                                      .read<WishListCubit>()
                                      .deleteFromWishList(product: product);
                                },
                              );
                            }
                            if (state is DeletedFromWishListS) {
                              return WishListIcon(
                                iconColor: Colors.grey,
                                product: product,
                                onPressed: () {
                                  context
                                      .read<WishListCubit>()
                                      .addToWishList(product: product);
                                },
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        context.read<ShopCubit>().getShop(product.shopId);
                        context.pushNamed(
                          AppRouteConstants.shopRoute.name,
                        );
                      },
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Constants.yellowColor.withOpacity(0.4)),
                      icon: const Icon(Icons.shopping_basket_rounded),
                      label: Text(
                        'Ghé thăm cửa hàng',
                        style: TextStyle(color: Constants.selectedNavBarColor),
                      ),
                    ),
                    BlocBuilder<AverageRatingCubit, AverageRatingState>(
                      builder: (context, state) {
                        if (state is AverageRatingLoadingS) {
                          return const SizedBox();
                        }
                        if (state is AverageRatingSuccessS) {
                          return Row(
                            children: [
                              Text(state.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87)),
                              const SizedBox(width: 4),
                              Stars(rating: state.averageRating),
                              const SizedBox(width: 6),
                              Text(
                                state.averageRatingLength.toString(),
                                style: TextStyle(
                                  color: Constants.selectedNavBarColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            // const DividerWithSizedBox(),
            // priceEmi(),
            // const DividerWithSizedBox(
            //   sB1Height: 15,
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Giá: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: '${formatPrice(product.price)}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                      text: 'giao hàng MIỄN PHÍ ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Constants.selectedNavBarColor,
                      ),
                      children: [
                        TextSpan(
                          text: deliveryDate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        if (state is UserSuccessS) {
                          if (state.user.address != '') {
                            return Expanded(
                              child: Text(
                                'Giao hàng đến ${capitalizeFirstLetter(string: state.user.name)} - ${state.user.address}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Constants.selectedNavBarColor),
                              ),
                            );
                          } else {
                            return Expanded(
                              child: Text(
                                'Giao hàng đến ${state.user.name} ',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Constants.selectedNavBarColor),
                              ),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Còn hàng',
                  style: TextStyle(color: Constants.greenColor, fontSize: 16),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomElevatedButton(
                    buttonText: 'Thêm vào giỏ hàng',
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final token = prefs.getString('x-auth-token');
                      if (token == null || token.isEmpty) {
                        context.pushNamed(AppRouteConstants.authRoute.name);
                        return;
                      }

                      context.read<CartBloc>().add(AddToCart(product: product));
                      showSnackBar(context, 'Đã thêm vào giỏ hàng!');
                    }),
                const SizedBox(
                  height: 10,
                ),
                CustomElevatedButton(
                  buttonText: 'Mua ngay',
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final token = prefs.getString('x-auth-token');
                    if (token == null || token.isEmpty) {
                      context.pushNamed(AppRouteConstants.authRoute.name);
                      return;
                    }
                    context.pushReplacementNamed(
                        AppRouteConstants.cartScreenScreenRoute.name,
                        );
                  },
                  color: Constants.secondaryColor,
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Giao dịch an toàn',
                      style: TextStyle(
                          color: Constants.selectedNavBarColor, fontSize: 15),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Có gói quà tặng.',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 14),
                BlocBuilder<WishListCubit, WishListState>(
                  builder: (context, state) {
                    return InkWell(
                      onTap: () async {
                        if (state is AddedToWishListS) {
                          return showSnackBar(context,
                              'Sản phẩm này đã có trong danh sách mong muốn của bạn');
                        } else {
                          await context
                              .read<WishListCubit>()
                              .addToWishList(product: product);
                          if (context.mounted) {
                            showSnackBar(
                                context, ' Đã thêm vào danh sách yêu thích!');
                          }
                        }
                      },
                      child: Text(
                        'Thêm vào danh sách yêu thích',
                        style: TextStyle(
                            color: Constants.selectedNavBarColor, fontSize: 15),
                      ),
                    );
                  },
                ),
              ],
            ),
            const DividerWithSizedBox(),
            const ProductQualityIcons(),
            const DividerWithSizedBox(
              sB1Height: 4,
              sB2Height: 6,
            ),
            ProductFeatures(product: product),
            const DividerWithSizedBox(),
            BlocBuilder<AverageRatingCubit, AverageRatingState>(
              builder: (context, state) {
                if (state is AverageRatingLoadingS) {
                  return CustomerReviews(averageRating: 0, product: product);
                }
                if (state is AverageRatingSuccessS) {
                  return CustomerReviews(
                      averageRating: state.averageRating, product: product);
                }
                return CustomerReviews(averageRating: 0, product: product);
              },
            ),
            const DividerWithSizedBox(),

            // userRating == -1
            //     ? const SizedBox()
            //     :
            BlocConsumer<UserRatingCubit, UserRatingState>(
                listener: (context, state) {
              if (state is UserRatingErrorS) {
                showSnackBar(context, state.errorString);
              }
            }, builder: (context, state) {
              if (state is UpdateUserRatingInitialS) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is UserRatingSuccessS) {
                if (state.userRating == -1) {
                  return const SizedBox();
                } else {
                  return ratingFromUser(context, state.userRating, product);
                }
              } else {
                if (state is UpdateUserRatingSuccessS) {
                  return ratingFromUser(context, state.userRating, product);
                }
              }
              return const SizedBox();
            }),

            const YouMightAlsoLike(),
          ]),
        ),
      ),
    );
  }

  Column ratingFromUser(
      BuildContext context, double userRating, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá sao của bạn!',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        RatingBar.builder(
            itemSize: 28,
            initialRating: userRating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Constants.secondaryColor,
                ),
            onRatingUpdate: (rating) {
              BlocProvider.value(
                  value: UserRatingCubit(AccountRepository())
                    ..updateUserRating(userRating: rating, product: product));
            }),
        const DividerWithSizedBox(),
      ],
    );
  }

  Column priceEmi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatPrice(product.price),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              width: 4,
            ),
            const Text(
              'đ',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            text: 'EMI ',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: 'từ đ${getEmi(product)}. Không có chi phí trả góp EMI.',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' Tùy chọn EMI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Constants.selectedNavBarColor,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Bao gồm tất cả các texes',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({
    super.key,
    required this.currentIndex,
    required this.product,
    required this.controller,
  });

  final int currentIndex;
  final Product product;
  final CarouselController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCarouselSliderList(
            onPageChanged: (index, reason) {
              BlocProvider.of<CarouselImageBloc>(context)
                  .add(CarouselImageChangedEvent(index: index));
            },
            sliderImages: product.images),
        DotsIndicatorList(
            controller: controller,
            current: currentIndex,
            sliderImages: product.images),
      ],
    );
  }
}

class WishListIcon extends StatelessWidget {
  const WishListIcon({
    super.key,
    required this.product,
    required this.onPressed,
    required this.iconColor,
  });

  final Product product;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InkWell(
      onTap: onPressed,
      child: Icon(
        Icons.favorite,
        color: iconColor,
        size: 30,
      ),
    )
        // : InkWell(
        //     onTap: () {
        //       context
        //           .read<WishListCubit>()
        //           .addToWishList(product: product);
        //     },
        //     child: const Icon(
        //       Icons.favorite_border,
        //       color: Colors.grey,
        //       size: 30,
        //     ),
        //   ),
        );
  }
}
