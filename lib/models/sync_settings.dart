class SyncSettings {
  final bool autoSyncEnabled;
  final int syncFrequencyMinutes;
  final bool resumeSyncEnabled;

  const SyncSettings({
    this.autoSyncEnabled = true,
    this.syncFrequencyMinutes = 15,
    this.resumeSyncEnabled = true,
  });

  SyncSettings copyWith({
    bool? autoSyncEnabled,
    int? syncFrequencyMinutes,
    bool? resumeSyncEnabled,
  }) {
    return SyncSettings(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncFrequencyMinutes: syncFrequencyMinutes ?? this.syncFrequencyMinutes,
      resumeSyncEnabled: resumeSyncEnabled ?? this.resumeSyncEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSyncEnabled': autoSyncEnabled,
      'syncFrequencyMinutes': syncFrequencyMinutes,
      'resumeSyncEnabled': resumeSyncEnabled,
    };
  }

  factory SyncSettings.fromJson(Map<String, dynamic> json) {
    return SyncSettings(
      autoSyncEnabled: json['autoSyncEnabled'] ?? true,
      syncFrequencyMinutes: json['syncFrequencyMinutes'] ?? 15,
      resumeSyncEnabled: json['resumeSyncEnabled'] ?? true,
    );
  }
}
