# TODO

- severely simplify the Makefile
  - should ónly have the bare minimum
    - make clean (general, cleans everything)
    - make build (general, builds everything from scratch for the current platform)
      - be sure it does frb generation, builds native rust libs and those libs are usable by the flutter app, builds the flutter app and any other step needed for a fully functional app
    - make run (general, runs app on current platform, basically just fvm flutter run)
    - make linux-build (build specifically for linux)
    - make android-build (build specifically for android)
    - make android-run (runs on connected android device)
    - make android-install (install on connected android device)
  - be sure to update any files with documentation on make commands, like AGENTS.md, README.md and more
- integration tests?
