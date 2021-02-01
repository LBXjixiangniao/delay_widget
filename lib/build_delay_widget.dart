part of 'delay_widget.dart';

class DelayBuildWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final DelayManager delayManager;
  final Widget placeholder;
  //是否可滚动的
  final bool isScrollalbeItem;
  const DelayBuildWidget({
    Key key,
    this.delayManager,
    this.builder,
    this.placeholder,
    this.isScrollalbeItem = false,
  }) : super(key: key);
  static DelayBuildWidget defaultManager({Key key, WidgetBuilder builder}) {
    return DelayBuildWidget(
      key: key,
      builder: builder,
      delayManager: defaultDelayManager,
    );
  }

  @override
  _DelayBuildWidgetState createState() => _DelayBuildWidgetState();
}

class _DelayBuildWidgetState extends State<DelayBuildWidget> {
  bool _initBuild = false;
  DelayManager delayManager;
  bool isScheduling = false;

  @override
  void initState() {
    delayManager = widget.delayManager ?? defaultDelayManager;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DelayBuildWidget oldWidget) {
    delayManager = widget.delayManager ?? defaultDelayManager;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_initBuild == false) {
      scheduleSetState();
      return widget.placeholder ?? SizedBox.shrink();
    }
    return widget.builder?.call(context);
  }

  void scheduleSetState() {
    if (!mounted) {
      isScheduling = false;
      return;
    }
    if (isScheduling) return;
    isScheduling = true;
    if (widget.isScrollalbeItem && Scrollable.recommendDeferredLoadingForContext(context)) {
      //滚动太快了，下一帧再判断是否setState
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() {
          isScheduling = false;
          scheduleSetState();
        });
      });
      return;
    }
    delayManager._add(
      _BuildAction(
        callback: () {
          _initBuild = true;
          if (mounted) {
            setState(() {});
          }
          return true;
        },
      ),
    );
  }
}
