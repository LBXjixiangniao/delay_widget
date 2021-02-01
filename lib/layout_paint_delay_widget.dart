part of 'delay_widget.dart';

class DelayLayoutAndPaintWidget extends SingleChildRenderObjectWidget {
  //用于控制DelayBuildChild的layout和paint
  final DelayManager delayManager;
  //必须设置宽高，因为layout延迟了，为了不影响其他小部件layout，所以要设置固定的宽高
  final double width;
  final double height;
  //DelayBuildChild对应的RenderObject是否是repaintBoundary
  final bool addRepaintBoundary;
  //是否可滚动的
  final bool isScrollalbeItem;
  DelayLayoutAndPaintWidget({
    Key key,
    Widget child,
    this.delayManager,
    @required this.width,
    @required this.height,
    this.addRepaintBoundary = true,
    this.isScrollalbeItem = false,
  })  : assert(width != null && height != null),
        super(
          key: key,
          child: _LayoutAndPaintDelayMarker(
            child: child,
          ),
        );
  static DelayLayoutAndPaintWidget defaultManager({
    Key key,
    Widget child,
    double width,
    double height,
    int index,
    bool addRepaintBoundary = true,
  }) {
    return DelayLayoutAndPaintWidget(
      key: key,
      delayManager: defaultDelayManager,
      child: child,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
    );
  }

  @override
  _LayoutAndPaintDelayElement createElement() {
    return _LayoutAndPaintDelayElement(this);
  }

  @override
  _LayoutAndPaintDelayRenderObject createRenderObject(BuildContext context) {
    _LayoutAndPaintDelayRenderObject renderObject = _LayoutAndPaintDelayRenderObject(
      delayManager: delayManager,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
      context: context,
      isScrollalbeItem: isScrollalbeItem,
    );
    if (delayManager == null) {
      //往上寻找_BuildDelayMarkerElement并获取DelayManager
      _LayoutAndPaintDelayMarkerElement marker = _LayoutAndPaintDelayMarker.of(context);
      assert(marker?._delayManager != null, '如果widget的delayManager为null，则marker._delayManager不能为空');
      renderObject.delayManager = marker?._delayManager;
      renderObject._dependencyBuildInfo = marker?._info;
    }
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _LayoutAndPaintDelayRenderObject renderObject) {
    //buildManager在element中更新
    // renderObject.buildManager = buildManager;
    renderObject.isScrollalbeItem = isScrollalbeItem;
    renderObject.width = width;
    renderObject.height = height;
    renderObject.addRepaintBoundary = addRepaintBoundary;
  }

  @override
  void didUnmountRenderObject(covariant _LayoutAndPaintDelayRenderObject renderObject) {
    renderObject.info.tryUnlink();
    super.didUnmountRenderObject(renderObject);
  }
}

class _LayoutAndPaintDelayElement extends SingleChildRenderObjectElement {
  _LayoutAndPaintDelayMarkerElement _marker;
  _LayoutAndPaintDelayElement(SingleChildRenderObjectWidget widget) : super(widget);
  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _LayoutAndPaintDelayMarker.of(this, listen: true);
  }

  @override
  _LayoutAndPaintDelayRenderObject get renderObject => super.renderObject;

  @override
  DelayLayoutAndPaintWidget get widget => super.widget;

  @override
  void update(covariant DelayLayoutAndPaintWidget newWidget) {
    if (newWidget.delayManager != null) {
      renderObject.delayManager = newWidget.delayManager;
      _marker?.buildManager = newWidget.delayManager;
    } else {
      resetDependentRenderObjectValue();
    }
    super.update(newWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //依赖的_BuildDelayMarker的buildManager改变的时候才会执行该处代码
    if (widget.delayManager == null) {
      //如buildManager为null，则该DelayBuildChild的layout和paint依赖于树上层的其他DelayBuildChild
      resetDependentRenderObjectValue();
    }
  }

  void resetDependentRenderObjectValue() {
    _LayoutAndPaintDelayMarkerElement marker = _LayoutAndPaintDelayMarker.of(this);
    assert(marker != null, '如果widget的buildManager为null，则marker不能为空');
    renderObject.delayManager = marker?._delayManager;

    renderObject._dependencyBuildInfo = marker?._info;
    _marker?.buildManager = marker?._delayManager;
  }
}

///用来传递DelayBuildChild的buildManager和其renderObject的BuildInfo到子树
class _LayoutAndPaintDelayMarker extends InheritedWidget {
  _LayoutAndPaintDelayMarker({
    Key key,
    Widget child,
  }) : super(key: key, child: child);
  @override
  @override
  _LayoutAndPaintDelayMarkerElement createElement() {
    return _LayoutAndPaintDelayMarkerElement(this);
  }

  static _LayoutAndPaintDelayMarkerElement of(BuildContext context, {bool listen}) {
    InheritedElement element = context.getElementForInheritedWidgetOfExactType<_LayoutAndPaintDelayMarker>();
    if (listen == true && element != null) {
      context.dependOnInheritedElement(element);
    }
    return element as _LayoutAndPaintDelayMarkerElement;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

//用来传递_BuildDelayRenderObject的info和buildManager到子树
class _LayoutAndPaintDelayMarkerElement extends InheritedElement {
  _LayoutAndPaintAction _info;
  DelayManager _delayManager;
  _LayoutAndPaintDelayMarkerElement(InheritedWidget widget) : super(widget);

  //同步_BuildDelayRenderObject的buildManager的更改
  set buildManager(DelayManager manager) {
    DelayManager oldManager = _delayManager;
    _delayManager = manager;
    if (oldManager != _delayManager) {
      notifyClients(widget);
    }
  }

  @override
  void mount(Element parent, newSlot) {
    //在super.mount(parent, newSlot)前设置DelayBuildManager和BuildInfo，以确保在子RenderObject创建的时候能回去到这两个值
    //_BuildDelayMarkerElement创建的时候parent.renderObject已经创建了
    if (parent is _LayoutAndPaintDelayElement) {
      _LayoutAndPaintDelayRenderObject parentRenderObject = parent.renderObject;
      _info = parentRenderObject.info;
      _delayManager = parentRenderObject.delayManager;
      parent._marker = this;
    }

    super.mount(parent, newSlot);
  }
}

class _LayoutAndPaintDelayRenderObject extends RenderProxyBox {
  //info依赖于_dependencyBuildInfo
  _LayoutAndPaintAction _dependencyBuildInfo;

  _LayoutAndPaintAction info;
  DelayManager delayManager;
  double width;
  double height;
  bool addRepaintBoundary;
  //标识是否已经paint过了，因为如果还没paint过，则_needsPaint为true，这时候调用markNeedsPaint会被忽略
  bool _hadPainted = false;
  //是否显示出来了，则真正paint出来了
  bool isVisible = false;
  //是否可滚动的
  bool isScrollalbeItem;

  BuildContext context;
  _LayoutAndPaintDelayRenderObject({
    @required this.context,
    this.delayManager,
    this.width,
    this.height,
    this.addRepaintBoundary,
    this.isScrollalbeItem,
  }) : assert(width != null && height != null) {
    info = _LayoutAndPaintAction(markNeedsLayout: () {
      if (this.attached) {
        super.markNeedsLayout();
        return true;
      }
      return false;
    }, markNeedsPaint: () {
      if (this.attached && _hadPainted) {
        super.markNeedsPaint();
        return true;
      }
      return false;
    });
  }

  @override
  bool get isRepaintBoundary => addRepaintBoundary;

  @override
  Size get size => Size(width, height);

  @override
  void detach() {
    info.tryUnlink();
    super.detach();
  }

  @override
  void markNeedsLayout() {
    if (!this.attached) return;
    if (isScrollalbeItem) {
      if (Scrollable.recommendDeferredLoadingForContext(context)) {
        //滚动太快了，下一帧再判断是否markNeedsLayout
        SchedulerBinding.instance.scheduleFrameCallback((_) {
          scheduleMicrotask(() => markNeedsLayout());
        });
        return;
      }
    }
    if (info.currentStatus != _LayoutAndPaintStatus.layout) {
      info.nextStatus = _LayoutAndPaintStatus.layout;
      addBuildInfoToManager();
    }
  }

  @override
  void performLayout() {
    if (info.currentStatus == _LayoutAndPaintStatus.layout) {
      super.performLayout();
    } else {
      performResize();
    }
  }

  // @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(BoxConstraints.tight(Size(width, height)), parentUsesSize: false);
  }

  @override
  void markNeedsPaint() {
    if (!this.attached) return;
    if (isScrollalbeItem) {
      if (Scrollable.recommendDeferredLoadingForContext(context)) {
        //滚动太快了，下一帧再判断是否markNeedsPaint
        SchedulerBinding.instance.scheduleFrameCallback((_) {
          scheduleMicrotask(() => markNeedsPaint());
        });
        return;
      }
    }
    if (info.currentStatus == _LayoutAndPaintStatus.idle && info.nextStatus == _LayoutAndPaintStatus.idle) {
      info.nextStatus = _LayoutAndPaintStatus.paint;
      addBuildInfoToManager();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if (isVisible) {
      return super.hitTest(result, position: position);
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _hadPainted = true;
    if (info.list == null || info.currentStatus == _LayoutAndPaintStatus.paint) {
      isVisible = true;
      super.paint(context, offset);
    } else {
      isVisible = false;
    }
  }

  void addBuildInfoToManager() {
    if (info.list == null && delayManager != null) {
      if (_dependencyBuildInfo != null && _dependencyBuildInfo.list != null) {
        if (delayManager.reverse) {
          _dependencyBuildInfo.insertBefore(info);
        } else {
          _dependencyBuildInfo.insertAfter(info);
        }
      } else {
        delayManager._add(info);
      }
    }
  }
}
