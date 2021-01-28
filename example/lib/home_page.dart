import 'package:example/optimize_page.dart';
import 'package:flutter/material.dart';

import 'common_page.dart';

class ListTileInfo {
  final String title;
  final VoidCallback tapAction;
  final String subTitle;

  ListTileInfo({this.title, this.tapAction, this.subTitle});
}

class PerformanceListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<ListTileInfo> itemList = [
      ListTileInfo(
          title: '普通页面',
          subTitle: '普通页面，没优化的',
          tapAction: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CommonPage()));
          }),
      ListTileInfo(
          title: '优化页面',
          subTitle: 'layout和paint分帧进行',
          tapAction: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OptimizePage()));
          }),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('延时小部件测试'),
      ),
      body: ListView.separated(
        itemBuilder: (_, index) {
          ListTileInfo info = itemList[index];
          return GestureDetector(
            onTap: info.tapAction,
            child: ListTile(
              title: Text(info.title),
              subtitle: info.subTitle != null ? Text(info.subTitle) : null,
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(
          height: 1,
        ),
        itemCount: itemList.length,
      ),
    );
  }
}
