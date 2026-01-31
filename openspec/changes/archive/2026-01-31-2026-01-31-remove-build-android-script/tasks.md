## 1. Delete Deprecated Script
- [x] 1.1 Delete scripts/build-android.sh file
- [x] 1.2 Verify file is deleted by checking file no longer exists

## 2. Update android-workflow.md
- [x] 2.1 Read docs/platforms/android-workflow.md to identify script documentation section
- [x] 2.2 Remove the shell script example/documentation section (lines containing script content)
- [x] 2.3 Add note directing users to use `make android-build` instead
- [x] 2.4 Verify the Complete Development Cycle section points to Makefile

## 3. Update build-deployment Spec
- [x] 3.1 Read openspec/specs/build-deployment/spec.md to locate script deprecation requirement
- [x] 3.2 Remove requirement about "The application SHALL use Makefile as primary build automation"
- [x] 3.3 Verify other Makefile-related requirements remain (if any)

## 4. Validation
- [x] 4.1 Verify scripts/build-android.sh no longer exists
- [x] 4.2 Search for any remaining references to build-android.sh in documentation
- [x] 4.3 Verify android-workflow.md no longer shows script content
- [x] 4.4 Verify build-deployment spec no longer references script deprecation
- [x] 4.5 Test `make android-build` still works correctly
