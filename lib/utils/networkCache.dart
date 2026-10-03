import 'dart:convert';

import 'package:auro_wallet/store/settings/types/customNode.dart';

/// Identifies node-derived caches; account-specific callers also include the owner.
String getNetworkCacheKey(CustomNode? node) =>
    jsonEncode([node?.networkID ?? '', node?.url ?? '', node?.txUrl]);
