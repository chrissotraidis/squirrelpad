# ROM import investigation (#3)

Updated 2026-10-27. These changes are unreleased; merging them does not update the
recipe selected by PadMint. The report on iOS 27.2 RC remains open for device confirmation.

## Findings and change

SquirrelPad 0.1.2 named an imported N64 UTI without declaring it in Info.plist.
Launching its UI on iOS 27.0 logs a Type Declaration Issues fault. Its picker
also filtered on `public.data`, and its main-actor import synchronously read,
hashed and copied the selected file. File-provider delays therefore block UI
updates during import. The main thread had no importing state to display.

The ROM picker now offers `public.item` and validates the actual bytes after
selection. It does not depend on an extension or a provider's type being a
subtype of `public.data`; the unused undeclared UTI is removed. Folders,
compressed files, unsupported byte order, wrong sizes and wrong checksums are
rejected. Only the same supported US ROM can start the game.

`ROMImport` coordinates the provider read, keeps security-scoped access until
it has finished, checks size before allocating the full file, and writes the
verified ROM atomically. It runs in a detached task, with an importing message
and duplicate import/play actions disabled. A failed replacement does not
modify the stored ROM or saves.

This is a repair of concrete import defects, **not proof of the reporter's
exact root cause**. The original 0.1.2 UI could open Files and select a local
`.z64` fixture on a fresh iPhone 17 Pro Max simulator running iOS 27.0. There is
no iOS 27.2 RC runtime here. The reporter has been asked whether the picker
fails to open, greys out the file, or stalls after selection, which provider
holds the file, and which app version is installed.

## Verification

- `python3 -m unittest discover -s tests -p test_rom_import.py` compiles the
  production Swift importer and exercises folders, missing files, short files,
  64 MiB files with wrong byte order or checksum, and preservation of an
  existing import and save after each rejection. No game data is in the suite.
- Setting `SQUIRRELPAD_TEST_ROM` to a private supported ROM additionally checks
  a successful import with an arbitrary extension, byte-for-byte readback,
  reimport of the existing stored ROM and preservation of a save sentinel.
- The app's actual Swift UI compiles in a simulator harness with no-op native
  game/renderer/audio functions. On the iPhone 17 Pro Max/iOS 27.0 simulator,
  invalid selection produces the new actionable error; a supported local ROM
  is copied with the expected checksum, switches to the game surface, and
  Settings still opens. The same supported-file import and Settings check pass
  on the iPad (A16)/iPadOS 27.0 simulator; a cold launch retains the ROM,
  cancelling Choose another ROM keeps it, and Play Conker starts again. This
  harness does not test gameplay.
- All ten Python-discovered native, controller, patch and import tests pass,
  using the clean player build’s pinned headers/host archive and a private ROM
  for the optional successful-import cases.
- PadMint `scripts/player-check.sh` from main `e8cc824d7fd70ee031cb477e7777ea1f76257253`
  passed against clean SquirrelPad `010ed66`, using Apple Python 3.9.6 and an
  empty PadMint folder. The complete unsigned iOS app built in 584 seconds;
  its ARM64/package audit has no failures and all 26 notices. Executable SHA-256:
  `99c4b0e722400777cf88204f2d6a2e74f19b3b21f275835a1fadcd6a1309c957`.
  No personal IPA or ROM is published.

Cloud-provider downloads, a physical iPhone 17 Pro Max, and iOS 27.2 RC remain
unverified. Do not close #3 solely on the basis of a successful build or these
simulator checks.

## Other ports

A read-only check of current GitHub `main` sources on 2026-10-27 found similar
filtering, but different import implementations:

| Ports | Picker behavior |
| --- | --- |
| AnnePad, BananaPad, PaperPad, DinoPad, SnapPad | `UTTypeData`, UIKit copies the selection (`asCopy:YES`) |
| BellPad | `UTTypeData`, opens the original (`asCopy:NO`) |
| BearBirdPad | `UTTypeData` plus types derived from extensions, opens the original |
| GoldenPad | Declared N64 type in its SwiftUI picker |
| YomiBoy | `.data`, with its own asynchronous import path |

These are candidates for provider/type compatibility testing, not confirmed
instances of #3. In particular, UIKit's copy mode differs from SquirrelPad's
former uncoordinated direct read. No cross-project changes are justified by
this report alone, and this change does not claim to fix every port. PadMint
builds the apps; it does not implement their on-device document pickers.

Apple's [type declaration documentation](https://developer.apple.com/documentation/uniformtypeidentifiers/defining-file-and-data-types-for-your-app)
explains the Info.plist requirement. Keep picker type filtering separate from
content validation when investigating a new report.
