import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget {  
  @override
  createState() => DrawerPageState();
}

class DrawerPageState extends State<DrawerPage> {
  bool close = true;
  bool tip = true;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 45.0, 10.0, 10.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
              dense: true,
              title: new Text('个性装扮'),
              trailing: new Text('默认皮肤',style: new TextStyle(fontSize: 10.0,color: Colors.black45),),
            ),
            new ListTile(
              title: new Text('消息中心'),
            ),
            new SwitchListTile(
              value: close,
              title: new Text('定时关闭'),
              onChanged: (bool value){
                setState(() {
                  close = !close;
                });
              },
              activeColor: Colors.blue,
            ),
            new SwitchListTile(
              value: tip,
              title: new Text('流量提醒'),
              onChanged: (bool value){
                setState(() {
                  tip = !tip;
                });
              },
              activeColor: Colors.blue,
            ),
            new ListTile(
              title: new Text('微云音乐网盘'),
            ),
            new ListTile(
              title: new Text('导入外部歌曲'),
            ),
            new ListTile(
              title: new Text('清理占用空间'),
            ),
            new ListTile(
              title: new Text('帮助与反馈'),
            ),
            new Container(
              margin: const EdgeInsets.only(top:140.0,),
              padding: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1.0,color: Colors.black26))
              ),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.brightness_high,color: Colors.blue,),
                  new Text('设置')
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}