part of 'delay_widget.dart';

class DelayBuildWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final DelayManager delayManager;
  const DelayBuildWidget({Key key, this.delayManager, this.builder}) : super(key: key);
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
      _initBuild = true;
      delayManager._add(
        _BuildAction(
          callback: () {
            if (mounted) {
              setState(() {});
            }
            return true;
          },
        ),
      );
      return SizedBox.shrink();
    }
    return widget.builder?.call(context);
  }
}
