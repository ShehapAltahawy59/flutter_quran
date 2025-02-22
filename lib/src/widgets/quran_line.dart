part of '../flutter_quran_screen.dart';

class QuranLine extends StatelessWidget {
  const QuranLine(
      this.line,
      this.bookmarksAyahs,
      this.bookmarks, {
        super.key,
        this.boxFit = BoxFit.fill,
        this.onLongPress,
        this.isDarkTheme = false, // Add isDarkTheme parameter
      });

  final Line line;
  final List<int> bookmarksAyahs;
  final List<Bookmark> bookmarks;
  final BoxFit boxFit;
  final Function? onLongPress;
  final bool isDarkTheme; // Add isDarkTheme property

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: boxFit,
      child: RichText(
        text: TextSpan(
          children: line.ayahs.reversed.map((ayah) {
            return WidgetSpan(
              child: GestureDetector(
                onLongPress: () {
                  if (onLongPress != null) {
                    onLongPress!(ayah);
                  } else {
                    final bookmarkId = bookmarksAyahs.contains(ayah.id)
                        ? bookmarks[bookmarksAyahs.indexOf(ayah.id)].id
                        : null;
                    if (bookmarkId != null) {
                      AppBloc.bookmarksCubit.removeBookmark(bookmarkId);
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AyahLongClickDialog(ayah,isDarkTheme: isDarkTheme),
                      );
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: bookmarksAyahs.contains(ayah.id)
                        ? Color(bookmarks[bookmarksAyahs.indexOf(ayah.id)]
                        .colorCode)
                        .withOpacity(0.7)
                        : null,
                  ),
                  child: Text(
                    ayah.ayah,
                    style: FlutterQuran().hafsStyle.copyWith(
                      color: isDarkTheme ? Colors.white : Colors.black, // Adjust text color
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          style: FlutterQuran().hafsStyle.copyWith(
            color: isDarkTheme ? Colors.white : Colors.black, // Adjust default text color
          ),
        ),
      ),
    );
  }
}