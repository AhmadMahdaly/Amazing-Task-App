import 'package:flutter_bloc/flutter_bloc.dart';

/// A custom Cubit class that safely handles state emissions.
/// It overrides the standard `emit` method to first check if the cubit
/// is closed. This prevents the common 'Bad state: Cannot emit new states
/// after calling close' error that occurs when an async operation
/// completes after the widget and its cubit have been disposed.
abstract class SafeCubit<State> extends Cubit<State> {
  SafeCubit(super.initialState);

  @override
  void emit(State state) {
    // Check if the cubit is closed before emitting a new state.
    // The `isClosed` property is inherited from BlocBase.
    if (!isClosed) {
      super.emit(state);
    }
  }
}
