# CLAUDE.md

## Development Process

All feature work in this repository follows the Claude Code AI Vibe Coding SDLC: every feature moves through BA → Coder → Tester → App-Visualiser → Verifier → Deployer, with explicit user approval required between each phase. Before starting or resuming any feature work:

- Read `.claude/memory.md` for the current feature, branch, and phase.
- Read `.claude/agents/<phase>-agent.md` for the active phase's role, inputs, outputs, and rules.
- See `.claude/AI_SDLC_README.md` for the full end-to-end workflow (starting a feature, invoking each agent, closing phases, and merging to `main`).

Everything below this section is the project's architecture and coding-standards reference — it applies regardless of which phase is active.

## Project Overview

This project is a Flutter mobile application for St Luke's Catholic Parish Marsden Park.

The app targets Android and iOS only. There is no web support.

Phase 1 is frontend-only and does not include a backend. The app reads selected public information from https://stlukesmarsdenpark.org.au, including bulletin PDF links and metadata, plus other selected parish attributes such as Mass times and clergy/parish contact information.

Phase 2 may introduce Supabase for backend-supported capabilities such as notifications. Phase 1 code should remain ready for future backend integration, but must not overengineer backend patterns before they are needed.

The app must only consume public parish website content. Do not assume private APIs, admin endpoints, or unpublished data sources exist.

## Tech Stack

- Flutter stable
- Dart stable with sound null safety
- Mobile only: Android and iOS
- Riverpod-based state management
- `riverpod_generator` for provider generation
- `freezed` for immutable models and sealed states where appropriate
- `json_serializable` for serialization support where needed
- Standard Flutter CLI workflow only
- `dart format` and `flutter analyze` are the default formatting and linting tools

Use the latest stable package versions only. Do not add prerelease, experimental, or abandoned packages unless there is a documented reason.

Prefer widely used packages with strong maintenance, clear documentation, and stable release history.

## Architecture Summary

Use a feature-first, layered architecture.

Every feature should follow this separation:

- `presentation/` for UI, widgets, screens, and Riverpod providers/notifiers used by the UI
- `domain/` for core entities, contracts, and feature-specific business rules
- `data/` for repositories, scraper clients, parsers, DTOs, and external data access logic

Architecture rules:

- No business logic in widgets
- No scraping logic in UI code
- No direct network calls from screens or widgets
- Repositories are the only access point for external data retrieval
- Parsers transform raw scraped content into typed models
- Models must be immutable
- Keep feature concerns isolated; avoid dumping everything into shared folders
- Prefer small, composable widgets over large screen files

Use Riverpod as the primary dependency injection and state management mechanism.

## Commands

Use these commands unless the project explicitly changes.

### Setup

```bash
flutter pub get
```

### Run app

```bash
flutter run
```

### Analyze

```bash
flutter analyze
```

### Format

```bash
dart format .
```

### Run all tests

```bash
flutter test
```

### Run a specific test file

```bash
flutter test test/path_to_test_file.dart
```

### Run integration tests

```bash
flutter test integration_test
```

### Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch code generation during active development

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Build Android

```bash
flutter build apk
```

### Build iOS

```bash
flutter build ios
```

Do not invent custom scripts unless they are added intentionally to the project.

## Project Structure

Use this default structure unless there is a good reason to change it.

```text
lib/
  app/
  core/
  shared/
  features/
    <feature_name>/
      presentation/
      domain/
      data/
test/
integration_test/
```

### Directory purpose

- `lib/app/` — app bootstrap, `main.dart`, app configuration, routing, theme, top-level providers
- `lib/core/` — cross-cutting utilities, constants, failures, result types, networking primitives, logging, environment-safe helpers
- `lib/shared/` — reusable UI components and shared models that truly belong to multiple features
- `lib/features/` — all feature modules
- `test/` — unit tests, widget tests, parser tests, repository tests, golden tests
- `integration_test/` — end-to-end or live integration tests

Do not put feature-specific logic into `core/` or `shared/` just because it is convenient.

Keep generated files checked in or ignored according to the project’s chosen policy, but be consistent across the codebase.

## Feature Module Template

Each feature should follow a consistent structure.

```text
lib/features/<feature_name>/
  presentation/
    providers/
    screens/
    widgets/
    states/
  domain/
    entities/
    repositories/
    usecases/
  data/
    datasources/
    repositories/
    models/
    parsers/
    selectors/
```

Notes:

- `presentation/providers/` contains Riverpod providers, not raw data-fetching code
- `presentation/screens/` contains page-level widgets
- `presentation/widgets/` contains smaller reusable feature widgets
- `presentation/states/` contains UI state classes when needed
- `domain/entities/` contains pure feature models or business entities
- `domain/repositories/` contains abstract contracts
- `domain/usecases/` is optional; add it when business logic grows beyond simple repository reads
- `data/datasources/` contains scraper/data-fetch clients
- `data/repositories/` contains repository implementations
- `data/models/` contains DTOs and serialized data objects
- `data/parsers/` contains HTML parsing and transformation code
- `data/selectors/` contains selector configuration definitions

Keep the structure simple for small features, but do not break the layering rules.

## Scraping Strategy

The source website is:

- `https://stlukesmarsdenpark.org.au`

The app reads only selected public content from this website.

Scraping rules:

- Use CSS selectors as the default selector format
- Allow XPath only as an exception when CSS selectors cannot reliably express the target
- Do not mix random selector strategies within the same feature without reason
- Keep selector definitions in configuration or selector files, not scattered through repository or UI code
- Do not hardcode selectors inside widgets, screens, or provider definitions
- Keep raw HTML parsing isolated from presentation code
- Design extraction so that website structure changes can be localized to selector/parsing files

Bulletin handling rules:

- Extract bulletin PDF links from the public parish website
- Extract bulletin metadata needed by the app, such as title and date when available
- Support download/view workflows in the mobile app using extracted public links
- Validate extracted URLs before exposing them to the UI

General parish attribute rules:

- Extract only approved fields needed by the app
- Treat Mass times, priest/parish names, office details, and similar public details as scrapeable content only when they are intentionally mapped in configuration
- Do not scrape entire pages blindly if only a few attributes are needed

## Selector Configuration Rules

The project should use a selector mapping approach.

There are two concepts:

1. A selector-definition map that describes how to retrieve data
2. A resolved-data map or typed model that contains extracted values

Prefer typed configuration objects over deeply nested dynamic maps whenever possible.

Recommended selector config fields:

- `key` — stable internal name used by the app
- `selectorType` — usually `css`, optionally `xpath`
- `selector` — the selector string
- `attribute` — optional attribute to read, such as `href`
- `extract` — extraction mode such as `text`, `html`, or `attribute`
- `postProcess` — optional cleanup/transformation rule
- `required` — whether missing data should be treated as failure
- `fallbackValue` — optional fallback if extraction fails

Naming rules:

- Use lowercase snake_case for selector keys
- Use stable names that reflect app usage, not page styling
- Example good keys: `bulletin_pdf_url`, `bulletin_title`, `mass_times`, `parish_priest_name`
- Do not use CSS class names as app-level field keys

Parsing rules:

- Normalize whitespace
- Trim surrounding labels when needed
- Validate URL fields before use
- Parse dates into typed date values when practical
- Return safe, explicit failures when extraction breaks

## Coding Standards

### General

- Follow idiomatic Dart and Flutter style
- Use sound null safety everywhere
- Keep functions short and focused
- Prefer explicit types when they improve readability
- Use `final` by default; use `const` wherever possible
- Avoid large files and deeply nested widget trees
- Keep side effects contained and easy to trace

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables, methods, providers: `camelCase`
- Constants: `camelCase` for Dart constants unless a specific pattern is established
- Provider names should be descriptive and end in `Provider` when appropriate
- Widget names should reflect UI purpose, not implementation detail

### Widgets

- Widgets must remain presentation-focused
- No parsing, scraping, or repository access directly inside widgets
- Lift logic into providers, controllers, or repositories
- Prefer small reusable widgets with a clear single purpose
- Handle loading, empty, success, and error states explicitly

### Accessibility

Parishioners are the audience, and that audience skews older. Treat these as
requirements, not polish.

- Interactive targets must be at least 48x48 logical pixels. An `InkWell`
  wrapped directly around a `Text` is too small — give it padding or use a
  button widget that supplies its own target size
- Every icon-only or emoji-only affordance needs an accessible name: wrap
  decorative glyphs in `ExcludeSemantics`, and give meaningful ones a
  `Semantics(label: ...)` or an `Icon(semanticLabel: ...)`
- Do not hardcode font sizes below 12 logical pixels. Prefer named
  `TextTheme` styles over per-widget `fontSize` values so scaling stays
  consistent
- Layouts must reflow rather than overflow when the system text size is
  increased. Fixed-height rows and fixed-width label columns are the usual
  culprits
- Text must meet WCAG AA contrast (4.5:1 for body text). Low-opacity white on
  the navy gradient is the easiest way to fail this — measure rather than
  eyeball it

### Generated code

Provider code is generated by `riverpod_generator`, and the generated `.g.dart`
output is committed to the repository.

- After changing any annotated provider, re-run
  `dart run build_runner build --delete-conflicting-outputs` and commit the
  regenerated output in the same commit as the source change
- Never hand-edit a `.g.dart` file
- A pull request whose generated output does not match its source is incomplete
  — the two must always be committed together

### Error handling

- Do not swallow exceptions silently
- Convert parsing and network failures into explicit typed failures or domain-safe errors
- Show user-friendly UI states for recoverable problems
- Keep raw exception details out of end-user messaging

### Async handling

- Avoid unmanaged async work in widgets
- Prefer Riverpod-managed async state
- Cancel or scope long-running work appropriately
- Keep async dependencies testable

### Logging

- Log meaningful diagnostics during scraping and parsing flows
- Do not log secrets or sensitive data
- Keep logs structured and useful for debugging selector failures

### Dependencies

- Prefer mature, stable packages
- Do not add packages for trivial convenience
- Document non-obvious package choices in code comments or project docs when needed

## State Management Rules

Use Riverpod as the default state management approach.

Rules:

- Use generated providers with `riverpod_generator`
- Keep provider responsibilities narrow and focused
- UI should read providers, not assemble raw dependencies manually
- Separate UI state from scraped/domain data state
- Use `AsyncValue` properly for asynchronous content
- Always handle loading, data, and error branches
- Avoid global mutable state
- Avoid provider chains that are hard to trace unless clearly justified

State design guidance:

- Use simple providers for static or derived values
- Use async providers or notifier-based providers for loading external content
- Model complex state explicitly instead of using loose maps in UI code

## Data and Repository Rules

Repositories are the boundary between the app and external content.

Rules:

- Screens and widgets must not call scraper clients directly
- Repositories orchestrate fetching, parsing, validation, and mapping
- Parsers should return typed models, not raw DOM fragments
- Keep DTOs separate from domain entities when the source format is unstable or noisy
- If a feature is simple, domain and data models can start close together, but keep code organized so separation can grow later
- Do not expose raw website structure to presentation layer code

If caching is added later, it should happen behind repositories.

Do not add local persistence until there is a clear requirement.

## Testing Standards

Testing is required.

Every completed feature should include tests appropriate to its behavior.

### Required test types

- Unit tests for parsers, transformers, utility functions, and repository logic
- Widget tests for screens and reusable widgets
- Golden tests for stable, important UI states
- Integration tests for user flows and live data validation where appropriate

### Scraping test rules

- Live integration tests against `https://stlukesmarsdenpark.org.au` are allowed and expected for scraping verification
- Do not rely only on mocked HTML for scraper confidence
- Also use focused unit tests with controlled HTML fixtures for parser edge cases
- Keep live tests resilient; assert important outcomes rather than fragile full-page assumptions

### Coverage expectations

Test these states whenever relevant:

- Loading
- Success
- Empty result
- Parsing failure
- Network failure
- Missing selector result
- Invalid URL result

Widget tests that assert absence of layout overflow should cover increased
system text size as well as screen size. `test/app/app_test.dart` already
sweeps screen sizes via its `expectNoOverflowAt` helper; extend that pattern
with a text-scale axis (for example `TextScaler.linear(1.5)` and `2.0`) rather
than adding a parallel helper.

### Delivery rule

Build and test one feature/page at a time.

Do not mark a feature complete until its code, tests, and UI states are verified.

## Security and Reliability Rules

- Scrape public content only
- Do not access private, authenticated, or administrative pages
- Do not hardcode secrets, tokens, or credentials in source code
- Add request timeouts and safe failure handling
- Validate external URLs before opening or downloading them
- Treat website HTML as unstable external input
- Expect selectors to break over time; design so updates are easy
- Use defensive parsing rather than brittle string slicing
- Keep future Supabase integration possible, but do not add premature backend abstractions in Phase 1

If the website structure changes, the fix should primarily happen in selector and parser layers, not across UI files.

## Delivery Workflow

Claude should work incrementally.

Rules:

- Build one feature or one page at a time
- Confirm architecture before scaling code patterns across the app
- Keep changes scoped to the requested task
- Write tests alongside or immediately after feature implementation
- Verify loading, success, empty, and error states before moving on
- Run formatter and analyzer after significant code changes
- Do not move to the next feature while the current feature is broken
- Prefer small, reviewable changes over large speculative rewrites

## Anti-Patterns

Do not do the following:

- Put business logic in widgets
- Put scraping logic in presentation layer code
- Scatter selectors across unrelated files
- Expose raw HTML or DOM handling to UI code
- Use giant dynamic maps in place of typed models without reason
- Add unstable packages without justification
- Skip tests for completed work
- Overengineer backend abstractions in Phase 1
- Scrape more website content than the app actually needs
- Hide failures silently

## Future Phase Notes

Phase 2 may introduce Supabase for notification-related features.

When Phase 2 begins:

- Keep notification logic behind clean interfaces
- Avoid coupling current scraping flows tightly to future backend behavior
- Reevaluate caching, sync, and push notification architecture at that time

Until then, optimize for a high-quality, testable, frontend-only mobile app with clean structure and reliable public-content extraction.