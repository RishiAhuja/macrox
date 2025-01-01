import 'package:blog/core/configs/constants/app_constants/constants.dart';
import 'package:flutter/material.dart';

extension MobileX on BuildContext {
  bool get isMobile {
    return MediaQuery.of(this).size.width < Constants.mobileWidth
        ? true
        : false;
  }
}
