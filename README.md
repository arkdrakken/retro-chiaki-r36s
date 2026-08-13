# Retro Chiaki — R36S / ArkOS Edition

**PS4 / PS5 Remote Play for R36S (RK3326), adapted for ArkOS by [ArkDrakken](https://github.com/arkdrakken).**

This repository is an R36S/ArkOS adaptation of [Retro Chiaki](https://github.com/ed-fruty/retro-chiaki), which is itself based on Chiaki by Florian Märkl and contributors.

> This project is not endorsed or certified by Sony Interactive Entertainment. You need your own compatible PlayStation console and PSN account.

## Current R36S status

The R36S port has been tested on real R36S hardware with:

| Component | Tested configuration |
|---|---|
| Device | R36S |
| SoC | Rockchip RK3326 |
| CPU | 4× Cortex-A35 |
| GPU | Mali-G31 |
| OS | ArkOS |
| Display | 640×480 DSI |
| Architecture | AArch64 |

The GUI has successfully initialized and remained running through the complete graphics path:

`Retro Chiaki -> Qt 5.15 -> EGLFS KMS -> GBM -> DRM/KMS -> Mali-G31 -> DSI1 640×480`

**Current release status is experimental until PS5 registration, controller input, audio and a complete live stream are validated on the packaged release.**

## What the R36S package changes

ArkOS ships an older userspace than the current Retro Chiaki ARM64 build expects. The R36S package therefore keeps all compatibility files private to Chiaki and does **not** replace ArkOS system libraries.

The package includes:

- a private Ubuntu 22.04 glibc 2.35 runtime used only by Retro Chiaki;
- a private compatible `libevdev.so.2`;
- matching Qt 5.15 EGLFS/KMS plugins;
- an ArkOS-specific DRM/KMS + GBM launcher;
- PortMaster `gptokeyb` integration;
- network diagnostics.

The launcher deliberately uses the Mali/GBM userspace already present in ArkOS at:

`/usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so`

The proprietary Mali driver is **not** redistributed in this repository or in the release ZIP.

## Installation

1. Download the latest R36S/ArkOS ZIP from **Releases**.
2. Extract it to the root of the EASYROMS partition / SD card containing the `ports` directory.
3. Verify:
   - `ports/PS5 Remote Play R36S.sh`
   - `ports/chiaki/chiaki`
4. Connect the R36S to the same network as the PlayStation console.
5. Optional: run **Ports → Chiaki R36S Network Test**.
6. Run **Ports → PS5 Remote Play R36S**.

No ArkOS system package is installed or replaced.

## Controls

Before streaming, `gptokeyb` is used for the desktop-style Chiaki interface. During a stream, Retro Chiaki uses the SDL game controller mapping supplied by PortMaster/ArkOS.

The exact final R36S control map is still being validated on hardware.

## Recommended first stream profile

For initial testing on RK3326:

- Resolution: **360p or 540p**
- FPS: **30**
- Codec: **H.264**

Start conservatively and increase quality after stable decode/audio/input are confirmed.

## Building

The original upstream ARM64 build remains available.

The R36S release workflow:

1. cross-builds Retro Chiaki for AArch64 on Ubuntu 22.04;
2. packages the normal ARM64 runtime;
3. adds the R36S private glibc/input/Qt-KMS compatibility layer;
4. creates a single ArkOS-ready ZIP.

R36S packaging files live in [`packaging/r36s`](packaging/r36s).

Tags matching `v*-r36s.*` trigger the dedicated R36S release workflow.

## Credits

### R36S / ArkOS adaptation

**ArkDrakken**
https://github.com/arkdrakken

Initial R36S adaptation: **2026**

### Upstream

- Retro Chiaki by **ed-fruty**
- Chiaki by **Florian Märkl** and contributors

The Remote Play implementation originates from the upstream Chiaki project. This fork claims authorship only for its own R36S/ArkOS adaptation and packaging work.

See [`NOTICE-R36S.md`](NOTICE-R36S.md) for details.

## License

This fork retains the upstream **GNU AGPL v3** licensing and the upstream OpenSSL linking exception.

See `COPYING` and `LICENSES/`.
