import 'dart:math';

import 'package:flutter/material.dart';

class GridInfo {
  final String url;
  final String title;
  final String icon;
  final String aboveIcon;
  final String subTitle;
  final int index;

  GridInfo(
      {@required this.index,
      @required this.icon,
      @required this.url,
      @required this.title,
      @required this.subTitle,
      @required this.aboveIcon});
}

class CommonPage extends StatefulWidget {
  @override
  CommonPageState createState() => CommonPageState();
}

class CommonPageState extends State<CommonPage> {
  List<GridInfo> dataList = [];
  ScrollController _firstScrollController = ScrollController();
  double itemWidth = 0;
  double itemHeight = 0;
  List<String> imageUrls = [
    '2774198',
    '6194942',
    '2209382',
    '3614942',
    '1906802',
    '5193557',
    '6161317',
    '5859431',
    '6341566',
    '5484328',
    '4685127',
    '3206433',
    '4852349',
    '1376889',
    '5560899',
    '4987688',
    '5949511',
    '6126297',
    '3467152',
    '5707732',
    '5591661',
    '5727545',
    '4617820',
    '4333606',
    '5273001',
    '3673521',
    '5232105',
    '5722868',
    '5567002',
    '1669072',
    '6334707',
    '5716323',
    '6212297',
    '3220237',
    '5855535',
    '5272575',
    '6021588',
    '4000213',
    '5993563',
    '3402578',
    '6066993',
    '5390006',
    '3410287',
    '6070378',
    '6167767',
    '5968900',
    '1030934',
    '1683994',
    '6102555',
    '4468058',
    '5914166',
    '6291566',
    '4621378',
    '5965972',
    '5913391',
    '5312333',
    '5101217',
    '5855527',
    '6061293',
    '5770047',
    '4558306',
    '2109762',
    '5913949',
    '6070129',
    '2886574',
    '6032603',
    '5615782',
    '5997712',
  ];
  @override
  void initState() {
    super.initState();
    String content = '拉开就分开了拉萨附近都是六块腹肌饭撒的克己复礼看到撒酒疯黎噶搜ID股份分开那份礼物来自空间的佛i阿哥辣椒素的弗兰克为列宁格勒';
    Random random = Random();
    int i = 0;
    imageUrls.forEach((element) {
      int titleStart = random.nextInt(content.length - 5);
      int subTitleStart = random.nextInt(content.length - 5);
      dataList.add(
        GridInfo(
          index: i,
          aboveIcon: random.nextInt(3).toString(),
          icon: random.nextInt(9).toString(),
          subTitle: content.substring(titleStart, titleStart + random.nextInt(4) + 1),
          title: content.substring(subTitleStart, subTitleStart + random.nextInt(4) + 1),
          url:
              'https://images.pexels.com/photos/$element/pexels-photo-$element.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=200',
        ),
      );
      i++;
    });
  }

  Widget pageBuild(
      {ScrollController controller,
      Widget childBuilder(
        GridInfo info,
      )}) {
    return GridView.builder(
      controller: controller,
      itemCount: dataList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 0.8,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (_, index) {
        GridInfo info = dataList[index];
        return Padding(
          padding: const EdgeInsets.all(4),
          child: childBuilder(info),
        );
      },
    );
  }

  Widget networkImage(GridInfo info, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        info.url,
        fit: BoxFit.cover,
        width: width,
        height: height,
        cacheWidth: (width * 2).toInt(),
        cacheHeight: (height * 2).toInt(),
      ),
    );
  }

  Widget detailWidget(GridInfo info, double width, double height) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              networkImage(info, 60, 60),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 4)],
                ),
                child: Text(
                  info.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.yellow.withOpacity(0.5),
                child: Text(
                  info.index.toString(),
                ),
              ),
              Image.asset(
                'assets/icon_a_${info.aboveIcon}.png',
                width: 35,
              ),
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    info.title,
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    info.title,
                    style: TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ],
              ),
              Text(
                info.subTitle,
                style: TextStyle(fontSize: 14, color: Colors.black12),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.red,
                  ),
                ),
                child: Image.asset(
                  'assets/icon_a_${info.aboveIcon}.png',
                  width: 20,
                ),
              ),
            ],
          ),
          Text(
            info.subTitle + info.title,
            style: TextStyle(fontSize: 12, color: Colors.red[100]),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.red,
              ),
            ),
            child: Text(
              info.subTitle + info.subTitle,
              style: TextStyle(fontSize: 13, color: Colors.blue[100]),
            ),
          ),
        ],
      ),
    );
  }

  Widget item(GridInfo info) {
    return Column(
      children: [
        Expanded(
          child: detailWidget(info, itemWidth, itemHeight - 30),
        ),
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Text(
                info.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Image.asset(
                'assets/icon_${info.icon}.png',
                width: 25,
              ),
              Spacer(),
              Text(
                info.subTitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get pageTitle => '优化前页面';
  @override
  Widget build(BuildContext context) {
    itemWidth = MediaQuery.of(context).size.width / 2 - 8;
    itemHeight = itemWidth / 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          FlatButton(
            onPressed: () {
              // setState(() {
              //   PaintingBinding.instance.imageCache.clear();
              // });
              ScrollController scrollController = _firstScrollController;
              if (scrollController.offset > 100) {
                scrollController.animateTo(0, duration: Duration(milliseconds: 2000), curve: Curves.linear);
              } else {
                scrollController.animateTo(7000, duration: Duration(milliseconds: 2000), curve: Curves.linear);
              }
            },
            child: Text('滚动'),
          ),
        ],
      ),
      body: pageBuild(
        controller: _firstScrollController,
        childBuilder: (info) {
          return item(info);
        },
      ),
    );
  }
}
