# Repository Guidelines

## Project Structure & Module Organization
- `docs/`: Product documentation and references.
  - `docs/specification.md`: Functional requirements.
  - `docs/datore-specification.md`: Source word data specification.
  - `docs/design.md`: Design decisions and constraints.
  - `docs/tasks.md`: Task backlog.
  - `docs/tech_debt.md`: Tech debt notes and refactoring direction.
- `src/main/`: Main application UI.
  - `src/main/view.mbt`: Shared view helpers (header and word display).
  - `src/style.css`: Tailwind `@theme` variables and minimal base rules.
- `todo_cli/`: Moonbit learning project (CLI).
  - `todo_cli/todo_cli.mbt`: CLI entrypoint and tests.
  - `todo_cli/todo/`: Core domain logic.
  - `todo_cli/storage/`: File persistence and temp path helper.
  - `todo_cli/moon.pkg.json`: Main package definition.
- `docs/images/`: Reference screenshots.

## Build, Test, and Development Commands
- `moon test`: run Moonbit tests (including `todo_cli`).
- `moon run -- <args>`: run CLI locally (inside `todo_cli`).

## Coding Style & Naming Conventions
- Language: Moonbit for application code.
- UI styling: Tailwind CSS (keep class usage minimal and layout-focused).
- Avoid arbitrary values in Tailwind classes when possible; prefer theme tokens and standard scales.
- Indentation: 2 spaces for Markdown and configuration files unless a tool dictates otherwise.
- Naming: use clear, descriptive, lowercase filenames (e.g., `todo_cli.mbt`, `word_filter.mbt`).

## Testing Guidelines
- Use Moonbit `test "name" { ... }` blocks.
- Prefer stable, isolated tests; CLI tests use temp files under `todo_cli/data/`.

## Commit & Pull Request Guidelines
- The current Git history uses short, Japanese messages without a formal convention. There is no enforced format yet.
- Keep commits small and scoped; include context in the body if the subject is ambiguous.
- For PRs (when used), include:
  - Purpose and summary of changes
  - Links to relevant tasks (e.g., `docs/tasks.md` entries)
  - Screenshots for UI changes

## Deployment Notes
- Target deployment platform: Cloudflare Workers. Document the deployment command and any required secrets when added.
