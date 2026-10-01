# New Borrow — multi-book selection

Mode: Operate
Primary: lib/screens/borrow/new_borrow_screen.dart
Related: lib/providers/borrow_provider.dart, lib/services/borrow_service.dart, lib/database/database_helper.dart, lib/services/email_service.dart, lib/screens/borrow/borrow_screen.dart

## Purpose

Librarian records a student loan and selects one or more in-stock books in a single form. Saving creates one borrow line per title, decrements stock per copy, and emails one receipt listing every title.

## Direction contract

THESIS: New Borrow is a librarian checkout desk — student identity first, then a searchable shelf checklist of what leaves with them; not a one-title dropdown buried in dates.
OWN-WORLD: Cream glass form pane, rosewood primary actions, Material checkboxes and search field, Poppins labels; warm wash from CaseBackground; signal amber only for empty stock.
STORY: Librarian enters the student, ticks every book they take, sets shared borrow/due dates, saves once; each title becomes a trackable loan that returns independently.
FIRST VIEWPORT: App bar “New borrow”; frosted form with Student information; School level segment; Books borrowed heading with live search and scrollable checklist (title + available count); shared dates; filled Save borrow record.
FORM: Multi-checklist (user lock multi-checklist); extension of established Only Hope Library Nook; seed n/a local extension.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
