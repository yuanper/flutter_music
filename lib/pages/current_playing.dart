import 'package:flutter/material.dart';
import 'package:flutter_music/models/songs_data.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter_music/pages/comment_page.dart';
import 'dart:io';
enum PlayerState{stopped,playing,paused}
class CurrentPlaying extends StatefulWidget {
  final song;
  final SongsData songsList;
  final bool nowPlaying;
  CurrentPlaying(this.songsList,this.song,{this.nowPlaying});
  @override 
  createState() => new CurrentPlayingState();
}

class CurrentPlayingState extends State<CurrentPlaying> {
  Song song;
  MusicFinder audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
    duration != null ?duration.toString().split('.').first : '';
  get positionText => 
    position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  bool isAlreadySaved = false;
  @override
  void initState() {
    super.initState();
    initPlaying();
  }

  Future initPlaying() async{
    if(audioPlayer == null ){
      audioPlayer = widget.songsList.audioPlayer;
    }
    setState(() {
      song = widget.song;
      if(widget.nowPlaying == null || widget.nowPlaying == false){
        if(playerState != PlayerState.stopped){
          stop();
        }
      }
      play(song);
    });
    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }
  Future play(Song s) async{
    if(s != null) {
      final result = await audioPlayer.play(s.uri,isLocal:true);
      if(result == 1){
        setState(() {
          playerState = PlayerState.playing;
          song = s;
        });
      }
    }
  }
  Future pause() async{
    final result = await audioPlayer.pause();
    if(result == 1) setState(() => playerState = PlayerState.paused);
  }
  Future stop() async{
    final result = await audioPlayer.stop();
    if(result == 1){
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
    }
  }
  Future mute(bool muted) async{
    final result = await audioPlayer.mute(muted);
    if(result == 1) setState(() => isMuted = muted);
  }
  void onComplete() {
    setState(() {
          playerState = PlayerState.stopped;
    });
  }
  Future next(SongsData songs) async{
    stop();
    setState(() {
      play(songs.nextSong);
    });
  }
  Future prev(SongsData songs) async{
    stop();
    setState(() {
      play(songs.prevSong);
    });
  }
  Future shuffle(SongsData songs) async{
    stop();
    setState(() {
      play(songs.randomSong);
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Widget _buildPlayer() {
      var artFile =
              song.albumArt == null ? null : new File.fromUri(Uri.parse(song.albumArt));
      return new Container(
        padding: new EdgeInsets.only(top:16.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          new Center(//唱曲者
            child: new Text('一' + song.artist + '一',style: new TextStyle(color: Colors.white),),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 15.0,bottom: 25.0),
            child: buildTage(),//标准、视频、音效
          ),
          new Center(//头像
            child: new Container(
              width: 280.0,
              height: 280.0,
              margin: const EdgeInsets.only(bottom: 30.0),
              child: new ClipOval(
                child: new Image.file(artFile,fit: BoxFit.fill,)
              ),
            ),
          ),
          duration == null
            ? new Container()
            : new Row(//播放进度条
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Text(position != null ? "${positionText ?? ''}":'',style: new TextStyle(fontSize: 12.0,color: Colors.white),),
                new Container(
                  width: 260.0,
                  child: new Slider(//进度条
                    inactiveColor: Colors.black45,
                    activeColor: Colors.black87,
                    value: position?.inMilliseconds?.toDouble() ?? 0,
                    onChanged: (double value) =>
                        audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble()
                  ),
                ),
                new Text(position != null ? "${durationText ?? ''}":'',style: new TextStyle(fontSize: 12.0,color: Colors.white),),
              ],
            ),
          new Container(
            margin: const EdgeInsets.only(top: 15.0,bottom: 15.0),
            child: new Row(//播放按钮
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.shuffle),
                  iconSize: 25.0,
                  onPressed: () => shuffle(widget.songsList),
                  color: Colors.white,
                ),
                new IconButton(
                  icon: new Icon(Icons.skip_previous),
                  iconSize: 35.0,
                  onPressed: () => prev(widget.songsList),//上一首
                  color: Colors.white,
                ),
                new IconButton(
                  icon: new Icon(isPlaying ? Icons.pause : Icons.play_circle_outline),
                  iconSize: 50.0,
                  onPressed: () => isPlaying ? pause() :play(song),//播放或者暂停
                  color: Colors.white,
                ),
                new IconButton(
                  icon: new Icon(Icons.skip_next),
                  iconSize: 35.0,
                  onPressed: () =>next(widget.songsList), //下一首
                  color: Colors.white,
                ),
                new IconButton(
                  icon: new Icon(Icons.queue_music),
                  iconSize: 25.0,
                  onPressed: _showMusicList,
                  color: Colors.white,
                )
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(//喜欢
                icon: new Icon(isAlreadySaved ? Icons.favorite : Icons.favorite_border),
                iconSize: 25.0,
                onPressed: () {
                  setState(() {
                    if(isAlreadySaved){
                      isAlreadySaved = false;
                      _confirmDelete();
                    }else{
                      isAlreadySaved = true;
                    }                
                  });
                },
                color: isAlreadySaved ? Colors.red :Colors.white70,
              ),
              new IconButton(//下载
                icon: new Icon(Icons.file_download),
                iconSize: 25.0,
                onPressed: () {
                  
                },
                color: Colors.white70,
              ),
              new IconButton(//分享
                icon: new Icon(Icons.share),
                iconSize: 25.0,
                onPressed: _shareBottomSheet,
                color: Colors.white70,
              ),
              new IconButton(//评论
                icon: new Icon(Icons.comment),
                iconSize: 25.0,
                onPressed: _goCommentPage,
                color: Colors.white70,
              )
            ],
          )
        ])
      );
    }
    return new Scaffold(
      backgroundColor: Colors.brown,
      appBar: new AppBar(
        backgroundColor: Colors.brown,
        title: new Text(song.title),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.more_horiz),
            onPressed: () {

            },
          ),
        ],
      ),
      body: _buildPlayer(),
    );
  }
  
  Widget buildTage() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          width: 50.0,
          height: 20.0,
          margin: const EdgeInsets.only(right: 15.0),
          child: new DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 1.0,color: Colors.white),
            ),
            child: new Text('标准',style: new TextStyle(color: Colors.white),textAlign: TextAlign.center,),
          )
        ),
        new Container(
          width: 50.0,
          height: 20.0,
          margin: const EdgeInsets.only(right:15.0),
          child: new DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 1.0,color: Colors.white),
            ),
            child: new Text('视频',style: new TextStyle(color: Colors.white),textAlign: TextAlign.center,),
          )
        ),
        new Container(
          width: 50.0,
          height: 20.0,
          child: new DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 1.0,color: Colors.white),
            ),
            child: new Text('音效',style: new TextStyle(color: Colors.white),textAlign: TextAlign.center,),
          )
        )
      ],
    );
  }
  void _showMusicList() {//音乐列表
    showModalBottomSheet<void>(context: context,builder: (BuildContext context){
      return new Container(
        color: Colors.white12,
        padding: const EdgeInsets.all(10.0),
        child: new ListView.builder(
          itemCount: widget.songsList.length,
          itemBuilder: (BuildContext context,int index){
            var song = widget.songsList.songs[index];
            // var artFile = songsList[index].albumArt == null ? null : new File.fromUri(Uri.parse(songsList[index].albumArt));            
            return new Column(
              children: <Widget>[
                new ListTile(
                  dense: true,
                  title: new Text(song.title,style: new TextStyle(fontSize: 14.0),),
                  trailing: new GestureDetector(
                    child: new Icon(Icons.more_horiz),
                    onTap: () {
                      
                    },
                  ),
                  subtitle: new Text(
                    "${song.artist}·${song.album}",
                    style: new TextStyle(fontSize: 10.0,color: Colors.black87),
                  ),
                  onTap: () {
                    widget.songsList.setCurrentIndex(index);
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => new CurrentPlaying(widget.songsList,song),
                      )
                    );
                  },
                ),
                new Divider(color: Colors.black87,height: 1.0,indent: 15.0,)
              ],
            ); 
          },
        ),
      );
    });
  }
  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text('确定从我喜欢中删除这首歌？'),
          contentPadding: const EdgeInsets.fromLTRB(24.0,10.0,24.0,10.0),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text('确定删除'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  void _shareBottomSheet() {
    showModalBottomSheet<void>(context: context,builder: (BuildContext context) {
      return new Container(
        height: 120.0,
        padding: const EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/wechat.png',height: 50.0,fit: BoxFit.fitHeight,),
                new Text('微信')
              ],
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/qq.png',height: 50.0,fit: BoxFit.fitHeight,),
                new Text('qq好友')
              ],
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/kongjian.png',height: 50.0,fit: BoxFit.fitHeight,),
                new Text('空间')
              ],
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/peng_you_quan.png',height: 50.0,fit: BoxFit.fitHeight,),
                new Text('朋友圈')
              ],
            )
          ],
        ),
      );
    });
  }
  void _goCommentPage() {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new CommentPage(),
      )
    );
  }
}