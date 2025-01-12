part of '../flutter_quran_screen.dart';

class AyahLongClickDialog extends StatelessWidget {
  const AyahLongClickDialog(this.ayah, {super.key, required this.isDarkTheme});

  final Ayah ayah;
  final bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme
    final backgroundColor = isDarkTheme ? Colors.grey[900] : const Color(0xFFF7EFE0);
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final iconColor = isDarkTheme ? Colors.white : const Color(0xFF798FAB);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 3,
        backgroundColor: backgroundColor, // Set background color based on theme
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أضف علامة',
                  style: TextStyle(
                    color: textColor, // Set text color based on theme
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...AppBloc.bookmarksCubit.bookmarks
                    .sublist(0, 3)
                    .map((bookmark) => ListTile(
                  leading: Icon(
                    Icons.bookmark,
                    color: Color(bookmark.colorCode), // Keep bookmark color
                  ),
                  title: Text(
                    bookmark.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor, // Set text color based on theme
                    ),
                  ),
                  onTap: () {
                    AppBloc.bookmarksCubit.saveBookmark(
                        ayahId: ayah.id,
                        page: ayah.page,
                        bookmarkId: bookmark.id);
                    Navigator.of(context).pop();
                  },
                )),
                const Divider(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: AppBloc
                            .quranCubit.staticPages[ayah.page - 1].ayahs
                            .firstWhere((element) => element.id == ayah.id)
                            .ayah))
                        .then((value) =>
                        ToastUtils().showToast("تم النسخ الى الحافظة"));
                    Navigator.of(context).pop();
                  },
                  child: ListTile(
                    title: Text(
                      "نسخ الى الحافظة",
                      style: TextStyle(color: textColor), // Set text color based on theme
                    ),
                    leading: Icon(
                      Icons.copy_rounded,
                      color: iconColor, // Set icon color based on theme
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}