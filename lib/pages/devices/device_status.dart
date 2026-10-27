import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// DEVICE STATUS
// A device is Online when its shelf has sent a sensor reading in the last
// few seconds. The server decides this (GET /device-status) from the same
// readings the live sensor page shows.
// ─────────────────────────────────────────────────────────────

enum DeviceState {
  online, //  a reading arrived recently
  offline, // readings exist, but the last one is old
  noData, //  this shelf has never sent a reading
  unknown, // the status could not be checked (yet)
}

class DeviceStatus {
  final DeviceState state;
  final DateTime? lastReadingAt;
  final double? secondsSinceLast;

  // Latest pH, EC, temperature and ORP values (may be null)
  final Map<String, dynamic>? latest;

  final int readingsLastHour;

  const DeviceStatus({
    required this.state,
    this.lastReadingAt,
    this.secondsSinceLast,
    this.latest,
    this.readingsLastHour = 0,
  });

  // Shown while the status is loading or could not be loaded
  static const DeviceStatus unknown = DeviceStatus(state: DeviceState.unknown);

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    final state = switch (json['state']) {
      'online' => DeviceState.online,
      'offline' => DeviceState.offline,
      'no_data' => DeviceState.noData,
      _ => DeviceState.unknown,
    };

    final seconds = json['seconds_since_last'];
    final latest = json['latest'];

    return DeviceStatus(
      state: state,
      lastReadingAt: DateTime.tryParse(
        json['last_reading_at']?.toString() ?? '',
      )?.toLocal(),
      secondsSinceLast: seconds is num ? seconds.toDouble() : null,
      latest: latest is Map ? Map<String, dynamic>.from(latest) : null,
      readingsLastHour: (json['readings_last_hour'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isOnline => state == DeviceState.online;

  String get label {
    switch (state) {
      case DeviceState.online:
        return 'Online';
      case DeviceState.offline:
        return 'Offline';
      case DeviceState.noData:
        return 'No data yet';
      case DeviceState.unknown:
        return 'Checking...';
    }
  }

  Color get color {
    switch (state) {
      case DeviceState.online:
        return const Color(0xFF2A9D6B);
      case DeviceState.offline:
        return const Color(0xFFE63946);
      case DeviceState.noData:
      case DeviceState.unknown:
        return const Color(0xFF888888);
    }
  }

  IconData get icon {
    switch (state) {
      case DeviceState.online:
        return Icons.wifi_rounded;
      case DeviceState.offline:
        return Icons.wifi_off_rounded;
      case DeviceState.noData:
        return Icons.hourglass_empty_rounded;
      case DeviceState.unknown:
        return Icons.sync_rounded;
    }
  }

  // One line that says what is going on
  String get description {
    switch (state) {
      case DeviceState.online:
        return 'Sending readings. Last one ${formatSecondsAgo(secondsSinceLast)}.';
      case DeviceState.offline:
        return 'No reading received. The last one was ${formatSecondsAgo(secondsSinceLast)}.';
      case DeviceState.noData:
        return 'This shelf has never sent a sensor reading.';
      case DeviceState.unknown:
        return 'Checking the connection...';
    }
  }

  // A short version for the device list
  String get shortDescription {
    switch (state) {
      case DeviceState.online:
        return 'Last reading ${formatSecondsAgo(secondsSinceLast)}';
      case DeviceState.offline:
        return 'Last reading ${formatSecondsAgo(secondsSinceLast)}';
      case DeviceState.noData:
        return 'No reading received yet';
      case DeviceState.unknown:
        return 'Checking the connection...';
    }
  }
}

// 4 -> "4 s ago", 130 -> "2 min ago", 7200 -> "2 h ago"
String formatSecondsAgo(double? seconds) {
  if (seconds == null) return 'a while ago';

  final s = seconds.round();

  if (s < 5) return 'just now';
  if (s < 60) return '$s s ago';
  if (s < 3600) return '${s ~/ 60} min ago';
  if (s < 86400) return '${s ~/ 3600} h ago';

  final days = s ~/ 86400;

  return days == 1 ? '1 day ago' : '$days days ago';
}

// The small Online / Offline pill
class DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const DeviceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
