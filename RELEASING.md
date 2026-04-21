# Публикация релизов / Releases

## Русский

1. Залейте репозиторий на GitHub, включите submodules: `git submodule update --init --recursive`.
2. **Actions → SilentGuard build matrix → Run workflow**: укажите тег версии, при необходимости **Publish Release**.
3. Для загрузки релиза используется `GITHUB_TOKEN`. По умолчанию релизы ищутся в `OptimusFaber/SilentGuard` (см. `Utils.hpp`, `check_new_release.js`); при другом форке задайте `SILENTGUARD_GITHUB_REPO`.
4. **Windows:** установщик `*-windows64-installer.exe`. **Linux:** AppImage / архив из артефактов.

## English

Push the repo, run the workflow, attach binaries to Releases. Update checks default to `OptimusFaber/SilentGuard`; override with `SILENTGUARD_GITHUB_REPO` if needed. GitHub Actions still use third-party composite actions and ruleset URLs from the upstream fork; if those repos disappear, fork or replace them.
