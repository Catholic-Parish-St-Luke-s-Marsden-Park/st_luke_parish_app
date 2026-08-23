# Skill: Flutter Architecture

Use this skill when implementing Flutter features.

## Principles
- feature-first, layered architecture
- no business logic in widgets
- no scraping logic in presentation
- repositories are the external data boundary
- models are immutable
- Riverpod is the dependency/state system

## Layer guide
- presentation: screens, widgets, providers, UI state
- domain: entities, contracts, use cases
- data: datasources, repositories, models, parsers, selectors
