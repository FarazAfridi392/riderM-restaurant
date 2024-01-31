import 'package:flutter/foundation.dart';

void customPrint(var message) {
  if (kDebugMode) {
    print(message);
  }
}