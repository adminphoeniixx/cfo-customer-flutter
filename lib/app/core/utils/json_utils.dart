/// Small parsing helpers so models can be tolerant of the API returning a
/// number as a string (Laravel does this a lot for decimal columns) without
/// littering every model with the same ternary.
num? asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

double asDouble(dynamic v, [double fallback = 0]) => asNum(v)?.toDouble() ?? fallback;

int asInt(dynamic v, [int fallback = 0]) => asNum(v)?.toInt() ?? fallback;

bool asBool(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == 'true' || v == '1';
  return fallback;
}

String asString(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;
