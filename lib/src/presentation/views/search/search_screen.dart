import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_app_bar.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/single_listing_product.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_amazon_clone_bloc/src/logic/blocs/search/bloc/search_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Bộ lọc
  double _minPrice = 0;
  double _maxPrice = 30000000;

  // Danh sách sản phẩm hiển thị sau khi lọc
  late List<Product> _displayProducts;

  // Khởi tạo trạng thái
  @override
  void initState() {
    super.initState();
    _displayProducts = [];
  }

  // Hàm cập nhật danh sách sau khi lọc
  void _applyFilters(List<Product> originalProducts) {
    setState(() {
      _displayProducts = originalProducts.where((product) {
        return product.price >= _minPrice && product.price <= _maxPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchErrorS) {
            showSnackBar(context, state.errorString);
          }
        },
        builder: (context, state) {
          if (state is SearchLoadingS) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchSuccessS) {
            // Khởi tạo danh sách nếu chưa có
            if (_displayProducts.isEmpty) {
              _displayProducts = List.from(state.searchProducts);
            }

            return Column(
              children: [
                // Widget lọc giá tiền
                PriceFilterWidget(
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  onFilterChanged: (double newMin, double newMax) {
                    _minPrice = newMin;
                    _maxPrice = newMax;
                    _applyFilters(state.searchProducts);
                  },
                ),
                Expanded(
                  child: _displayProducts.isNotEmpty
                      ? ListView.builder(
                          itemCount: _displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = _displayProducts[index];
                            final averageRating =
                                state.averageRatingList[index];

                            return SingleListingProduct(
                              product: product,
                              averageRating: averageRating,
                              deliveryDate: getDeliveryDate(),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "Không tìm thấy sản phẩm phù hợp với bộ lọc.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class PriceFilterWidget extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final Function(double, double) onFilterChanged;

  const PriceFilterWidget({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lọc theo giá tiền",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          RangeSlider(
            values: RangeValues(minPrice, maxPrice),
            min: 0,
            max: 30000000,
            divisions: 100,
            labels: RangeLabels(
              minPrice.toStringAsFixed(0),
              maxPrice.toStringAsFixed(0),
            ),
            onChanged: (values) {
              onFilterChanged(values.start, values.end);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Từ: ${formatPrice(double.parse(minPrice.toStringAsFixed(0)))}₫"),
              Text(
                  "Đến: ${formatPrice(double.parse(maxPrice.toStringAsFixed(0)))}₫"),
            ],
          ),
        ],
      ),
    );
  }
}
