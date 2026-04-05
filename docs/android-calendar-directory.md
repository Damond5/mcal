# MCAL Calendar Directory - Android Debug Guide

This document explains how to access and list files in the mcal calendar directory on Android devices using ADB (Android Debug Bridge).

## Calendar Directory Location

The mcal calendar directory is located at:

```
/data/data/com.mcal/files/app_flutter/calendar/
```

This is an app-private directory that stores calendar events as markdown files within a git repository.

## Commands

### List All Files in Calendar Directory

```bash
adb shell "run-as com.mcal ls -la ./app_flutter/calendar/"
```

### View a Specific Event File

```bash
adb shell "run-as com.mcal cat ./app_flutter/calendar/<filename.md>"
```

Example:
```bash
adb shell "run-as com.mcal cat ./app_flutter/calendar/zzz.md"
```

### View Git Commit History

```bash
adb shell "run-as com.mcal cat ./app_flutter/calendar/.git/logs/HEAD"
```

### Pull Calendar Directory to Local Machine

To copy the entire calendar directory to your local machine:

```bash
adb pull /data/data/com.mcal/files/app_flutter/calendar/ ./calendar_backup/
```

Note: This may require root access depending on your device and Android version.

## Notes

- The calendar uses `run-as com.mcal` to access app-private directories without root
- Events are stored as markdown (.md) files within a git repository
- This allows the app to sync events to a remote git repository
- The `files/calendar/` path (app documents directory) is also created by the app but may not contain the primary event storage if using git-based storage
