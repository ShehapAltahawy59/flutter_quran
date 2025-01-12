part of '../flutter_quran_screen.dart';

class _DefaultDrawer extends StatelessWidget {
  const _DefaultDrawer({required this.isDarkTheme});

  final bool isDarkTheme;

  // Function to launch the Surah audio URL
  void _playSurahAudio(int surahIndex) async {
    final surahAudioUrl =
        'https://alquran.cloud/cdn/$surahIndex'; // Replace with the correct URL format
    final uri =
        Uri.parse(surahAudioUrl); // Convert the URL string to a Uri object

    if (await canLaunchUrl(uri)) {
      // Use canLaunchUrl instead of canLaunch
      await launchUrl(uri); // Use launchUrl instead of launch
    } else {
      throw 'Could not launch $surahAudioUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final jozzs = FlutterQuran().getAllJozzs();
    final hizbs = FlutterQuran().getAllHizbs();
    final surahs = FlutterQuran().getAllSurahs();

    // Define colors based on the theme
    final backgroundColor = isDarkTheme ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final iconColor = isDarkTheme ? Colors.white : Colors.blueAccent;

    return Drawer(
      child: Container(
        color: backgroundColor, // Set background color based on theme
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.search, color: iconColor), // Set icon color
                    title: Text(
                      'بحث',
                      style: TextStyle(color: textColor), // Set text color
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => _FlutterQuranSearchScreen(
                              isDarkTheme: isDarkTheme)));
                    },
                  ),
                  ExpansionTile(
                    leading:
                        Icon(Icons.list, color: iconColor), // Set icon color
                    title: Text(
                      'الفهرس',
                      style: TextStyle(color: textColor), // Set text color
                    ),
                    children: [
                      ExpansionTile(
                        leading: Icon(Icons.book,
                            color: Colors.green), // Keep green for consistency
                        title: Text(
                          'الجزء',
                          style: TextStyle(color: textColor), // Set text color
                        ),
                        children: List.generate(
                          jozzs.length,
                          (jozzIndex) => ExpansionTile(
                            title: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                jozzs[jozzIndex],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Set text color
                                ),
                              ),
                            ),
                            children: List.generate(2, (index) {
                              final hizbIndex = (index == 0 && jozzIndex == 0)
                                  ? 0
                                  : ((jozzIndex * 2 + index));
                              return ListTile(
                                title: Text(
                                  hizbs[hizbIndex],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor, // Set text color
                                  ),
                                ),
                                onTap: () {
                                  FlutterQuran().navigateToHizb(hizbIndex + 1);
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.menu_book_outlined,
                            color:
                                Colors.orange), // Keep orange for consistency
                        title: Text(
                          'السورة',
                          style: TextStyle(color: textColor), // Set text color
                        ),
                        children: List.generate(
                          surahs.length,
                          (index) => ListTile(
                            title: Text(
                              surahs[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor, // Set text color
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.play_arrow,
                                  color: iconColor), // Play icon
                              onPressed: () => _playSurahAudio(
                                  index + 1), // Play Surah audio
                            ),
                            onTap: () =>
                                FlutterQuran().navigateToSurah(index + 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.bookmark,
                        color: Colors
                            .deepPurpleAccent), // Keep purple for consistency
                    title: Text(
                      'العلامات',
                      style: TextStyle(color: textColor), // Set text color
                    ),
                    children: FlutterQuran()
                        .getUsedBookmarks()
                        .map((bookmark) => ListTile(
                              leading: Icon(
                                Icons.bookmark,
                                color: Color(
                                    bookmark.colorCode), // Keep bookmark color
                              ),
                              title: Text(
                                bookmark.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor, // Set text color
                                ),
                              ),
                              onTap: () =>
                                  FlutterQuran().navigateToBookmark(bookmark),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
