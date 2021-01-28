part of 'delay_widget.dart';

final DelayManager defaultDelayManager = DelayManager(reverse: true);

enum _LayoutAndPaintStatus {
  idle,
  layout,
  paint,
}

class DelayManager {
  final LinkedList<_DelayAction> _list = LinkedList<_DelayAction>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  //是否后加入的事件先执行
  final bool reverse;

  //依赖于this的
  DelayManager _dependent;
  //this依赖于的
  DelayManager _dependentcy;

  DelayManager({this.reverse = false});

  //this依赖于dependentcy
  void dependentOn(DelayManager dependentcy) {
    if (dependentcy != null) {
      dependentcy._dependent = this;
      this._dependentcy = dependentcy;
    }
  }

  //删除依赖，this不再依赖其他DelayBuildManager
  void removeDependent() {
    _dependentcy?._dependent = null;
    this._dependentcy = null;
  }

  void _stop() {
    _isRunning = false;
    _dependent?._stop();
  }

  void _start() {
    if (!_isRunning) {
      _dependent?._stop();
      if (!canStart()) return;
      _isRunning = true;
      //用future，因为此时可能没有帧刷新了，所以此处不能用ServicesBinding.instance.addPostFrameCallback
      Future.delayed(
          Duration(
            milliseconds: 16,
          ), () {
        _actionNext();
      });
    }
  }

  //如果往上遍历_dependentcy有任务待执行，则该manager不能start
  bool canStart() {
    if (_dependentcy == null) return true;
    bool b = true;
    DelayManager parentManager = _dependentcy;
    while (parentManager != null) {
      if (parentManager?._list?.isNotEmpty == true) {
        b = false;
        break;
      }
      parentManager = parentManager._dependentcy;
    }
    return b;
  }

  void _add(_DelayAction info) {
    _list.add(info);
    _start();
  }

  void _actionNext() {
    if (!_isRunning) return;
    if (_list.isNotEmpty) {
      _DelayAction info = reverse == true ? _list.last : _list.first;
      if (info is _LayoutAndPaintAction) {
        if (info.nextStatus == _LayoutAndPaintStatus.idle || info.nextStatus == null) {
          info.currentStatus = _LayoutAndPaintStatus.idle;
          info.tryUnlink();
          _actionNext();
        } else {
          bool waitNextFrame = false;
          if (info.nextStatus == _LayoutAndPaintStatus.layout) {
            info.currentStatus = _LayoutAndPaintStatus.layout;
            info.nextStatus = _LayoutAndPaintStatus.paint;
            waitNextFrame = info.markNeedsLayout();
          } else if (info.nextStatus == _LayoutAndPaintStatus.paint) {
            info.currentStatus = _LayoutAndPaintStatus.paint;
            info.nextStatus = _LayoutAndPaintStatus.idle;
            waitNextFrame = info.markNeedsPaint();
          }
          if (waitNextFrame) {
            ServicesBinding.instance.addPostFrameCallback((_) {
              _actionNext();
            });
          } else {
            _actionNext();
          }
        }
      } else if (info is _BuildAction) {
        bool b = info.callback?.call();
        info.tryUnlink();
        if (b == true) {
          ServicesBinding.instance.addPostFrameCallback((_) {
            _actionNext();
          });
        } else {
          _actionNext();
        }
      } else {
        _actionNext();
      }
    } else {
      _isRunning = false;
      _dependent?._start();
    }
  }
}

typedef _FrameCallback = dynamic Function();

class _DelayAction extends LinkedListEntry<_DelayAction> {
  void tryUnlink() {
    if (list != null) unlink();
  }
}

class _BuildAction extends _DelayAction {
  final _FrameCallback callback;

  _BuildAction({
    @required this.callback,
  });
}

class _LayoutAndPaintAction extends _DelayAction {
  _LayoutAndPaintStatus nextStatus;
  _LayoutAndPaintStatus currentStatus;
  final _FrameCallback markNeedsLayout;
  final _FrameCallback markNeedsPaint;

  _LayoutAndPaintAction({
    @required this.markNeedsLayout,
    @required this.markNeedsPaint,
    this.currentStatus = _LayoutAndPaintStatus.idle,
    this.nextStatus = _LayoutAndPaintStatus.idle,
  }) : assert(markNeedsLayout != null, markNeedsPaint != null);
}
