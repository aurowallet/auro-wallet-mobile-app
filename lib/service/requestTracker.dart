import 'package:mobx/mobx.dart';

/// Invalidates reads on context changes, including A -> B -> A transitions.
class RequestTracker {
  RequestTracker(this.contextKey) {
    _context = contextKey();
    _dispose = reaction<String>((_) => contextKey(), _updateContext);
  }

  final String Function() contextKey;
  final Map<String, ({Object token, bool fromCache})> _latest = {};
  late final ReactionDisposer _dispose;
  late String _context;
  int _revision = 0;

  bool Function() start(String resource, {bool fromCache = false}) {
    final key = contextKey();
    _updateContext(key);
    // Cache reads must never supersede an already started network refresh.
    final previous = _latest[resource];
    if (fromCache && previous != null && !previous.fromCache) {
      return () => false;
    }
    final revision = _revision;
    final token = Object();
    _latest[resource] = (token: token, fromCache: fromCache);
    return () =>
        revision == _revision &&
        key == contextKey() &&
        identical(_latest[resource]?.token, token);
  }

  void _updateContext(String key) {
    // A page can start its new request before the context reaction runs.
    if (_context == key) return;
    _context = key;
    invalidate();
  }

  void invalidate() {
    _revision++;
    _latest.clear();
  }

  void dispose() {
    invalidate();
    _dispose();
  }
}
