import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomNumberProvider = StateProvider<int>((ref){
  return 10;
});