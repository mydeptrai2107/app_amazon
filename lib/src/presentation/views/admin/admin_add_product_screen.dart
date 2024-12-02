import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/admin/admin_add_products/add_product_images/admin_add_products_images_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/admin/admin_add_products/select_category_cubit/admin_add_select_category_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/admin/admin_add_products/sell_product_cubit/admin_sell_product_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_elevated_button.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_textfield.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key, this.product});
  final Product? product;

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  late final TextEditingController productNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController quantityController;
  @override
  void initState() {
    productNameController = TextEditingController(text: widget.product?.name);
    descriptionController =
        TextEditingController(text: widget.product?.description);
    priceController =
        TextEditingController(text: widget.product?.price.toString());
    quantityController =
        TextEditingController(text: widget.product?.quantity.toString());
    super.initState();
  }

  final _addProductFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AdminAddProductsImagesBloc>().add(ClearImagesPressedE());
    context.read<AdminAddSelectCategoryCubit>().resetCategory();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: Constants.appBarGradient),
          ),
          title: const Text('Add Product'),
        ),
      ),
      body: SingleChildScrollView(
        child: BlocConsumer<AdminSellProductCubit, AdminSellProductState>(
          listener: (context, state) {
            if (state is AdminSellProductErrorS) {
              showSnackBar(context, state.errorString);
            }

            if (state is AdminSellProductSuccessS) {
              showSnackBar(
                context,
                widget.product == null
                    ? 'Thêm sản phẩm thành công!'
                    : "Cập nhật sản phẩm thành công",
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AdminSellProductsLoadingS) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height / 1.2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.product == null
                            ? 'Đang thêm sản phẩm...'
                            : "Đang cập nhật sản phẩm...",
                      )
                    ],
                  ),
                ),
              );
            }

            return Form(
              key: _addProductFormKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    BlocConsumer<AdminAddProductsImagesBloc,
                        AdminAddProductsImagesState>(
                      listener: (context, state) {
                        if (state is AdminAddProductsErrorS) {
                          showSnackBar(context, 'Vui lòng chọn ảnh sản phẩm.');
                        }
                      },
                      builder: (context, state) {
                        if (state is AdminAddProductsImagesSelectedS) {
                          return Column(
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  state.imagesList.length > 1
                                      ? const Icon(
                                          Icons.chevron_left_rounded,
                                          color: Constants.secondaryColor,
                                        )
                                      : const SizedBox(),
                                  Expanded(
                                    child: CarouselSlider(
                                      items: state.imagesList.map((i) {
                                        return Builder(
                                          builder: (context) => Image.file(
                                            i,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }).toList(),
                                      options: CarouselOptions(
                                        height: 230,
                                        viewportFraction: 1,
                                        initialPage: 0,
                                      ),
                                    ),
                                  ),
                                  state.imagesList.length > 1
                                      ? const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Constants.secondaryColor,
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              TextButton.icon(
                                onPressed: () => context
                                    .read<AdminAddProductsImagesBloc>()
                                    .add(const SelectImagesPressedE()),
                                style: const ButtonStyle(
                                    side: WidgetStatePropertyAll(BorderSide(
                                        width: 1,
                                        color: Constants.secondaryColor))),
                                icon: const Icon(Icons.add),
                                label: const Text('Chọn ảnh'),
                              ),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => context
                                .read<AdminAddProductsImagesBloc>()
                                .add(const SelectImagesPressedE()),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: Colors.black54,
                              borderPadding:
                                  const EdgeInsets.symmetric(horizontal: 5)
                                      .copyWith(top: 5),
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open,
                                      size: 40,
                                      color: Colors.black54,
                                    ),
                                    Text(
                                      'Chọn ảnh sản phẩm',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextfield(
                      controller: productNameController,
                      hintText: 'Product name',
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    CustomTextfield(
                      controller: descriptionController,
                      hintText: 'Description',
                      maxLines: 8,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    CustomTextfield(
                        controller: priceController, hintText: 'Price'),
                    const SizedBox(
                      height: 4,
                    ),
                    CustomTextfield(
                        controller: quantityController, hintText: 'Quantity'),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: BlocBuilder<AdminAddSelectCategoryCubit,
                          AdminAddSelectCategoryState>(
                        builder: (context, state) {
                          if (state is AdminAddProductsSelectCategory) {
                            return CustomDropDown(
                              inputBorderStyle: Constants.inputBorderStyle,
                              productCategories: Constants.productCategories,
                              currentCategory: state.category,
                              valueStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                          } else {
                            if (widget.product != null) {
                              context
                                  .read<AdminAddSelectCategoryCubit>()
                                  .selectCategory(
                                    category: widget.product!.category,
                                  );
                            }
                            return CustomDropDown(
                              inputBorderStyle: Constants.inputBorderStyle,
                              productCategories: Constants.productCategories,
                              currentCategory: widget.product?.category ??
                                  Constants.productCategories[0],
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    BlocConsumer<AdminSellProductCubit, AdminSellProductState>(
                      listener: (context, state) {
                        if (state is AdminSellProductErrorS) {
                          showSnackBar(context,
                              'Lỗi! hãy chắc chắn rằng bạn đã điền vào mẫu một cách chính xác!');
                        }
                      },
                      builder: (context, state) {
                        return CustomElevatedButton(
                            buttonText: widget.product != null
                                ? "Cập nhật sản phẩm"
                                : 'Thêm sản phẩm',
                            onPressed: () async {
                              try {
                                List<File> imagesList = context
                                    .read<AdminAddProductsImagesBloc>()
                                    .imagesList!;
                                String category = context
                                    .read<AdminAddSelectCategoryCubit>()
                                    .category!;

                                if (_addProductFormKey.currentState!
                                        .validate() &&
                                    imagesList.isNotEmpty &&
                                    category != 'Category') {
                                  final adminSell =
                                      context.read<AdminSellProductCubit>();
                                  if (widget.product != null) {
                                    await adminSell.updateProduct(
                                      id: widget.product!.id.toString(),
                                      name: productNameController.text,
                                      description: descriptionController.text,
                                      price: double.parse(priceController.text),
                                      quantity:
                                          int.parse(quantityController.text),
                                      category: category,
                                      images: imagesList,
                                    );
                                  } else {
                                    await adminSell.sellProduct(
                                      name: productNameController.text,
                                      description: descriptionController.text,
                                      price: double.parse(priceController.text),
                                      quantity:
                                          int.parse(quantityController.text),
                                      category: category,
                                      images: imagesList,
                                    );
                                  }

                                  if (context.mounted) {
                                    showSnackBar(
                                      context,
                                      widget.product == null
                                          ? 'Đã thêm sản phẩm thành công!'
                                          : 'Đã cập nhật sản phẩm thành công',
                                    );
                                  }
                                } else {
                                  showSnackBar(context,
                                      'Lỗi! hãy chắc chắn rằng bạn đã điền vào mẫu một cách chính xác!');
                                }
                              } catch (e) {
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  showSnackBar(context,
                                      'Vui lòng điền vào mẫu một cách chính xác!');
                                }
                              }
                            }
                            // sellProducts
                            );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.inputBorderStyle,
    required this.productCategories,
    required this.currentCategory,
    this.valueStyle =
        const TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
  });

  final String currentCategory;
  final TextStyle valueStyle;
  final OutlineInputBorder inputBorderStyle;
  final List<String> productCategories;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        focusedBorder: inputBorderStyle,
        enabledBorder: inputBorderStyle,
        border: inputBorderStyle,
      ),
      items: productCategories.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: valueStyle),
        );
      }).toList(),
      value: currentCategory,
      onChanged: (newVal) {
        context
            .read<AdminAddSelectCategoryCubit>()
            .selectCategory(category: newVal!);
      },
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }
}
