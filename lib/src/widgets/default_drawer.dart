part of '../flutter_quran_screen.dart';

class _DefaultDrawer extends StatelessWidget {
  const _DefaultDrawer({required this.isDarkTheme});

  final bool isDarkTheme;

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
                          (index) {
                            final surah = 'Surah ${index + 1}';
                            return ListTile(
                              title: Text(
                                surahs[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Set text color
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  AudioManager().isPlaying(surah)
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: iconColor,
                                ),
                                onPressed: () =>
                                    AudioManager().playSurahAudio(index + 1),
                              ),
                              onTap: () =>
                                  FlutterQuran().navigateToSurah(index + 1),
                            );
                          },
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

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSurah;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  Future<void> playSurahAudio(int surahIndex) async {
    final surahAudioUrl =
        'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahIndex.mp3';

    try {
      if (_isPlaying && _currentSurah == 'Surah $surahIndex') {
        // If the same Surah is already playing, pause it
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        // Load and play the new Surah
        await _audioPlayer.setUrl(surahAudioUrl); // Load the audio URL
        await _audioPlayer.play(); // Start playback
        _isPlaying = true;
        _currentSurah = 'Surah $surahIndex';
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentSurah = null;
  }

  bool isPlaying(String surah) {
    return _isPlaying && _currentSurah == surah;
  }
}
