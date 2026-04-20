# AGENTS

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>core-data-expert</name>
<description>'Expert Core Data guidance (iOS/macOS): stack setup, fetch requests & NSFetchedResultsController, saving/merge conflicts, threading & Swift Concurrency, batch operations & persistent history, migrations, performance, and NSPersistentCloudKitContainer/CloudKit sync.'</description>
<location>project</location>
</skill>

<skill>
<name>ios-clean-architecture</name>
<description>Modular Clean Architecture template for iOS apps built with SwiftUI and Swift Package Manager on Swift 6.2 with default main-actor isolation. Use when scaffolding a new iOS feature, organizing a SwiftUI app into layered SPM packages (NetworkService, Endpoints, Repositories, UseCases, DIContainer, feature views), applying protocol-first cross-module dependencies, wiring up Builder-based feature instantiation, or migrating ObservableObject code to @Observable with Swift 6 concurrency and Swift Testing.</description>
<location>project</location>
</skill>

<skill>
<name>spm-build-analysis</name>
<description>Analyze Swift Package Manager dependencies, package plugins, module variants, and CI-oriented build overhead that slow Xcode builds. Use when a developer suspects packages, plugins, or dependency graph shape are hurting clean or incremental build performance, mentions SPM slowness, package resolution time, build plugin overhead, duplicate module builds from configuration drift, circular dependencies between modules, oversized modules needing splitting, or modularization best practices.</description>
<location>project</location>
</skill>

<skill>
<name>swift-concurrency</name>
<description>'Diagnose data races, convert callback-based code to async/await, implement actor isolation patterns, resolve Sendable conformance issues, and guide Swift 6 migration. Use when developers mention: (1) Swift Concurrency, async/await, actors, or tasks, (2) "use Swift Concurrency" or "modern concurrency patterns", (3) migrating to Swift 6, (4) data races or thread safety issues, (5) refactoring closures to async/await, (6) @MainActor, Sendable, or actor isolation, (7) concurrent code architecture or performance optimization, (8) concurrency-related linter warnings (SwiftLint or similar; e.g. async_without_await, Sendable/actor isolation/MainActor lint).'</description>
<location>project</location>
</skill>

<skill>
<name>swift-testing-expert</name>
<description>'Expert guidance for Swift Testing: test structure, #expect/#require macros, traits and tags, parameterized tests, test plans, parallel execution, async waiting patterns, and XCTest migration. Use when writing new Swift tests, modernizing XCTest suites, debugging flaky tests, or improving test quality and maintainability in Apple-platform or Swift server projects.'</description>
<location>project</location>
</skill>

<skill>
<name>swiftui-expert-skill</name>
<description>Write, review, or improve SwiftUI code following best practices for state management, view composition, performance, and iOS 26+ Liquid Glass adoption. Use when building new SwiftUI features, refactoring existing views, reviewing code quality, or adopting modern SwiftUI patterns.</description>
<location>project</location>
</skill>

<skill>
<name>xcode-build-benchmark</name>
<description>Benchmark Xcode clean and incremental builds with repeatable inputs, timing summaries, and timestamped `.build-benchmark/` artifacts. Use when a developer wants a baseline, wants to compare before and after changes, asks to measure build performance, mentions build times, build duration, how long builds take, or wants to know if builds got faster or slower.</description>
<location>project</location>
</skill>

<skill>
<name>xcode-build-fixer</name>
<description>Apply approved Xcode build optimization changes following best practices, then re-benchmark to verify improvement. Use when a developer has an approved optimization plan from xcode-build-orchestrator, wants to apply specific build fixes, needs help implementing build setting changes, script phase guards, source-level compilation fixes, or SPM restructuring that was recommended by an analysis skill.</description>
<location>project</location>
</skill>

<skill>
<name>xcode-build-orchestrator</name>
<description>Orchestrate Xcode build optimization by benchmarking first, running the specialist analysis skills, prioritizing findings, requesting explicit approval, delegating approved fixes to xcode-build-fixer, and re-benchmarking after changes. Use when a developer wants an end-to-end build optimization workflow, asks to speed up Xcode builds, wants a full build audit, or needs a recommend-first optimization pass covering compilation, project settings, and packages.</description>
<location>project</location>
</skill>

<skill>
<name>xcode-compilation-analyzer</name>
<description>Analyze Swift and mixed-language compile hotspots using build timing summaries and Swift frontend diagnostics, then produce a recommend-first source-level optimization plan. Use when a developer reports slow compilation, type-checking warnings, expensive clean-build compile phases, long CompileSwiftSources tasks, warn-long-function-bodies output, or wants to speed up Swift type checking.</description>
<location>project</location>
</skill>

<skill>
<name>xcode-project-analyzer</name>
<description>Audit Xcode project configuration, build settings, scheme behavior, and script phases to find build-time improvements with explicit approval gates. Use when a developer wants project-level build analysis, slow incremental builds, guidance on target dependencies, build settings review, run script phase analysis, parallelization improvements, or module-map and DEFINES_MODULE configuration.</description>
<location>project</location>
</skill>

<skill>
<name>xcodebuildmcp</name>
<description>Official skill for XcodeBuildMCP (preferred). Use when doing iOS/macOS/watchOS/tvOS/visionOS work (build, test, run, debug, log, UI automation).</description>
<location>project</location>
</skill>

<skill>
<name>find-skills</name>
<description>Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.</description>
<location>global</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
