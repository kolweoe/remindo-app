---
name: "Remindo Pixel RPG"
description: "Soft, cute 2D pixel-art RPG productivity design system pairing lavender-plum framing with warm cream parchment cards, crisp dark-purple borders, and pink and gold gamification accents."
---

## Overview

Remindo blends a cozy 2D pixel-art RPG aesthetic with practical offline productivity for Indonesian students. The interface feels warm, friendly, and rewarding rather than clinical: soft lavender skies and deep plum navigation frame warm cream parchment cards, accented by rose-pink action buttons and golden coin/XP rewards.

- **Brand Personality:** Cozy, encouraging, playful, and crisp.
- **Target Audience:** Indonesian university students and personal productivity users.
- **Design Style:** Soft 2D Pixel RPG — rounded tactile containers, crisp 2px dark-plum outlines, soft drop shadows, and generous cream card surfaces.

## Colors

The palette pairs a deep royal-purple **Primary** for navigation chrome, ribbons, and primary actions with warm cream parchment **Surfaces** for readable quest, wallet, and hero cards. **Secondary** rose-pink highlights primary creation triggers (`+` FAB, `+ Tambah Quest`), while **Accent** gold marks coins, crowns, and streaks.

```yaml
colors:
  primary: "#6D3FA8"
  on-primary: "#FFFFFF"
  primary-container: "#8B5CF6"
  on-primary-container: "#0F0F0F"
  secondary: "#D9468F"
  on-secondary: "#161616"
  secondary-container: "#FCE7F3"
  on-secondary-container: "#831843"
  accent: "#F59E0B"
  on-accent: "#2D1B4E"
  accent-container: "#FEF3C7"
  on-accent-container: "#78350F"
  surface: "#F3E8FF"
  on-surface: "#2D1B4E"
  surface-container-low: "#FFF8EB"
  on-surface-container-low: "#2D1B4E"
  surface-container: "#F7ECFF"
  on-surface-container: "#2D1B4E"
  surface-container-high: "#E9D5FF"
  on-surface-container-high: "#2D1B4E"
  surface-nav: "#4A2E70"
  on-surface-nav: "#FFFFFF"
  outline: "#4A2E70"
  outline-variant: "#D8B4FE"
  success: "#2E8B57"
  on-success: "#0F0F0F"
  warning: "#D97706"
  on-warning: "#2A2A2A"
  error: "#DC2626"
  on-error: "#FFFFFF"
```

## Typography

**Boogaloo** gives headings, ribbons, and level badges a friendly, hand-crafted RPG character, while **Capriola** keeps Indonesian quest titles, labels, and body copy crisp and legible on mobile screens. **Spline Sans Mono** handles tabular numbers for XP, Coins, Rupiah (`Rp`), and alarm clocks.

```yaml
typography:
  display-lg:
    fontFamily: "Boogaloo"
    fontSize: 44px
    fontWeight: 400
    lineHeight: 48px
    letterSpacing: 0px
  display-lg-mobile:
    fontFamily: "Boogaloo"
    fontSize: 32px
    fontWeight: 400
    lineHeight: 36px
    letterSpacing: 0px
  headline-lg:
    fontFamily: "Boogaloo"
    fontSize: 28px
    fontWeight: 400
    lineHeight: 34px
    letterSpacing: 0px
  headline-md:
    fontFamily: "Boogaloo"
    fontSize: 22px
    fontWeight: 400
    lineHeight: 28px
    letterSpacing: 0px
  title-md:
    fontFamily: "Capriola"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 22px
    letterSpacing: 0px
  body-md:
    fontFamily: "Capriola"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 0px
  label-lg:
    fontFamily: "Capriola"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 18px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: "Capriola"
    fontSize: 11px
    fontWeight: 400
    lineHeight: 14px
    letterSpacing: 0.2px
  mono-lg:
    fontFamily: "Spline Sans Mono"
    fontSize: 20px
    fontWeight: 700
    lineHeight: 24px
    letterSpacing: -0.2px
  mono-sm:
    fontFamily: "Spline Sans Mono"
    fontSize: 12px
    fontWeight: 600
    lineHeight: 16px
    letterSpacing: 0px
```

## Layout & Spacing

Remindo is a mobile-first Android application (`390px` viewport) built on a single-column fluid grid with `16px` page margins and `12px` card gutters. A strict `4px` base unit keeps icons, badges, and pixel-bordered cards aligned, while a fixed 5-slot bottom navigation bar (`Home | Quests | (+) | Wallet | Hero`) anchors primary destinations.

```yaml
spacing:
  unit-xs: 4px
  unit-sm: 8px
  unit-md: 12px
  unit-lg: 16px
  unit-xl: 24px
  page-margin: 16px
  nav-height: 72px
```

## Elevation & Depth

Depth is achieved through **crisp 2px dark-plum borders (`outline`)** paired with **soft bottom-offset tactile shadows** (e.g., `0 3px 0 #4A2E70` for interactive buttons and `0 4px 12px rgba(45, 27, 78, 0.12)` for parchment cards). Avoid glassmorphism or heavy blur; keep edges clean, tactile, and pixel-crisp.

## Shapes

UI containers combine soft rounded corners with sturdy 2px outlines so the interface feels friendly and tactile without losing its pixel-RPG structure.

```yaml
rounded:
  sm: 6px
  DEFAULT: 12px
  md: 14px
  lg: 18px
  xl: 24px
  full: 9999px
```

## Motion & Micro-interaction

Interactions feel snappy and tactile, like pressing a physical game button: buttons depress slightly on active press (`translateY(2px)`), while XP bars and modal sheets ease smoothly into place.

```yaml
motion:
  button-press:
    duration: 100ms
    delay: 0ms
    timingFunction: ease-out
  surface-enter:
    duration: 220ms
    delay: 0ms
    timingFunction: cubic-bezier(0.2, 0, 0, 1)
```

## Voice & Content Strategy

- **Tone of Voice:** Warm, motivating, and casual Indonesian (`"3 quest siap!"`, `"Ayo selesaikan!"`, `"Upgrade Kamar"`). RPG terms like `Quest`, `XP`, `Coin`, `Hero`, `Wallet`, `Home`, and `Streak` stay in English/Indonesian hybrid as specified in the app brief.
- **Capitalisation:** Title Case for screen headers, tabs, and navigation items; Sentence case for quest descriptions, prompts, and helper text.
- **Numbers & Currency:** Use Indonesian Rupiah format (`Rp 245.750`) with dot thousand separators and `tabular-nums` for all XP, Coin, and currency values.

## Components

Component implementations live as individual HTML sticker sheet files in
`components/`. Each file contains the canonical, styled HTML components with
`<!-- COMPONENT: name -->` comment markers. Read each file before use.

- **Badge** → `@components/badge.html`: `badge-numeric`, `badge-dot`
- **Button** → `@components/button.html`: `button-primary`, `button-icon`, `button-with-icon`
- **Card** → `@components/card.html`: `card-elevated`, `card-action`, `card-interactive`, `card-interactive-2`
- **Typography** → `@components/typography.html`: `typography-display`, `typography-body`, `typography-label`
