# Release checklist

Use this checklist before publishing a release candidate or stable version.

## Repository

- [ ] Repository visibility is appropriate for the intended pub.dev release. If publishing publicly, make the repository public so homepage, repository, issue tracker, architecture, and migration links are accessible.
- [ ] `main` branch protection or a repository ruleset requires pull requests.
- [ ] Required checks include `Flutter stable` and `Flutter 3.19.0`.
- [ ] Force pushes and deletion of `main` are disabled.

## Quality gates

- [ ] `dart format --output=none --set-exit-if-changed lib test example benchmark`
- [ ] `flutter analyze`
- [ ] `flutter test --coverage`
- [ ] Example package resolves, analyzes, and tests successfully.
- [ ] `flutter pub publish --dry-run` succeeds.
- [ ] Golden files are intentional and reviewed.
- [ ] Manual benchmark results are compared with the previous recorded baseline on controlled hardware.

## API and docs

- [ ] `doc/public-api.md` matches `lib/design_scale.dart`.
- [ ] Debug-only APIs remain in `lib/design_scale_debug.dart`.
- [ ] README usage matches the example application.
- [ ] CHANGELOG contains the release version and notable behavior changes.
- [ ] Migration guides reflect any breaking changes.

## Release candidate validation

- [ ] Validate in at least one real mobile application.
- [ ] Validate portrait and landscape.
- [ ] Validate keyboard open/close behavior.
- [ ] Validate large text/accessibility scaling.
- [ ] Validate a tablet or resized desktop/web window.
- [ ] Record any production issue as a regression test before the next release.

`1.0.0` should not be published until the release-candidate API has completed real-application validation.
