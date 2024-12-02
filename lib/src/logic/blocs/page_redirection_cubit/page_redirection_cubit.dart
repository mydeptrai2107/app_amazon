import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/auth_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'page_redirection_state.dart';

class PageRedirectionCubit extends Cubit<PageRedirectionState> {
  final AuthRepository authRepository;
  UserRepository userRepository = UserRepository();
  PageRedirectionCubit(this.authRepository) : super(PageRedirectionInitial());

  void redirectUser() async {
    String userType;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('x-auth-token');
      bool? isShop = prefs.getBool('is-shop');

      if (token == null) {
        prefs.setString('x-auth-token', '');
        token = '';
      }

      User user =
          await userRepository.getUserDataInitial(token, isShop ?? false);
      userType = user.type;
      emit(PageRedirectionSuccess(isValid: true, userType: userType));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
