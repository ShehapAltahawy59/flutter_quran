part of '../flutter_quran_screen.dart';

class BasmallahWidget extends StatelessWidget {
  const BasmallahWidget({required this.isDarkTheme,super.key});
  final bool isDarkTheme;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        style: FlutterQuran()
        .hafsStyle
        .copyWith(
      color: isDarkTheme ? Colors.white : Colors.black,
    )))
    ;
  }
}
