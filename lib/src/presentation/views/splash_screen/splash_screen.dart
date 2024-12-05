import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/page_redirection_cubit/page_redirection_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    context.read<PageRedirectionCubit>().redirectUser();
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: BlocConsumer<PageRedirectionCubit, PageRedirectionState>(
        listener: (context, state) {
          if (state is PageRedirectionSuccess) {
            if (state.userType == 'admin') {
              context.goNamed(AppRouteConstants.adminBottomBarRoute.name);
            } else {
              context.goNamed(AppRouteConstants.bottomBarRoute.name);
            }
          }
        },
        builder: ((context, state) {
          return Scaffold(
            body: Center(
              child: Image.asset(
                'assets/images/amazon_in_alt.png',
                height: 52,
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.width,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.pushNamed(
                          AppRouteConstants.authRoute.name,
                          extra: true,
                        );
                      },
                      label: const Text('Dành cho shop'),
                      icon: const Icon(Icons.person),
                    ),
                  ),
                  SizedBox(
                    width: size.width,
                    child: FilledButton.icon(
                      onPressed: () => context
                          .goNamed(AppRouteConstants.bottomBarRoute.name),
                      label: const Text('Bắt đầu mua sắm'),
                      icon: const Icon(Icons.shopping_bag),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
