import 'package:flutter_bloc/flutter_bloc.dart';
import '/../core/functions/debug_print_extension.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    'onCreate -- ${bloc.runtimeType}'.dPrint();
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    'onChange -- ${bloc.runtimeType}, $change'.dPrint();
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    'onError -- ${bloc.runtimeType}, $error'.dPrint();
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    'onClose -- ${bloc.runtimeType}'.dPrint();
  }
}
