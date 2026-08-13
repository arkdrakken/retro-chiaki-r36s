# R36S / ArkOS Modification Notice

This repository is a modified fork of **Retro Chiaki** containing an adaptation for the **R36S handheld (Rockchip RK3326 / Mali-G31) running ArkOS**.

## R36S adaptation

Maintained by **ArkDrakken**
GitHub: https://github.com/arkdrakken

Initial R36S adaptation work: **2026**

R36S-specific work includes:

- RK3326 / AArch64 runtime integration;
- ArkOS compatibility;
- 640×480 DRM/KMS display initialization;
- GBM / Mali-G31 userspace selection;
- private glibc 2.35 compatibility runtime;
- Qt 5.15 EGLFS/KMS compatibility packaging;
- PortMaster / gptokeyb launcher integration;
- R36S-specific release packaging and diagnostics.

## Upstream projects

This port is based on:

- **Retro Chiaki** by ed-fruty;
- **Chiaki** by Florian Märkl and contributors.

The PlayStation Remote Play protocol implementation originates from the upstream Chiaki project and its contributors. This R36S fork does not claim authorship of that implementation.

## License

This fork retains the upstream GNU AGPL v3 license and the upstream OpenSSL linking exception.

See `COPYING` and `LICENSES/`.
