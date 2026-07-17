# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-07-17

### Added

- Recursive sequential extraction for ZIP, RAR, and 7z archive families.
- Optional deletion of archive sets after verified extraction and placement.
- Multipart RAR handling through the first volume.
- Detection and recovery of RAR entries with filesystem-incompatible overlong UTF-8 filenames.
- Wrapper-directory preservation without duplicate nesting.
- Archive-name fallback folders for wrapperless or mixed-layout archives.
- Collision-safe merging that accepts only byte-identical existing files.
- Detailed text logs and TSV status reports.
- Read-only recursive leftover archive scanner.
- Makefile installation into `~/.local/bin`.
