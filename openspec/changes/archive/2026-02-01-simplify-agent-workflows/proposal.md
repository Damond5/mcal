## Why

The current agent workflow documentation has become overly complex and fragmented:

- **Documentation sprawl**: 10 files in `docs/platforms/` with 4 being incomplete skeletons (only 21 lines each)
- **Indirection layer**: AGENTS.md points agents to `docs/platforms/<platform>-workflow.md` instead of directly to commands
- **Linux neglect**: Linux is the "primary platform for automated testing" but has no Makefile targets
- **Content duplication**: `android-workflow.md` contains 68 lines of exact duplication (lines 68-106)
- **Broken promise**: iOS, macOS, Web, Windows workflows marked "Coming soon" for unknown duration

This fragmentation makes it difficult for AI agents and humans to quickly find essential build, test, and run commands.

## What Changes

1. **Delete `docs/` folder entirely** - All content is redundant or can be captured elsewhere
2. **Migrate essential content to Makefile comments** - Build commands, troubleshooting, and platform-specific notes
3. **Simplify `AGENTS.md`** - Point directly to Makefile targets instead of workflow files
4. **Add missing Linux targets to Makefile** - Create `linux-build`, `linux-test`, `linux-libs` targets to match Android
5. **Keep only essential documentation** - README.md and CHANGELOG.md remain in project root

## Capabilities

### New Capabilities
- AI agents can find all build/test/run commands in one place (AGENTS.md which contains make commands)
- Linux platform has equivalent build tooling to Android
- Documentation maintenance burden reduced

### Modified Capabilities
- Agent workflow documentation: from multi-file navigation to single Makefile reference
- Build process: Linux now has Makefile targets for consistent workflow

## Impact

- **Positive**: Simpler documentation, faster agent onboarding, consistent Linux/Android workflows
- **Risk**: Anyone with bookmarks to `docs/platforms/*` will need to update them
- **Zero impact**: Application functionality, event storage, Git sync, or notification system
