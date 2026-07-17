# Archive Cleanup Toolkit

Two small Linux utilities for cleaning large directory trees that contain ZIP, RAR, 7z, and multipart archives.

- `extract-archives-cleanup` recursively extracts supported archives one at a time, verifies the result, handles split RAR sets, and can delete successful archive sets.
- `find-leftover-archives` performs a read-only recursive audit for archives that remain anywhere below a directory.

The tools were built for one-time archive migrations where hundreds of nested folders may contain a mix of normal archives, split volumes, password-protected files, damaged archives, and filenames that exceed Linux filesystem limits.

## Highlights

- Recursive scanning with no practical folder-depth limit.
- Sequential extraction to avoid launching many disk-heavy jobs at once.
- Native multipart RAR support through `unrar`.
- Split ZIP and 7z set detection.
- Recovery for RAR entries whose UTF-8 filenames exceed ext4's 255-byte component limit.
- Safe layout handling:
  - A single wrapper directory is placed beside the archive without adding a duplicate folder.
  - Wrapperless or mixed-layout archives are contained in a directory named after the archive.
- Existing destination folders are merged only when colliding files are byte-identical.
- Password, CRC, missing-volume, extraction, and destination failures leave the archive set untouched.
- Optional deletion happens only after verified extraction and successful placement.
- Detailed text logs and TSV reports.

## Requirements

`extract-archives-cleanup` requires:

- Linux
- Python 3.10 or newer
- `7z`
- `unrar`
- `findmnt` from util-linux

On Fedora, the required archive commands are provided by the `7zip` and `unrar` packages.

`find-leftover-archives` requires Bash and standard GNU utilities such as `find`, `sort`, and `realpath`.

## Installation

Clone the repository and install both commands into `~/.local/bin`:

```bash
make install
```

Make sure `~/.local/bin` is in your `PATH`. On most modern Linux desktops it already is after signing out and back in.

To uninstall:

```bash
make uninstall
```

You can also run the scripts directly from the repository's `bin/` directory.

## Recommended workflow

### 1. Audit a directory tree

This command is read-only:

```bash
find-leftover-archives "/mnt/storage/archive-library"
```

It prints every archive path it finds and writes a TSV report under:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/archive-cleanup-toolkit/
```

The scanner recognizes more formats than the extractor. This is intentional: it can report TAR, gzip, bzip2, xz, and zstd files even though the extraction script currently focuses on ZIP, RAR, and 7z families.

### 2. Pilot extraction while keeping archives

```bash
extract-archives-cleanup \
  --keep-archives \
  "/mnt/storage/archive-library/Example Collection"
```

Keeping archives is the default, so this is equivalent:

```bash
extract-archives-cleanup "/mnt/storage/archive-library/Example Collection"
```

Review the extracted folders and the generated report before enabling deletion.

### 3. Extract and delete successful archive sets

```bash
extract-archives-cleanup \
  --delete-successful \
  "/mnt/storage/archive-library"
```

This permanently removes successful archive files. For a multipart set, every detected volume is deleted only after extraction, archive verification, layout handling, and destination placement all succeed.

To prevent desktop sleep during a long run:

```bash
systemd-inhibit \
  --what=idle:sleep \
  --mode=block \
  --why="Archive cleanup" \
  extract-archives-cleanup \
  --delete-successful \
  "/mnt/storage/archive-library"
```

## Layout examples

### Archive already has a wrapper directory

```text
photos.zip
└── photos/
    ├── image-01.jpg
    └── image-02.jpg
```

Result:

```text
photos/
├── image-01.jpg
└── image-02.jpg
```

The tool does not create `photos/photos/`.

### Archive has no wrapper directory

```text
videos.zip
├── clip-01.mp4
└── clip-02.mp4
```

Result:

```text
videos/
├── clip-01.mp4
└── clip-02.mp4
```

### Multipart RAR

```text
backup.part1.rar
backup.part2.rar
backup.part3.rar
```

Only `part1.rar` is processed as the entry point. `unrar` reads the later volumes automatically. After a verified successful run with `--delete-successful`, all three volumes are removed.

## Existing destinations and collisions

If a destination folder already exists, the tool compares collisions before merging:

- Byte-identical files are accepted as already present.
- New non-conflicting files are added.
- A different-content file collision rejects the placement and retains the archive.
- File-versus-directory conflicts reject the placement and retain the archive.

The tool never silently overwrites a different existing file.

## Overlong filenames

Some archives contain individual filenames longer than ext4 can store. A filename may appear shorter than 255 characters but still exceed 255 bytes when it contains emoji or other multi-byte Unicode characters.

For RAR archives, the tool detects those entries, excludes them from normal extraction, streams them separately, and saves them with deterministic shortened names while preserving the extension and a recognizable suffix where possible. The complete RAR set is then tested before it can be deleted.

## Supported extraction formats

- `.zip`
- traditional split ZIP sets such as `.z01` plus `.zip`
- numbered split ZIP sets such as `.zip.001`
- `.rar`
- multipart RAR sets such as `.part1.rar`, `.part2.rar`, and so on
- traditional RAR sets such as `.rar`, `.r00`, `.r01`, and so on
- `.7z`
- numbered split 7z sets such as `.7z.001`

Password-protected archives are not prompted for during unattended runs. They fail safely, remain on disk, and are recorded in the logs.

## Reports

By default, logs are written to:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/archive-cleanup-toolkit/
```

Override the extraction log directory when needed:

```bash
extract-archives-cleanup \
  --log-dir "$HOME/archive-reports" \
  "/mnt/storage/archive-library"
```

View the newest TSV report:

```bash
REPORT="$(ls -1t "$HOME/.local/state/archive-cleanup-toolkit"/*.tsv | head -n 1)"
column -t -s $'\t' "$REPORT" | less -S
```

## Safety notes

`find-leftover-archives` is read-only.

`extract-archives-cleanup --keep-archives` writes extracted files but does not delete archives.

`extract-archives-cleanup --delete-successful` permanently deletes successful archive sets. Keep a separate backup when archive deletion would be difficult or impossible to reverse.

External disks should remain connected for the entire run. Desktop sleep inhibition cannot protect against a USB hub, monitor, cable, or enclosure disconnecting.

## Development

Run syntax checks:

```bash
make check
```

Changes are documented in [CHANGELOG.md](CHANGELOG.md).

## License

MIT License. See [LICENSE](LICENSE).
