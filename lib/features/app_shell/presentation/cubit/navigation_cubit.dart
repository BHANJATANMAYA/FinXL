import 'package:finxl/core/navigation/app_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.dashboard);

  void selectTab(AppTab tab) {
    if (tab == state) {
      return;
    }
    emit(tab);
  }
}
