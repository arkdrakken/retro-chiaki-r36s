# Retro Chiaki for R36S / ArkOS

**R36S / ArkOS adaptation by [ArkDrakken](https://github.com/arkdrakken).**

This document describes the R36S-specific build and packaging layer for Retro Chiaki.

## Target hardware

| Component | Target |
|---|---|
| Device | R36S |
| SoC | Rockchip RK3326 |
| CPU | 4× ARM Cortex-A35 |
| GPU | Mali-G31 |
| Display | 640×480 DSI |
| OS | ArkOS |
| Architecture | AArch64 |

## Current status

The GUI has been verified on real R36S hardware through the complete graphics path:

`Retro Chiaki -> Qt 5.15 -> EGLFS KMS -> GBM -> DRM/KMS -> Mali-G31 -> DSI1 640×480`

The packaged release remains experimental until PS5 registration, controller input, audio and a complete live stream have been validated.

## Runtime design

ArkOS uses an older base userspace than the Ubuntu 22.04 ARM64 Retro Chiaki build. The R36S package therefore carries a private compatibility runtime used only for Retro Chiaki.

It includes:

- private glibc 2.35 runtime;
- compatible `libevdev.so.2`;
- matching Qt 5.15 EGLFS/KMS libraries and plugins;
- R36S/ArkOS launch scripts;
- network diagnostics.

No ArkOS system library is replaced.

The launcher uses the Mali/GBM userspace already shipped with the tested ArkOS image:

`/usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so`

The proprietary Mali driver is not redistributed in this repository or release ZIP.

## Installation

1. Download the R36S/ArkOS release ZIP.
2. Extract it to the root of the EASYROMS partition / SD card containing `ports`.
3. Confirm that `ports/PS5 Remote Play R36S.sh` and `ports/chiaki/chiaki` exist.
4. Connect the R36S to the same network as the PlayStation console.
5. Optionally run **Ports -> Chiaki R36S Network Test**.
6. Run **Ports -> PS5 Remote Play R36S**.

## Recommended first stream profile

For initial RK3326 testing:

- Resolution: **360p or 540p**
- FPS: **30**
- Codec: **H.264**

Increase quality only after stable decoding, audio and controller input are confirmed.

## Credits

R36S / ArkOS adaptation and packaging: **ArkDrakken**.

Based on Retro Chiaki by **ed-fruty** and Chiaki by **Florian Märkl** and contributors.

## License

This fork retains the upstream GNU AGPL v3 licensing and OpenSSL linking exception. See `COPYING`, `LICENSES/` and `NOTICE-R36S.md`.