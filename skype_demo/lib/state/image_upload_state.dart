import 'package:flutter/material.dart';
import 'package:flutter_projects/enum/view_state.dart';
import 'package:get/get.dart';

class UploadingState extends GetxController {
  var viewState = ViewState.idle.obs;

  // ViewState get getViewState => _viewState;

  setToLoading() {
    viewState.value = ViewState.loading;
  }

  setToIdle() {
    viewState.value = ViewState.idle;
  }
}
