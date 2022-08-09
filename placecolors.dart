import 'dart:ui';
import 'dart:math';

class PlaceColors {

  static const Color primaryBackground = Color(0xFF111111);
  static const Color gray = Color(0xFF888888);
  static const Color darkGray = Color(0xFF222222);
  static const Color orange = Color(0xFFFF4500);
  static const Color purple = Color(0xFF820080);
  static const Color pink1 = Color(0xFFF10086);
  static const Color pink2 = Color(0xFFFFA7D1);
  static const Color yellow1 = Color(0xFFFFF323);
  static const Color yellow2 = Color(0xFFE59500);
  static const Color blue1 = Color(0xFF00D3DD);
  static const Color blue2 = Color(0xFF0083C7);
  static const Color blue3 = Color(0xFF0000EA);
  static const Color green1 = Color(0xFF02BE01);
  static const Color green2 = Color(0xFF94E044);
  static const Color brown = Color(0xFFA06A42);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red1 = Color(0xFFE50000);
  static const Color red2 = Color(0xFF990000);

  static Color randomColor() {

    Random select = Random();

    List<Color> choices = const [
      Color(0xFF111111),Color(0xFF888888),Color(0xFF222222),
      Color(0xFFFF4500),Color(0xFF820080),Color(0xFFF10086),
      Color(0xFFFFA7D1),Color(0xFFFFF323),Color(0xFFE59500),
      Color(0xFF00D3DD),Color(0xFF0083C7),Color(0xFF0000EA),
      Color(0xFF02BE01),Color(0xFF94E044),Color(0xFFA06A42),
      Color(0xFFFFFFFF),Color(0xFF000000),Color(0xFFE50000),
      Color(0xFF990000)
      ];
  
    return choices[select.nextInt(choices.length)];
    
  }

}
