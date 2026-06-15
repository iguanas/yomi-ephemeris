/// The Yomi Ephemeris as a standalone HTTP service.
///
/// JSON in, JSON out. Every response carries `engine_version` (the same
/// `currentEngineVersion` the app stamps into stored charts) and
/// `node_model: "mean"` (the North Node is the mean node — a claim
/// constraint from the data-story kernel).
///
/// Endpoints (all POST bodies are JSON; all datetimes ISO-8601 **with an
/// explicit offset or Z** — naive local datetimes are rejected):
///   GET  /healthz            — liveness, no auth.
///   POST /v1/natal           — {datetime, location:{latitude, longitude, ...},
///                              exact_time_known?: bool}
///                              → full natal chart (positions, cusps).
///   POST /v1/transits        — {natal: `<chart json | natal input>`,
///                              datetime?: ISO} → active transits with house,
///                              aspect, orb, direction, peak + window timing.
///   POST /v1/transits/batch  — same natal, plus either {datetimes: [...]} or
///                              {start, end, step_hours} → per-datetime feeds.
///
/// `/v1` versions the request/response contract (same convention as the
/// existing proxy); `engine_version` in the body versions the astronomy.
///
/// Auth: `X-Api-Key` header checked against the EPHEMERIS_API_KEY env var.
/// The key is required at startup — this is internal infrastructure, never
/// an open endpoint.
library;

// shelf lives in dev_dependencies (deliberately — see pubspec.yaml); the
// server only ever runs with this package as the resolution root.
// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:yomi_ephemeris/yomi_ephemeris.dart';

final _service = AstronomyService();
final _transitFinder = TransitFinder();

/// Hard cap on batch size — internal service, not a bulk-compute farm.
const _maxBatch = 1000;

/// Smallest accepted batch step. Sub-minute steps round to zero-length
/// Durations and would loop in place.
const _minStep = Duration(minutes: 1);

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final apiKey = Platform.environment['EPHEMERIS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('EPHEMERIS_API_KEY is required. Refusing to start open.');
    exit(64);
  }

  final router = Router()
    ..get('/healthz', _healthz)
    ..post('/v1/natal', _natal)
    ..post('/v1/transits', _transits)
    ..post('/v1/transits/batch', _transitsBatch);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_requireApiKey(apiKey))
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln(
    'yomi_ephemeris engine v$currentEngineVersion listening on :${server.port}',
  );
}

// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------

Middleware _requireApiKey(String expected) {
  return (inner) {
    return (request) {
      if (request.url.path == 'healthz') return inner(request);
      final provided = request.headers['x-api-key'];
      if (provided == null || !_constantTimeEquals(provided, expected)) {
        return _json(401, {'error': 'missing or invalid X-Api-Key'});
      }
      return inner(request);
    };
  };
}

/// Compare without short-circuiting so timing doesn't leak prefix length.
bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

// ---------------------------------------------------------------------------
// Handlers
// ---------------------------------------------------------------------------

Response _healthz(Request request) =>
    _json(200, {'status': 'ok', ..._envelope()});

Future<Response> _natal(Request request) => _guard(request, (body) async {
      final chart = _chartFromInput(body);
      return _json(200, {..._envelope(), 'natal': chart.toJson()});
    });

Future<Response> _transits(Request request) => _guard(request, (body) async {
      final chart = _natalFromBody(body);
      final at = body['datetime'] == null
          ? DateTime.now().toUtc()
          : _parseUtc(body['datetime'], 'datetime');
      final transits = _transitFinder.findActiveTransits(chart, at);
      return _json(200, {
        ..._envelope(),
        'at': at.toIso8601String(),
        'natal_id': chart.id,
        'transits': [for (final t in transits) t.toJson()],
      });
    });

Future<Response> _transitsBatch(Request request) =>
    _guard(request, (body) async {
      final chart = _natalFromBody(body);
      final datetimes = _batchDatetimes(body);
      return _json(200, {
        ..._envelope(),
        'natal_id': chart.id,
        'results': [
          for (final at in datetimes)
            {
              'at': at.toIso8601String(),
              'transits': [
                for (final t in _transitFinder.findActiveTransits(chart, at))
                  t.toJson(),
              ],
            },
        ],
      });
    });

// ---------------------------------------------------------------------------
// Input parsing
// ---------------------------------------------------------------------------

class _BadRequest implements Exception {
  _BadRequest(this.message);
  final String message;
}

/// `natal` is either a previously returned chart (recognized by
/// `planetPositions`) or a `{datetime, location}` input to compute one.
BirthChart _natalFromBody(Map<String, dynamic> body) {
  final natal = body['natal'];
  if (natal is! Map<String, dynamic>) {
    throw _BadRequest(
      'natal is required: a chart from POST /v1/natal, or '
      '{datetime, location}',
    );
  }
  if (natal.containsKey('planetPositions')) {
    final BirthChart chart;
    try {
      chart = BirthChart.fromJson(natal);
    } catch (e) {
      throw _BadRequest('natal chart failed to parse: $e');
    }
    // fromJson is structurally lenient; the transit math is not. Charts
    // stored by older engine versions can lack newer bodies entirely.
    final missing = [
      for (final p in Planet.values)
        if (!chart.planetPositions.containsKey(p)) p.name,
    ];
    if (missing.isNotEmpty) {
      throw _BadRequest(
        'natal chart is missing planet positions for: ${missing.join(', ')}. '
        'Recompute it via POST /v1/natal (engine v$currentEngineVersion).',
      );
    }
    if (chart.houseCusps.length != 12) {
      throw _BadRequest(
        'natal chart must carry exactly 12 house cusps '
        '(got ${chart.houseCusps.length}).',
      );
    }
    return chart;
  }
  return _chartFromInput(natal);
}

BirthChart _chartFromInput(Map<String, dynamic> input) {
  final dt = _parseUtc(input['datetime'], 'datetime');
  final loc = input['location'];
  if (loc is! Map<String, dynamic>) {
    throw _BadRequest('location is required: {latitude, longitude}');
  }
  final lat = _parseDouble(loc['latitude'], 'location.latitude');
  final lon = _parseDouble(loc['longitude'], 'location.longitude');
  if (lat < -90 || lat > 90) {
    throw _BadRequest('location.latitude must be -90..90');
  }
  if (lon < -180 || lon > 180) {
    throw _BadRequest('location.longitude must be -180..180');
  }
  final etkRaw = input['exact_time_known'];
  final bool exactTimeKnown;
  if (etkRaw == null) {
    exactTimeKnown = false;
  } else if (etkRaw is bool) {
    exactTimeKnown = etkRaw;
  } else {
    throw _BadRequest('exact_time_known must be a boolean');
  }
  return _service.calculateBirthChart(
    dt,
    GeoLocation(
      latitude: lat,
      longitude: lon,
      cityName: _optionalString(
          loc['city'] ?? loc['cityName'], 'location.city', ''),
      countryCode: _optionalString(
          loc['country'] ?? loc['countryCode'], 'location.country', ''),
      timezone: _optionalString(loc['timezone'], 'location.timezone', 'UTC'),
    ),
    exactTimeKnown: exactTimeKnown,
  );
}

/// Optional JSON string field: absent/null → [fallback]; present but
/// non-string → 400 (never a 500 from a blind cast).
String _optionalString(Object? raw, String field, String fallback) {
  if (raw == null) return fallback;
  if (raw is String) return raw;
  throw _BadRequest('$field must be a string');
}

DateTime _parseUtc(Object? raw, String field) {
  if (raw is! String) throw _BadRequest('$field is required (ISO-8601 string)');
  final DateTime dt;
  try {
    dt = DateTime.parse(raw);
  } on FormatException {
    throw _BadRequest('$field is not valid ISO-8601: "$raw"');
  }
  // DateTime.parse marks offset-bearing strings (Z, +05, +05:30, ...) as
  // UTC and offset-less ones as local — on a server "local" is the
  // container's timezone, which is never what the caller meant.
  if (!dt.isUtc) {
    throw _BadRequest(
      '$field must carry an explicit offset or Z (got "$raw"). '
      'Convert local birth time to UTC before calling.',
    );
  }
  if (dt.isBefore(minSupportedUtc) || dt.isAfter(maxSupportedUtc)) {
    throw _BadRequest(
      '$field must be within ${minSupportedUtc.toIso8601String()}..'
      '${maxSupportedUtc.toIso8601String()} — the JPL table range the '
      'engine is validated for.',
    );
  }
  return dt;
}

double _parseDouble(Object? raw, String field) {
  if (raw is num) return raw.toDouble();
  throw _BadRequest('$field is required (number)');
}

List<DateTime> _batchDatetimes(Map<String, dynamic> body) {
  final list = body['datetimes'];
  if (list is List) {
    if (list.isEmpty) throw _BadRequest('datetimes is empty');
    if (list.length > _maxBatch) {
      throw _BadRequest('datetimes exceeds the $_maxBatch cap');
    }
    return [for (final raw in list) _parseUtc(raw, 'datetimes[]')];
  }
  final start = _parseUtc(body['start'], 'start');
  final end = _parseUtc(body['end'], 'end');
  if (!end.isAfter(start)) throw _BadRequest('end must be after start');
  final stepHours = body['step_hours'];
  if (stepHours is! num || stepHours <= 0) {
    throw _BadRequest('step_hours is required (positive number)');
  }
  // Steps are whole minutes; sub-minute values would round to a
  // zero-length step and loop in place.
  final step = Duration(minutes: (stepHours * 60).round());
  if (step < _minStep) {
    throw _BadRequest(
      'step_hours must be at least ${1 / 60} (1 minute); got $stepHours',
    );
  }
  final out = <DateTime>[];
  for (var t = start; !t.isAfter(end); t = t.add(step)) {
    if (out.length >= _maxBatch) {
      throw _BadRequest('range yields more than the $_maxBatch cap');
    }
    out.add(t);
  }
  return out;
}

// ---------------------------------------------------------------------------
// Response plumbing
// ---------------------------------------------------------------------------

Map<String, dynamic> _envelope() => {
      'engine_version': currentEngineVersion,
      'node_model': 'mean',
    };

Future<Response> _guard(
  Request request,
  Future<Response> Function(Map<String, dynamic> body) handler,
) async {
  final Map<String, dynamic> body;
  try {
    final raw = await request.readAsString();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return _json(400, {'error': 'body must be a JSON object'});
    }
    body = decoded;
  } on FormatException {
    return _json(400, {'error': 'body is not valid JSON'});
  }
  try {
    return await handler(body);
  } on _BadRequest catch (e) {
    return _json(400, {'error': e.message});
  } catch (e) {
    stderr.writeln('500 on ${request.url.path}: $e');
    return _json(500, {'error': 'internal error'});
  }
}

Response _json(int status, Map<String, dynamic> body) => Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
