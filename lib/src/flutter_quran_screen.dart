import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:flutter_quran/src/utils/string_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_bloc.dart';
import 'controllers/bookmarks_controller.dart';
import 'controllers/quran_controller.dart';
import 'models/quran_constants.dart';
import 'models/quran_page.dart';
import 'package:just_audio/just_audio.dart';
part 'utils/images.dart';
part 'utils/toast_utils.dart';
part 'widgets/bsmallah_widget.dart';
part 'widgets/quran_line.dart';
part 'widgets/quran_page_bottom_info.dart';
part 'widgets/surah_header_widget.dart';
part 'widgets/default_drawer.dart';
part 'widgets/ayah_long_click_dialog.dart';

class FlutterQuranScreen extends StatelessWidget {
  const FlutterQuranScreen(
      {this.showBottomWidget = true,
      this.useDefaultAppBar = true,
      this.bottomWidget,
      this.appBar,
      this.onPageChanged,
      this.isDarkTheme = false,
      super.key});

  ///[showBottomWidget] is a bool to disable or enable the default bottom widget
  final bool showBottomWidget;

  ///[showBottomWidget] is a bool to disable or enable the default bottom widget
  final bool useDefaultAppBar;

  ///[bottomWidget] if if provided it will replace the default bottom widget
  final Widget? bottomWidget;

  ///[appBar] if if provided it will replace the default app bar
  final PreferredSizeWidget? appBar;

  ///[onPageChanged] if provided it will be called when a quran page changed
  final Function(int)? onPageChanged;

  final isDarkTheme;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size; // Check for dark theme
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return MultiBlocProvider(
      providers: AppBloc.providers,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBar ?? (useDefaultAppBar ? AppBar(elevation: 0) : null),
          drawer: appBar == null && useDefaultAppBar
              ? _DefaultDrawer(
                  isDarkTheme: isDarkTheme,
                )
              : null,
          body: BlocBuilder<QuranCubit, List<QuranPage>>(
            builder: (ctx, pages) {
              return pages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: PageView.builder(
                        itemCount: pages.length,
                        controller: AppBloc.quranCubit.pageController,
                        onPageChanged: (page) {
                          if (onPageChanged != null) onPageChanged!(page);
                          AppBloc.quranCubit.saveLastPage(page + 1);
                        },
                        pageSnapping: true,
                        itemBuilder: (ctx, index) {
                          List<String> newSurahs = [];
                          return Container(
                              height: deviceSize.height * 0.8,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: index == 0 || index == 1

                                        /// This is for first 2 pages of Quran: Al-Fatihah and Al-Baqarah
                                        ? Center(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SurahHeaderWidget(
                                                      pages[index]
                                                          .ayahs[0]
                                                          .surahNameAr,
                                                      isDarkTheme: isDarkTheme),
                                                  if (index == 1)
                                                    BasmallahWidget(
                                                        isDarkTheme:
                                                            isDarkTheme),
                                                  ...pages[index]
                                                      .lines
                                                      .map((line) {
                                                    return BlocBuilder<
                                                        BookmarksCubit,
                                                        List<Bookmark>>(
                                                      builder:
                                                          (context, bookmarks) {
                                                        final bookmarksAyahs =
                                                            bookmarks
                                                                .map((bookmark) =>
                                                                    bookmark
                                                                        .ayahId)
                                                                .toList();
                                                        return Column(
                                                          children: [
                                                            SizedBox(
                                                                width: deviceSize
                                                                        .width -
                                                                    32,
                                                                child:
                                                                    QuranLine(
                                                                  line,
                                                                  bookmarksAyahs,
                                                                  bookmarks,
                                                                  boxFit: BoxFit
                                                                      .scaleDown,
                                                                  isDarkTheme:
                                                                      isDarkTheme, // Pass isDarkTheme
                                                                )),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          )

                                        /// Other Quran pages
                                        : LayoutBuilder(
                                            builder: (context, constraints) {
                                            return ListView(
                                                physics: currentOrientation ==
                                                        Orientation.portrait
                                                    ? const NeverScrollableScrollPhysics()
                                                    : null,
                                                children: [
                                                  ...pages[index]
                                                      .lines
                                                      .map((line) {
                                                    bool firstAyah = false;
                                                    if (line.ayahs[0]
                                                                .ayahNumber ==
                                                            1 &&
                                                        !newSurahs.contains(line
                                                            .ayahs[0]
                                                            .surahNameAr)) {
                                                      newSurahs.add(line
                                                          .ayahs[0]
                                                          .surahNameAr);
                                                      firstAyah = true;
                                                    }
                                                    return BlocBuilder<
                                                        BookmarksCubit,
                                                        List<Bookmark>>(
                                                      builder:
                                                          (context, bookmarks) {
                                                        final bookmarksAyahs =
                                                            bookmarks
                                                                .map((bookmark) =>
                                                                    bookmark
                                                                        .ayahId)
                                                                .toList();
                                                        return Column(
                                                          children: [
                                                            if (firstAyah)
                                                              SurahHeaderWidget(
                                                                  line.ayahs[0]
                                                                      .surahNameAr,
                                                                  isDarkTheme:
                                                                      isDarkTheme),
                                                            if (firstAyah &&
                                                                (line.ayahs[0]
                                                                        .surahNumber !=
                                                                    9))
                                                              BasmallahWidget(
                                                                  isDarkTheme:
                                                                      isDarkTheme),
                                                            SizedBox(
                                                              width: deviceSize
                                                                      .width -
                                                                  30,
                                                              height: ((currentOrientation ==
                                                                              Orientation
                                                                                  .portrait
                                                                          ? constraints
                                                                              .maxHeight
                                                                          : deviceSize
                                                                              .width) -
                                                                      (pages[index]
                                                                              .numberOfNewSurahs *
                                                                          (line.ayahs[0].surahNumber != 9
                                                                              ? 110
                                                                              : 80))) *
                                                                  0.95 /
                                                                  pages[index]
                                                                      .lines
                                                                      .length,
                                                              child: QuranLine(
                                                                line,
                                                                bookmarksAyahs,
                                                                bookmarks,
                                                                boxFit: line
                                                                        .ayahs
                                                                        .last
                                                                        .centered
                                                                    ? BoxFit
                                                                        .scaleDown
                                                                    : BoxFit
                                                                        .fill,
                                                                isDarkTheme:
                                                                    isDarkTheme, // Pass isDarkTheme
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }),
                                                ]);
                                          }),
                                  ),
                                  bottomWidget ??
                                      (showBottomWidget
                                          ? QuranPageBottomInfoWidget(
                                              page: index + 1,
                                              hizb: pages[index].hizb,
                                              surahName: pages[index]
                                                  .ayahs
                                                  .last
                                                  .surahNameAr)
                                          : Container()),
                                ],
                              ));
                        },
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _FlutterQuranSearchScreen extends StatefulWidget {
  const _FlutterQuranSearchScreen({required this.isDarkTheme});

  final bool isDarkTheme;

  @override
  State<_FlutterQuranSearchScreen> createState() =>
      _FlutterQuranSearchScreenState();
}

class _FlutterQuranSearchScreenState extends State<_FlutterQuranSearchScreen> {
  List<Ayah> ayahs = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بحث'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  onChanged: (txt) {
                    final searchResult = FlutterQuran().search(txt);
                    setState(() {
                      ayahs = [...searchResult];
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.isDarkTheme
                            ? Colors.white
                            : Colors.black, // Set border color based on theme
                      ),
                    ),
                    hintText: 'بحث',
                    hintStyle: TextStyle(
                      color: widget.isDarkTheme
                          ? Colors.white
                          : Colors.black, // Set hint text color based on theme
                    ),
                  ),
                  style: TextStyle(
                    color: widget.isDarkTheme
                        ? Colors.white
                        : Colors.black, // Set text color based on theme
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: ayahs
                        .map((ayah) => Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    ayah.ayah.replaceAll('\n', ' '),
                                    style: TextStyle(
                                      color: widget.isDarkTheme
                                          ? Colors.white
                                          : Colors
                                              .black, // Set text color based on theme
                                    ),
                                  ),
                                  subtitle: Text(
                                    ayah.surahNameAr,
                                    style: TextStyle(
                                      color: widget.isDarkTheme
                                          ? Colors.white
                                          : Colors
                                              .black, // Set text color based on theme
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    FlutterQuran().navigateToAyah(ayah);
                                  },
                                ),
                                Divider(
                                  color: widget.isDarkTheme
                                      ? Colors.grey[700]
                                      : Colors
                                          .grey, // Set divider color based on theme
                                  thickness: 1,
                                ),
                              ],
                            ))
                        .toList(),
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
