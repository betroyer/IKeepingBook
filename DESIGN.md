---
name: I-Keeping Books
description: Rare-book glass case — frosted panes and labeled specimens for offline library inventory.
colors:
  case-indigo: "#1A2744"
  case-deep: "#0B1220"
  case-mist: "#C5D0EA"
  case-glass: "#E8EEF8"
  case-glass-fill: "#99E8EEF8"
  case-glass-fill-dark: "#661A2744"
  purple-secondary: "#5B4B8A"
  metal-edge: "#8B9BB8"
  label-ink: "#0F172A"
  label-muted: "#475569"
  on-dark: "#E8EEF8"
  gallery-wash: "#D8D0EA"
  dialog-surface: "#F4F7FC"
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

**Creative North Star: "Rare-Book Glass Case"**

The interface is a lit museum case for a personal library: cool indigo gallery light behind frosted panes, thin metal edges, and typed specimen labels. Surfaces read as glass under soft ambient glow, not as purple-tinted CRUD chrome or opaque admin cards. Material 3 supplies navigation, FAB, dialogs, and snackbars; brand lives in the case lighting, frosted panes, and signal lamps.

Density stays calm and labeled. Home opens the case with four instrument tiles and a glass shelf of recent specimens; Books tends stock via search, labeled list rows, and an indigo FAB. Status never becomes a decorative accent — only green, amber, or red signal lamps mark stock health.

**Key Characteristics:**
- Cool indigo gallery gradient with soft purple secondary wash
- Frosted translucent panes (blur 18) with 1px metal-edge borders
- Specimen label cards: title, category, copies — lamp first, no icon plaque
- Poppins throughout Material type roles
- Status only as green / amber / red signal lamps

## Colors

Cool indigo gallery light with a soft purple secondary and metal-edge neutrals; traffic colors reserved for stock signals.

### Primary
- **Case Indigo** (`{colors.case-indigo}`): Seed and primary fill — FAB, filled buttons, snackbar, dark nav wash. Anchors the case frame.
- **Case Deep** (`{colors.case-deep}`): Dark-mode scaffold base and ambient shadow tint.

### Secondary
- **Gallery Purple** (`{colors.purple-secondary}`): Soft secondary — nav indicator wash, instrument/empty icons, focus ring, sample-notice edge. Never used as status.

### Neutral
- **Case Glass** (`{colors.case-glass}`): Light gallery paper — gradient start and on-dark text.
- **Case Mist** (`{colors.case-mist}`): Mid gradient band and light ColorScheme surface.
- **Gallery Wash** (`{colors.gallery-wash}`): Soft purple-tinted gradient end in light mode.
- **Glass Fill** (`{colors.case-glass-fill}` / `{colors.case-glass-fill-dark}`): Frosted pane fills (alpha baked into ARGB).
- **Metal Edge** (`{colors.metal-edge}`): Thin pane borders and shelf rail, typically at ~45–55% opacity.
- **Label Ink** (`{colors.label-ink}`): Primary text in light mode.
- **Label Muted** (`{colors.label-muted}`): Categories, copies, secondary copy.
- **On Dark** (`{colors.on-dark}`): Text/icons on indigo fills.
- **Dialog Surface** (`{colors.dialog-surface}`): Light dialog panel.

### Tertiary (signal lamps only)
- **Signal Green** (`{colors.signal-green}`): Healthy stock.
- **Signal Amber** (`{colors.signal-amber}`): Low stock (quantity ≤ 5).
- **Signal Red** (`{colors.signal-red}`): Errors and destructive affordances (e.g. delete icon).

### Named Rules
**The Signal Lamp Rule.** Green, amber, and red appear only as stock/error signals — never as brand accents or decorative chips.

**The Case Light Rule.** Screens sit on the gallery gradient (`case-glass` → `case-mist` → `gallery-wash` light; `case-deep` → `case-indigo` → deep purple wash dark), not on flat white or solid purple fields.

## Typography

**Display Font:** Poppins (with system sans-serif fallback)
**Body Font:** Poppins (same family)

**Character:** Clean specimen typography — confident weight steps, slightly tightened display/app-bar tracking, no decorative display serif.

### Hierarchy
- **Display** (700, 24px, tight −0.5): Instrument tile values (`headlineSmall`).
- **Headline** (700, 22px, −0.3): App bar titles (`titleLarge`).
- **Title** (600–700, 16px): Section headers (`titleMedium` w700) and book names (`titleMedium`/`titleSmall` w600).
- **Body** (400, 14px): Supporting copy and empty-state messages; muted uses `{colors.label-muted}`.
- **Label** (500–600, 12px): Instrument labels, stock lines, nav labels (`labelMedium`).

### Named Rules
**The Specimen Type Rule.** Book rows read as printed labels: strong title, muted category/copies — no badge stacks or uppercase micro-kickers.

## Layout

Phone-first Material shell: transparent scaffold over `CaseBackground`, content in SafeArea with bottom nav. Horizontal page inset is 16px; section gaps 12–16px; list separators 10px; bottom lists pad ~100px clear of nav/FAB.

Home vitals use a 2×2 grid (`crossAxisCount: 2`, 12px gutters, aspect ~1.35). Recently added sits above a thin metal `CaseShelfRail`, then a vertical stack of specimen panes. Books: search field under app bar, then spaced label cards. Empty states center a single glass pane with 24px outer padding.

## Elevation & Depth

Depth comes from frosted glass over gallery light, not stacked Material shadows. Default panes use blur (sigma 18) + translucent fill + 1px metal border. Soft drop shadow appears only when a pane is explicitly `elevated`, or as a faint rail shadow under the shelf.

### Shadow Vocabulary
- **Elevated pane** (`0 8px 18px rgba(11,18,32,0.14)`): Optional glass lift when `GlassCard.elevated` is true (border omitted).
- **Shelf rail** (`0 2px 4px rgba(11,18,32,0.18)`): Thin metal ledge under recent specimens.
- **Lamp glow** (`0 1px 6px` at signal color 45%): Halo on the 10px signal lamp only.

### Named Rules
**The Pane-Not-Card Rule.** Prefer metal-edge border + blur over resting drop shadows. Shadows are exceptional lift, not the default surface recipe.

## Shapes

Gently curved case hardware: panes at 18px; search and FAB at 16px; buttons/inputs at 14px; dialogs at 20px; snackbars at 12px; category icon wells at 12px; shelf rail nearly square (2px). Borders are 1px metal edge at reduced opacity. Signal lamps are true circles (10px) with a light rim.

## Components

### Buttons
- **Shape:** 14px radius; primary height 52px.
- **Primary:** Case indigo fill, on-dark label/icon (`GlassButton` filled / Material FilledButton).
- **Outline:** Transparent with metal-edge side (~70% opacity), indigo foreground.
- **Hover / Focus:** Material ripple; inputs take purple-secondary focus stroke (1.5px).

### Cards / Containers
- **Corner Style:** 18px pane radius.
- **Background:** Light `{colors.case-glass-fill}` or dark `{colors.case-glass-fill-dark}` over blur.
- **Border:** 1px `{colors.metal-edge}` at ~55% opacity (default).
- **Internal Padding:** 16px default; instrument tiles 14px; specimen rows 12–14px horizontal.

### Inputs / Fields
- **Style:** Filled translucent white (~55–65% light / ~6–8% dark), 14px radius (search uses 16px), metal-edge border.
- **Focus:** Purple-secondary 1.5px outline.
- **Search:** Magnifier prefix, clear suffix when non-empty.

### Navigation
- **Bottom NavigationBar (M3):** Glass fill (light) or indigo ~92% (dark); purple indicator at ~28% alpha; labelMedium w600.
- **App bar:** Transparent, left-aligned bold title, zero elevation.
- **FAB:** Case indigo, on-dark icon, 16px radius, elevation 4 — Books “tend stock” control.

### Signal Lamp (signature)
- **Style:** 10px circle; green / amber / red only; white rim (~55%); soft color glow.
- **Placement:** Leading edge of instrument tiles (when statused) and specimen labels.

### Glass Pane / Specimen Label (signature)
- **Instrument tile:** Icon (purple, 18px) + optional lamp + large value + muted label.
- **Specimen label:** Lamp + title + category · copies; Books rows add edit/delete — delete tinted signal-red. No leading icon plaque on book specimens.

### Case Shelf Rail (signature)
- **Style:** 3px-tall metal gradient ledge under “Recently added,” inset 20px horizontally.

## Do's and Don'ts

### Do:
- **Do** build content on frosted panes with metal edges over the gallery gradient.
- **Do** reserve green / amber / red for signal lamps (and red for destructive affordances).
- **Do** use Poppins with Material roles: bold app titles, heavy instrument values, muted specimen metadata.
- **Do** keep M3 patterns for nav, FAB, dialogs, and snackbars while expressing brand through case glass.

### Don't:
- **Don't** turn the shell into generic purple glass CRUD — indigo case light and specimen labels lead.
- **Don't** use status colors as section accents, chips, or brand fills.
- **Don't** put icon plaques on book specimen rows (lamps + typography only).
- **Don't** rely on heavy resting shadows or opaque white cards instead of frosted panes.
