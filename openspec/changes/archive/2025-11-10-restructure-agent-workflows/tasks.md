## 1. Create docs/platforms directory
- [x] Create `docs/` directory in the project root if it doesn't exist
- [x] Create `docs/platforms/` subdirectory

## 2. Define standard template for workflow files
- [x] Create a standard template with sections: Building the App, Testing, Running on Device, Troubleshooting
- [x] Include a note in placeholders: "Platform-specific instructions to be added"

## 3. Extract Android workflow
- [x] Move Android Development Workflow section from AGENTS.md to `docs/platforms/android-workflow.md`
- [x] Search codebase for references to "Android Development Workflow" and update if needed

## 4. Create placeholder workflow files for other platforms
- [x] Create `docs/platforms/ios-workflow.md` using the standard template
- [x] Create `docs/platforms/linux-workflow.md` using the standard template
- [x] Create `docs/platforms/macos-workflow.md` using the standard template
- [x] Create `docs/platforms/web-workflow.md` using the standard template
- [x] Create `docs/platforms/windows-workflow.md` using the standard template

## 5. Update AGENTS.md
- [x] Remove the Android Development Workflow section
- [x] Add a new "Platform Development Workflows" section explaining the structure
- [x] Add relative path references to each platform's workflow file (e.g., `docs/platforms/android-workflow.md`)
- [x] Ensure the OpenSpec instructions block remains intact

## 6. Update README.md
- [x] Use docs-writer subagent to update the Project Structure section in README.md to include the new `docs/platforms/` directory

## 7. Validate changes
- [x] Run `openspec validate restructure-agent-workflows --strict` to ensure proposal is valid
- [x] Check that all new files are properly created, formatted, and references work