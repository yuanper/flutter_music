import 'package:flutter_music/models/songs_data.dart';
import 'package:flutter/material.dart';

class MusicInheritedWidget extends InheritedWidget {
  final SongsData songsList;
  final bool isLoading;

  const MusicInheritedWidget(this.songsList,this.isLoading,child)
    :super(child:child);

  static MusicInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MusicInheritedWidget);
  }

  @override 
  bool updateShouldNotify(MusicInheritedWidget oldWidget) => songsList != oldWidget.songsList || isLoading != oldWidget.isLoading;
  
}
