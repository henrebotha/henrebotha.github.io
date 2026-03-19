---
layout: post
title: Exquis setup
date: 2026-03-19 14:45 +0200
tags: [music, quickie]
---
I recently bought an Intuitive Instruments Exquis, thanks to my wife.

The documentation for this controller is a little fragmented and curt, so I am sharing here some succinct notes on how to configure and use it.

## Writing Exquis notation

I find the characters `⬡` (U+2b21) and `⬢` (U+2b22) useful for writing out chord shapes or similar.

In the default layout, this is how you can play an open minor triad (0 + 7 + 15).

```
 ⬡ ⬢
⬡ ⬡ ⬡
 ⬢ ⬡
⬡ ⬡ ⬡
 ⬢ ⬡
```

I don't know what standards exist for defining layouts, but privately, I've been using the convention [±n/±m], where n is how many semitones you move when you move 1 hex to the right, and m is how many you move when you move up-right.
The default layout is thus [+1/+4], which can be visualised as follows.

```
    ⬡
+4 ↗
  ⬢ → ⬡ 
   +1
```

## Configuring the keyboard

### Buttons

I'll refer to the encoders by their number, starting from the left.
"Turn" means turn the knob; "click" means press it.

The "gear" button ⚙︎ is the "keyboard settings" button, which is really just a grab bag of stuff that includes both "technical" (MIDI clock, LED brightness) and "musical" (tonic, scale) aspects.
The "squiggle" button ∿ is the "MIDI and layout settings" button.

### Shortcuts

- **MIDI output**
  - **Toggle MPE/poly aftertouch** (aka non-MPE): ∿ + click 1
  - **Choose MIDI output channel** (poly aftertouch mode): ∿ + turn 1
    - Set to 1 to use with non-MPE hardware while retaining some pitch bend facility
  - **Choose number of MPE channels**: ∿ + turn 1
- **Keyboard layout**
  - **Change note layout**: ∿ + turn 3
    <details>
      <summary><em>Click for list of layouts</em></summary>
      <ol type=1>
        <li>Default</li>
        <li>Default with duplicates</li>
        <li>Chromatic</li>
        <li>4×4 drum pads</li>
        <li>General MIDI percussion</li>
        <li>Rainbow</li>
      </ol>
    </details>
  - **Adjust tonic note**: ⚙︎ + turn 2
  - **Adjust scale**: ⚙︎ + turn 3
    <details>
      <summary><em>Click for list of scales</em></summary>
      <ol type=1>
        <li>Major</li>
        <li>Natural Minor</li>
        <li>Melodic Minor</li>
        <li>Harmonic Minor</li>
        <li>Dorian</li>
        <li>Phrygian</li>
        <li>Lydian</li>
        <li>Mixolydian</li>
        <li>Locrian</li>
        <li>Phrygian dominant</li>
        <li>Major Pentatonic</li>
        <li>Minor Pentatonic</li>
        <li>Whole Tone</li>
        <li>Chromatic</li>
      </ol>
    </details>
  - **Transpose keyboard stepwise**: ⚙︎ + ⌃︎/⌄︎
- **Adjust tempo**: ⚙︎ + turn 1
- **Hardware**
  - **Adjust sensitivity**: ⚙︎ + click & turn 4
  - **Adjust brightness**: ⚙︎ + turn 4

