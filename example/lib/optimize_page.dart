import 'package:delay_widget/delay_widget.dart';
import 'package:flutter/material.dart';

import 'common_page.dart';

class OptimizePage extends CommonPage {
  @override
  _OptimizePageState createState() => _OptimizePageState();
}

class _OptimizePageState extends CommonPageState {
  @override
  String get pageTitle => '优化后的页面';
  DelayManager manager;
  DelayManager managerTwo;
  DelayManager managerThree;
  @override
  void initState() {
    super.initState();
    manager = DelayManager(reverse: true);
    managerTwo = DelayManager(reverse: true);
    managerThree = DelayManager(reverse: true);
    managerTwo.dependentOn(manager);
    managerThree.dependentOn(managerTwo);
  }

  @override
  Widget detailWidget(GridInfo info, double width, double height) {
    return DelayLayoutAndPaintWidget(
      height: height,
      width: width,
      delayManager: managerTwo,
      addRepaintBoundary: false,
      isScrollalbeItem: true,
      child: super.detailWidget(info, width, height),
    );
  }

  @override
  Widget networkImage(GridInfo info, double width, double height) {
    return DelayLayoutAndPaintWidget(
      height: height,
      width: width,
      delayManager: managerThree,
      child: super.networkImage(info, width, height),
    );
  }

  @override
  Widget item(GridInfo info) {
    return DelayBuildWidget(
      delayManager: manager,
      isScrollalbeItem: false,
      placeholder: Container(color: Colors.red,),
      builder: (_) => super.item(info),
    );
  }
}
