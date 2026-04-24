# Ohrenspiel — Sound Memory Game

A two-player memory card game for iPhone where you match **sounds** instead of pictures. No colors, no numbers — your ears are the only clue.

> *Ohrenspiel* is German for "ear game".

## How It Works

Two players take turns on the same device. Flip a card and it plays a sound. Flip a second card — if they match, you score a point and go again. If they don't, both cards flip back and the device is passed to the other player. The player with the most matched pairs when the board is cleared wins.

```
Flip card → hear sound → flip second card → match? → score + keep turn
                                          → no match? → flip back, pass device
```

## Features

- **Sound-only matching** — all cards look identical, pairs are identified by sound alone
- **3 sound themes** — choose your challenge before each game
- **3 difficulty levels** — scales from a quick 5-minute game to a proper challenge
- **Pass-and-play** — full-screen interstitial hides the board when handing the phone over
- **Live scoreboard** — both player scores, move counter, and elapsed timer always visible
- **Confetti + haptics** on match and game completion
- **3D card flip animation** — satisfying 0.35s ease-in-out rotation

## Sound Themes

| Theme | Sounds | Source |
|-------|--------|--------|
| 🎹 **Musical** | C-major scale, two octaves (Do Re Mi …) | Synthesized sine waves |
| 🏙️ **City** | Car horn, siren, train, bicycle bell, jackhammer, cash register … | Synthesized via FM + noise |
| 🐾 **Animals** | Dog, cat, bird, cow, frog, duck, bee, horse, pig, owl, lion, wolf | Bundled audio files |

## Difficulty Levels

| Level | Grid | Pairs |
|-------|------|-------|
| Easy | 4 × 2 | 4 |
| Medium | 4 × 4 | 8 |
| Hard | 4 × 6 | 12 |

## Screenshots

> *Coming soon — TestFlight build in progress.*

## Tech Stack

- **SwiftUI** — declarative UI, iOS 16+
- **Swift 6** — strict concurrency, `@MainActor` throughout
- **AVAudioEngine** — low-latency audio with a fixed 12-node graph (no runtime graph changes)
- **ToneGenerator** — PCM sine-wave synthesis with ADSR envelope to eliminate click artifacts
- **SynthConfig / OscillatorLayer** — FM synthesis, frequency sweeps, vibrato, noise, and pulse gating for the City theme
- **NavigationStack** with a typed `Route` enum for push navigation
- **xcodegen** — `project.yml` as the source of truth; `project.pbxproj` is generated

## Project Structure

```
SoundMemory/
├── App/
│   ├── SoundMemoryApp.swift       # @main, injects AppEnvironment
│   └── AppEnvironment.swift       # shared audio engine + nav path
├── Models/
│   ├── Difficulty.swift
│   ├── SoundTheme.swift           # 3 themes, 12 sounds each
│   ├── SoundTone.swift            # id + SoundSource (.synthesized / .file)
│   ├── Card.swift
│   ├── Player.swift
│   └── GameState.swift            # GamePhase FSM
├── Audio/
│   ├── AudioEngine.swift          # AVAudioEngine wrapper
│   ├── ToneGenerator.swift        # sine-wave PCM buffer with ADSR
│   └── SynthConfig.swift          # synthesis primitives
├── ViewModels/
│   ├── GameViewModel.swift        # game FSM, card matching, turn logic
│   └── TimerViewModel.swift       # stopwatch with pause/resume
├── Views/
│   ├── Home/HomeView.swift
│   ├── Theme/ThemeView.swift
│   ├── Difficulty/DifficultyView.swift
│   ├── Game/
│   │   ├── GameView.swift
│   │   ├── CardGridView.swift
│   │   ├── CardView.swift         # 3D flip animation
│   │   ├── ScoreBarView.swift
│   │   └── GameOverView.swift
│   ├── Pass/PassView.swift        # full-screen cover, hides board
│   └── Components/
│       ├── PulseModifier.swift
│       └── CelebrationView.swift  # confetti particles
└── Utilities/
    ├── HapticManager.swift
    └── Constants.swift
```

## Building

Requires Xcode 16+ and [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
git clone https://github.com/j0schka/soundmemory.git
cd soundmemory
xcodegen generate
open SoundMemory.xcodeproj
```

Run on a physical device or simulator (iOS 16+).

## Audio Architecture

The `AudioEngine` allocates 12 `AVAudioPlayerNode`s at init — one per possible tone ID — and never changes the graph again. This avoids HAL reconfiguration errors when switching difficulty levels. All buffers (synthesized and file-based) are normalized to mono Float32 44100 Hz before caching, so every node uses the same format.

```
GameViewModel.init()
  └── audio.preloadTones(theme.tones(for: difficulty))
        ├── .synthesized → ToneGenerator.buffer(config:)
        └── .file        → AVAudioFile → AVAudioConverter → standardFormat buffer

cardTapped()
  └── audio.play(toneID:)   // scheduleBuffer(.interrupts) — instant restart on re-tap
```

## Running Tests

```bash
xcodebuild test -scheme SoundMemory -destination 'platform=iOS Simulator,name=iPhone 16'
```

Tests cover: card deck shuffling, tone buffer generation, no-clipping verification, game-over detection, winner resolution, and theme/difficulty slicing.

## License

MIT
