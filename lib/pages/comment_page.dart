import 'package:flutter/material.dart';

class CommentPage extends StatelessWidget{
  CommentPage({Key key})
    :super(key:key);
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('返回'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(Icons.error),
            new Text('糟糕 发生了错误')
          ],
        )
      ),
    );
  }
}