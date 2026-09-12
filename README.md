# Eisenlink helper

Offline PWA that shows how to load an Eisenlink adjustable dumbbell for any target weight, with an interactive 3D model.

**Live:** https://castellanza-alt.github.io/Eisenlink/

## What it does

Pick a weight and the app shows, in 3D, how the dumbbell is assembled and how many plates go on each side. Two modes:

- **Coppia** — two identical dumbbells, weight shown per hand (4–28 kg, 2 kg steps)
- **Singolo** — all plates on one dumbbell (up to 50 kg); weights beyond a single kit are flagged

Drag the model to rotate it. The last selection is remembered.

## The kit (per dumbbell)

| Part | Weight | Quantity |
|---|---|---|
| Handle (bar + two fixed square blocks) | 4 kg | 1 |
| Screw (knurled chrome disc + threaded shaft) | 1 kg | 2 |
| Large plate | 2 kg | 10 (5 pairs) |
| Small plate | 1 kg | 2 (1 pair) |

Plates are always mounted in pairs, one per side, outside the fixed block; the screw locks them.

## Stack

Vanilla HTML/CSS/JS, [three.js](https://threejs.org) r128 for the 3D model, Archivo (variable) embedded as base64, a service worker for offline use. No build step, no runtime dependencies.

## Files

| File | Role |
|---|---|
| `index.html` | the whole app |
| `three.min.js` | 3D library (local copy, offline) |
| `sw.js` | service worker — network-first for the page, cache-first for assets |
| `manifest.webmanifest` | PWA manifest |
| `icon-192.png`, `icon-512.png` | app icons |

## Updating

Replace the changed files and bump the cache name in `sw.js` (`eisenlink-vN`). On iOS, the Home Screen icon is frozen at install time: to pick up a new icon, remove the app and add it again from Safari.

## Install on iPhone

Open the live URL in Safari → Share → **Add to Home Screen**. Open it once online so the service worker can cache the files; from then on it works offline.
