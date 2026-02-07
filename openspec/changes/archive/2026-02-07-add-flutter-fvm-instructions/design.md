## Context

Adding Flutter Version Management (fvm) instructions to AGENTS.md for the MCAL project. This is a documentation enhancement to ensure all developers use fvm for Flutter version consistency.

## Goals / Non-Goals

**Goals:**
1. Provide comprehensive fvm-based Flutter development commands
2. Integrate seamlessly with existing Makefile commands
3. Cover all common development tasks (run, build, test, analyze, format)
4. Support all target platforms (Android, iOS, Linux, Web)
5. Maintain clarity and readability in documentation

**Non-Goals:**
1. Modify existing Makefile infrastructure (only document integration)
2. Change the underlying build processes
3. Add new features to the application
4. Modify Rust or Flutter application code

## Decisions

### 1. Section Structure and Organization

Create a dedicated "Flutter Development (fvm)" section at the beginning of AGENTS.md, before the existing Makefile sections. This ensures fvm setup is understood before using Make commands.

**Alternatives considered:**
- Inline fvm notes within existing sections: Rejected because it would fragment the fvm documentation and make it harder for developers to understand the full fvm workflow.

### 2. Command Format and Examples

Use consistent fvm command format: `fvm flutter <command>` for all Flutter operations. Include both direct fvm commands and Make equivalents for each task.

**Alternatives considered:**
- Document only Make commands: Rejected because developers need to understand the underlying fvm commands for debugging and advanced usage.

### 3. Platform-Specific Coverage

Organize commands by platform (Linux, Android, iOS, Web) while emphasizing that fvm provides cross-platform consistency. Document platform-specific variations where needed.

**Alternatives considered:**
- Generic commands only: Rejected because platform-specific nuances are important for correct device targeting and build configurations.

### 4. Integration with Makefile

Show how existing Make targets relate to fvm commands, using callouts or notes to indicate that Make commands automatically use the correct Flutter version through fvm integration.

**Alternatives considered:**
- Separate fvm documentation: Rejected because tight integration with Makefile documentation helps developers understand the relationship between both approaches.

## Risks / Trade-offs

- **Risk**: Developers may ignore fvm and use flutter directly
  - *Mitigation*: Clearly document why fvm is required and the benefits

- **Trade-off**: Additional documentation maintenance overhead
  - *Benefit*: Improved consistency and reduced version-related issues
