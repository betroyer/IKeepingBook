# Surface brief: Home (app shell)

Mode: Operate
Primary target: lib/screens/home/home_screen.dart
Related: lib/main.dart, lib/screens/books/, lib/theme/

## Audience / job
Phone-side offline library inventory. Glance vitals, then add/find/edit books.

## Direction contract

THESIS: The library is a lit rare-book glass case — frosted panes and labeled specimens — not a generic purple glass CRUD shell.

OWN-WORLD: Cool indigo gallery light (#1A2744 → #E8EEF8), soft purple secondary (#5B4B8A), frosted translucent panes with thin metal edges, specimen label cards; Material 3 navigation/FAB/dialogs; status only as green/amber/red signal lamps.

STORY: User opens the case, reads four library vitals, sees recent specimens on a glass shelf, taps Books or FAB to tend stock.

FIRST VIEWPORT: Top app bar “I-Keeping Books”; 2×2 glass instrument tiles (total books, copies, categories, low stock); glass shelf of recently added labeled books; bottom nav Home/Books/Categories/More. Primary Add is the Books FAB (or Quick Add on Home).

FORM: Rare-Book Glass Case (grounded list position 7; seed key f7470783). Signature interaction: shared-axis / pane-slide when opening Add or Edit — the case pane yields to the form.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
