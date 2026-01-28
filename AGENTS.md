# Repository Guidelines

## Project Structure & Module Organization
- `docs/`: Product documentation and references.
  - `docs/specification.md`: Functional requirements.
  - `docs/datore-specification.md`: Source word data specification.
  - `docs/design.md`: Design decisions and constraints.
  - `docs/tasks.md`: Task backlog.
- Source code and tests are not yet checked in. When added, keep app code under a single top-level directory (e.g., `src/`) and tests under `tests/` or alongside modules.
- `docs/images/`: Reference screenshots.

## Build, Test, and Development Commands
- No build/test commands are defined yet. When introducing a toolchain, document the exact commands here.
  - Example format:
    - `moon build`: build the app
    - `moon test`: run tests
    - `npm run dev`: local dev server (if used)

## Coding Style & Naming Conventions
- Language: Moonbit for application code.
- UI styling: Tailwind CSS (keep class usage minimal and layout-focused).
- Indentation: 2 spaces for Markdown and configuration files unless a tool dictates otherwise.
- Naming: use clear, descriptive, lowercase filenames (e.g., `typing_session.mbt`, `word_filter.mbt`).

## Testing Guidelines
- No testing framework is set yet. Once decided, add:
  - How to run tests (command)
  - Naming rules (e.g., `*_test.mbt`)
  - Minimum coverage expectations, if any

## Commit & Pull Request Guidelines
- The current Git history uses short, Japanese messages without a formal convention. There is no enforced format yet.
- Keep commits small and scoped; include context in the body if the subject is ambiguous.
- For PRs (when used), include:
  - Purpose and summary of changes
  - Links to relevant tasks (e.g., `docs/tasks.md` entries)
  - Screenshots for UI changes

## Deployment Notes
- Target deployment platform: Cloudflare Workers. Document the deployment command and any required secrets when added.
