import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter_music/models/songs_data.dart';
import 'package:flutter_music/pages/music_page.dart';
import 'package:flutter_music/widgets/music_inherit_page.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SongsData songsList;
  bool isLoading = true;
  MusicFinder audioPlayer = new MusicFinder();
  @override
  void initState() {
    super.initState();
    //获取平台数据，本地音乐文件夹中的数据
    initPlatformState();
  }

  initPlatformState() async {
    isLoading = true;
    var songs;
    try {
      songs = await MusicFinder.allSongs();
    } catch (e) {
      print("failed to get songs: '${e.message}'.");
    }
    if(!mounted) return;

    setState(() {
      songsList = new SongsData(songs);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //把一些数据封装在这个顶层的组件中，让其子组件都能访问里面的数据
    return new MusicInheritedWidget(
      songsList,
      isLoading,
      new MusicPage(),
    );
    // return new Scaffold(
    //   appBar: new AppBar(
    //     title: new Text('music'),
    //   ),
    //   body: new Center(
    //     child: new Text('nihao'),
    //   ),
    // );
  }
}