# Version History

## v1.0.4 (2026-06-13) — Current

**Sample configs, security harness, documentation expansion**

- Complete sample configurations for all platforms (PowerShell, Bash, Zsh, Fish, Git-Bash)
- Wiki documentation: Sample-Configs.md with 9 use cases across 5 shells
- Platform-specific integration guides with full code blocks
- Package manager manifest validation tests
- Documentation existence tests
- Security harness tests (no Invoke-Expression, safe config paths, safe cow files)
- Proof of legitimacy documentation for package manager reviewers
- Winget submission (PR #387476)
- Scoop submission (PR #18034)
- Fixed Show-FortuneCow function not defined in setup.ps1 generated profiles
- Fixed duplicate tab completion blocks in profile.ps1
- Fixed missing parameter names in cowpreview/cowgallery functions
- Fixed lolcat toggle not displaying current state
- Moved package manager docs from hidden .agent/ to visible package-managers/

## v1.0.3 (2026-06-13)

**Package manager support, interactive setup, figlet banner**

- Added winget manifests (`HKDEVS.Forgum`)
- Added Scoop manifest with autoupdate
- Created `setup.ps1` interactive setup with 6 shell toggles
- Figlet banner across all install scripts
- Fixed double output bug in `forgum -Lolcat`
- Updated README with banner and demo screenshots
- Renamed repo from CowsayFortune to Forgum
- **142 tests passing, 0 lint issues**

Commits: `2cf4ddf` → `d284127`

## v1.0.2 (2026-06-13)

**Lint, security, and code review fixes**

- Fixed lolcat rainbow algorithm (sine-wave color distribution)
- Fixed thought bubble alignment (heredoc regex)
- Added VTTerminal type guard
- Eliminated empty catch blocks
- Added Ghost test suite (30 hostile QA tests)
- Added security harness (22 tests)
- Fixed config defaults

Tag: `9a65494`

## v1.0.1 (2026-06-12)

**Initial public release**

- Core cowsay, fortune, lolcat functionality
- 107 cow templates
- 3 animation modes (static, talking, typewriter)
- Truecolor + 256-color support
- Cross-platform PowerShell module
- CI pipeline (Ubuntu, Windows, macOS)

## Release Assets

| Version | Asset | SHA256 |
|---------|-------|--------|
| v1.0.4 | `Forgum-v1.0.4.zip` | `pending` |
| v1.0.3 | `Forgum-v1.0.3.zip` (317KB) | `d9f6623d7dbe1581cbbb1fd58fd748fc0eac5ced576c9fdb0daf31f5f857d262` |

## Git Tags

```
v1.0.4 (latest)
v1.0.3
v1.0.2
```
