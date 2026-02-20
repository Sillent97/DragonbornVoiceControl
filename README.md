# Dragonborn Voice Control (CommonLibSSE-NG) + Python Pipe Runtime

Say It – Dragonborn Voice Control is an SKSE/CommonLibSSE-NG plugin for Skyrim SE/AE/VR that adds voice commands (dialogue start/close/selection, shouts, powers, spells, weapons, potions) via a local IPC-connected runtime. DVCRuntime is an embedded/isolated Python server using Vosk or faster-whisper for on-device speech recognition.

## Requirements (Windows)

- Visual Studio 2022 Build Tools or Visual Studio 2022 (C++ workload)
- CMake 3.21+
- Ninja
- vcpkg with `VCPKG_ROOT` set

Papyrus (optional, for `.pex`):

- PapyrusCompiler.exe and TESV_Papyrus_Flags.flg
- Skyrim Papyrus sources (`Data/Scripts/Source`)
- SkyUI sources (`SKI_*.psc`)

## Build order (Release)

Configure:

```sh
cmake --preset release
```

Core targets:

```sh
cmake --build --preset release --target DragonbornVoiceControl
cmake --build --preset release --target papyrus
cmake --build --preset release --target stage-mod
```

Runtime targets (PyInstaller). Includes a patched bootloader to resolve the real executable path under MO2/USVFS for onedir apps (fixes `sys._MEIPASS` base path) — if build runtimes without it, auto-launch runtime won’t start with the game client and need to start DVCRuntime manually. To enable the fix, build pyinstaller-bootloader-usvfs first, then build the runtime targets:

```sh
cmake --build --preset release --target pyinstaller-bootloader-usvfs
cmake --build --preset release --target runtime-vosk
cmake --build --preset release --target runtime-whisper-cpu
cmake --build --preset release --target runtime-whisper-gpu
```

## Outputs

- `build/release/_mod/...`
- `build/release/runtime/<variant>/dist`
