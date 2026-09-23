---
name: I-Keeping Books
description: Warm coquette library — dusty rose light, cream glass panes, and the circular brand logo.
colors:
  case-indigo: "#7A3F4A"
  case-deep: "#2C1810"
  case-mist: "#E8D5C8"
  case-glass: "#FFF8F0"
  case-glass-fill: "#99FFF8F0"
  case-glass-fill-dark: "#667A3F4A"
  purple-secondary: "#D4899A"
  metal-edge: "#C4A894"
  label-ink: "#1A1410"
  label-muted: "#6B5A52"
  on-dark: "#FFF8F0"
  cream-wash: "#FFF5EE"
  peach-wash: "#F0D9CC"
  rose-wash: "#E8C4B8"
  mint-accent: "#C5D9C8"
  dialog-surface: "#FFF8F0"
  signal-green: "#16A34A"
  signal-amber: "#D97706"
  signal-red: "#DC2626"
typography:
  display:
    fontFamily: "Poppins, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.5px"
  headline:
    fontFamily: "Poppins, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.3px"
  title:
    fontFamily: "Poppins, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "normal"
  body:
    fontFamily: "Poppins, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "normal"
  label:
    fontFamily: "Poppins, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "normal"
rounded:
  shelf: "2px"
  sm: "12px"
  md: "14px"
  lg: "16px"
  pane: "18px"
  dialog: "20px"
spacing:
  xs: "8px"
  sm: "10px"
  md: "12px"
  lg: "14px"
  xl: "16px"
  section: "24px"
components:
  button-primary:
    backgroundColor: "{colors.case-indigo}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.md}"
    padding: "14px 20px"
    height: "52px"
  button-primary-hover:
    backgroundColor: "{colors.case-deep}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.md}"
  button-outline:
    backgroundColor: "transparent"
    textColor: "{colors.case-indigo}"
    rounded: "{rounded.md}"
    height: "52px"
  glass-pane:
    backgroundColor: "{colors.case-glass-fill}"
    textColor: "{colors.label-ink}"
    rounded: "{rounded.pane}"
    padding: "16px"
  specimen-label:
    backgroundColor: "{colors.case-glass-fill}"
    textColor: "{colors.label-ink}"
    rounded: "{rounded.pane}"
    padding: "12px 14px"
  instrument-tile:
    backgroundColor: "{colors.case-glass-fill}"
    textColor: "{colors.label-ink}"
    rounded: "{rounded.pane}"
    padding: "14px"
  fab-add:
    backgroundColor: "{colors.case-indigo}"
    textColor: "{colors.on-dark}"
    rounded: "{rounded.lg}"
    size: "56px"
  input-search:
    backgroundColor: "rgba(255,255,255,0.65)"
    textColor: "{colors.label-ink}"
    rounded: "{rounded.lg}"
    padding: "12px 16px"
  nav-bar:
    backgroundColor: "{colors.case-glass-fill}"
    textColor: "{colors.label-ink}"
    rounded: "{rounded.sm}"
---

# Design System: I-Keeping Books

## Overview

**Creative North Star: "Only Hope Library Nook"**

The interface borrows light from the circular brand logo: warm dusty-rose library glow, cream frosted panes, rosewood primary fills, and soft pastel-pink accents. Glassmorphism stays, but the gallery shifts from cool indigo to a cozy coquette reading nook — soft peach washes, taupe metal edges, and mint secondary glow from the logo’s center badge.

Density stays calm and labeled. Home, Books, Borrow, and More keep Material 3 structure; brand lives in the warm wash, cream panes, rosewood FAB/buttons, and the circular logo on splash and login.

**Key Characteristics:**
- Cream → peach → dusty rose background wash (logo atmosphere)
- Rosewood primary (`#7A3F4A`) and pastel pink secondary (`#D4899A`)
- Frosted cream panes with taupe / rose-gold metal edges
- Circular logo asset (`assets/branding/logo.png`) on splash, login, and launcher
- Poppins throughout Material type roles
- Status only as green / amber / red signal lamps

## Colors

Warm library light pulled from the brand mark; traffic colors reserved for stock signals.

### Primary
- **Rosewood** (`{colors.case-indigo}`): Seed and primary fill — FAB, filled buttons, snackbar, dark nav wash.
- **Espresso Deep** (`{colors.case-deep}`): Dark-mode scaffold base.

### Secondary
- **Pastel Pink** (`{colors.purple-secondary}`): Soft secondary — nav indicator, icons, focus ring. Never used as status.
- **Mint Accent** (`{colors.mint-accent}`): Soft ambient glow from the logo’s center badge.

### Neutral
- **Cream / Peach / Rose washes**: Light scaffold gradient.
- **Glass Fill**: Cream frosted panes.
- **Metal Edge**: Soft taupe / rose-gold borders.
- **Label Ink / Muted**: Near-black and warm brown-gray text.
- **On Dark**: Cream on rosewood fills.

### Tertiary (signal lamps only)
- **Signal Green / Amber / Red**: Stock and error only.

### Named Rules
**The Signal Lamp Rule.** Green, amber, and red appear only as stock/error signals.

**The Logo Light Rule.** Screens sit on cream → peach → rose wash (light) or espresso → wood → rosewood (dark), matching the circular logo’s library atmosphere — not cool indigo or flat white.

## Typography

**Display / Body:** Poppins. Clean specimen typography with Material roles.

## Layout

Phone-first Material shell unchanged: transparent scaffold over `CaseBackground`, SafeArea, bottom nav, 16px page inset.

## Elevation & Depth

Frosted cream glass over warm wash; thin taupe metal edges; soft lift only when elevated.

## Components

Same component recipes as before, recolored to rosewood / pastel pink / cream. Logo appears on splash and login; adaptive launcher uses dusty-rose `#E8D5C8` background.

## Do's and Don'ts

### Do:
- **Do** keep cream panes and warm wash aligned with the logo.
- **Do** reserve green / amber / red for signal lamps.
- **Do** use the circular logo as the app mark (splash, login, launcher).

### Don't:
- **Don't** return to cool indigo / purple gallery light.
- **Don't** use status colors as brand fills.
- **Don't** replace the circular logo with the old coral book mark.
