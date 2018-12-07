import 'package:flutter/material.dart';
import 'package:flutter_music/widgets/music_inherit_page.dart';
import 'dart:io';
import 'package:flutter_music/models/songs_data.dart';
import 'package:flutter_music/pages/current_playing.dart';
import 'package:flutter_music/widgets/drawer_page.dart';
class MusicPage extends StatefulWidget {
  @override
  createState() => new MusicPageState();
}

class MusicPageState extends State<MusicPage> {
  ScrollController _scrollController = ScrollController();//ListView的控制器
  Object  selected=  {};//选中的歌曲对象
  bool isPlaying = false;//是否播放
  @override
  void initState() {
    super.initState();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        print('滑动到了最底部');
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final rootData = MusicInheritedWidget.of(context);
    SongsData songsList = rootData.songsList;
    //跳转到播放页面
    void goCurrentPlaying(Object song,{bool nowTap: false}){
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new CurrentPlaying(songsList, song,nowPlaying: nowTap,)
        )
      );
    }
    //底部弹出框，显示一些列表
    void _showBottomSheet() {
      showModalBottomSheet<void>(context: context,builder: (BuildContext context){        
        return new Container(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                title: new Text('这里可能是你的第一首歌'),
                subtitle: new Text('演唱者'),
              ),
              new ListTile(
                title: new Text('这里可能是你的第一首歌'),
                subtitle: new Text('演唱者'),
              ),
              new ListTile(
                title: new Text('这里可能是你的第一首歌'),
                subtitle: new Text('演唱者'),
              )
            ],
          ),
        );      
      });
    }
    Widget _buildBottomMusicInfo() {
      var index = rootData.songsList.currentIndex == null || rootData.songsList.currentIndex < 0 ? 0 : rootData.songsList.currentIndex;
      var s = songsList.songs[index];
      var artFile =
              s.albumArt == null ? null : new File.fromUri(Uri.parse(s.albumArt));
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(//演唱者头像
                margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                child: new ClipOval(
                  child: new Image.file(artFile,width: 40.0,height: 40.0),
                ),
              ),
              new Container(//歌名和演唱者
                width: 150.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(s.title,style: new TextStyle(fontSize: 10.0,color: Colors.white),overflow: TextOverflow.ellipsis,),
                    new Text(s.artist,style: new TextStyle(fontSize: 10.0,color: Colors.white),),
                  ],
                ),
              )
            ],
          ),
          new Row(
            children: <Widget>[
              new IconButton(//播放、暂停按钮
                icon: new Icon(isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
                iconSize: 36.0,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;         
                  });
                },
              ),
              new IconButton(
                icon: new Icon(Icons.queue_music),
                iconSize: 36.0,
                color: Colors.white,
                onPressed: () => _showBottomSheet(),
              ),
            ],
          )
        ],
      );
    }
    // print(rootData);
    return new Scaffold(
      drawer: new DrawerPage(),
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('本地音乐'),
        actions: <Widget>[
          new Container(//跳转到播放页面的按钮
            padding: const EdgeInsets.only(right: 20.0,top: 15.0),
            child: new InkWell(
              child: new Icon(Icons.poll),
              onTap: () {
                return goCurrentPlaying(
                  rootData.songsList.songs[(rootData.songsList.currentIndex == null || rootData.songsList.currentIndex < 0
                    ? 0
                    :rootData.songsList.currentIndex)],
                  nowTap: true
                );
              },
            ),
          )
        ],
      ),
      body: rootData.isLoading ? new Center(child: new CircularProgressIndicator(),) : RefreshIndicator(
        onRefresh: _onRefresh,
        child: buildMusicList(songsList),
      ),
      bottomSheet: new Container(
        height: 50.0,
        color: Colors.blueAccent,
        child: new Center(
          child: _buildBottomMusicInfo(),
        ),
      ),
    );
  }

  Widget buildMusicList(songsList) {
    return new ListView.builder(
      padding: const EdgeInsets.only(bottom: 50.0),
      controller: _scrollController,
      itemCount: songsList.songs.length,
      itemBuilder: (context, int index) {
        var song = songsList.songs[index];
        final isAlreadySelected = song == selected ? true : false;
        // var artFile = songsList[index].albumArt == null ? null : new File.fromUri(Uri.parse(songsList[index].albumArt));            
        return new Column(
          children: <Widget>[
            new ListTile(
              dense: true,
              selected: isAlreadySelected,
              title: new Text(song.title,style: new TextStyle(fontSize: 14.0),maxLines: 1,overflow: TextOverflow.ellipsis,),
              trailing: new GestureDetector(
                child: new Icon(Icons.more_horiz),
                onTap: () => _setMusic(song),
              ),
              subtitle:new Row(
                children: <Widget>[
                  new Icon(Icons.check_circle,color: Colors.blue,size: 15.0,),
                  new Text(
                    "${song.artist}·${song.album}",
                    style: new TextStyle(fontSize: 10.0,color: isAlreadySelected ? Colors.blue : Colors.black87),
                  )
                ],
              ),
              onTap: () {
                songsList.setCurrentIndex(index);
                setState(() {//歌曲选中操作
                  if(!isAlreadySelected){
                    selected = song;
                  }
                  isPlaying = true;
                });     
                // Navigator.push(
                //   context,
                //   new MaterialPageRoute(
                //     builder: (context) => new CurrentPlaying(songsList,song),
                //   )
                // );
              },
            ),
            new Divider(color: Colors.black87,height: 1.0,indent: 15.0,)
          ],
        ); 
      }         
    );
  }
  void _setMusic(song) {
    showModalBottomSheet<void>(context: context,builder: (BuildContext context) {
      return new Container(
        padding: const EdgeInsets.all(15.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('当前歌曲:${song.title}',style: TextStyle(color: Colors.blueAccent,fontSize: 20.0)),
            new Container(
              height: 50.0,
              width: 500.0,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0,color: Colors.black12))
              ),
              child: new Text('设为铃声'),
            ),
            new Container(
              height: 50.0,
              width: 500.0,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0,color: Colors.black12))
              ),
              child: new Text('收藏'),
            ),
            new Container(
              height: 50.0,
              width: 500.0,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0,color: Colors.black12))
              ),
              child: new Text('分享'),
            ),
            new Container(
              height: 50.0,
              width: 500.0,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0,color: Colors.black12))
              ),
              child: new Text('删除'),
            )
          ],
        ),
      );
    });
  }
  Future<Null> _onRefresh() async{
    await Future.delayed(Duration(seconds: 3),() {
      print('refresh');
    });
  }
}