# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Stack

Flutter + Dart; SQLite via sqflite; Provider for state management; Material 3. Confirmed from the attached complete app plan and the init choice "Build the plan as written."

## Users

People who want to keep a personal or small-collection book inventory on their phone without an account or internet connection. Primary job: add, find, update, and remove book records, and see stock at a glance.

## Product Purpose

I-Keeping Books is an offline mobile app for digitally managing a book collection. Success means a user can maintain accurate name, quantity, and category records on device, search and sort them quickly, and understand library health (totals, low stock, recent adds) without leaving the phone or needing a network.

## Positioning

A personal digital library for book inventory — not a reading app, storefront, or cloud sync service. All data stays in a local SQLite database. The product differentiator called out in the brief is a Glassmorphism Digital Library interface over simple offline CRUD.

## Operating Context

Used on Android phones, fully offline. Typical ritual: open app → glance at dashboard stats → search or browse books → add or edit a title → confirm deletes. Categories are fixed to five library buckets from the plan. Low stock is quantity ≤ 5.

## Capabilities and Constraints

Confirmed:
- CRUD for books (name, quantity, category, created/updated timestamps)
- Search by book name (case-insensitive, live)
- Sort: A–Z, Z–A, highest/lowest quantity, recently added
- Categories: Textbooks, Fiction Books, Reference Books, Science Books, Technology Books
- Dashboard: total books, total copies, category count, low-stock count, recently added, quick add
- Bottom navigation: Home, Books, Categories, More (Settings / About)
- FAB on Books to add
- Empty states, validation, delete and clear-all confirmations, SnackBar feedback
- Dark mode toggle in Settings
- Local Log in / Sign up (accounts stored on device in SQLite; session via SharedPreferences)
- Log out from More
- Student borrow records: full name, student ID, college (course & year) or high school (strand & year), borrow date, return due date; mark returned; stock decreases/increases with loan/return
- No internet requirement

Undecided / out of scope for v1:
- Custom user-defined categories beyond the five
- Cover images, ISBNs, authors, lending fines/penalties beyond due-date overdue flag
- Cloud backup, multi-device sync, or remote authentication
- iOS shipping (Android-first per plan; not selected in init)

## Brand Commitments

- Name: **I-Keeping Books**
- Visual direction from the plan (binding): Glassmorphism Digital Library — soft gradient backgrounds, translucent glass cards, blur, thin borders, rounded corners, subtle shadows
- Color direction from the plan: deep blue/indigo primary, soft purple secondary, light blue/purple gradient background, dark navy primary text, gray secondary; green normal / amber low-stock / red error
- Typography direction from the plan: Poppins or Inter; Material type roles preferred for Android
- Feel: small personal digital library, not a bare CRUD admin tool

## Evidence on Hand

- Source brief: `c:\Users\Admin\Downloads\I-Keeping_Complete_App_Plan.docx` (extracted working copy: `.impeccable-plan-extract.txt`)
- No real user library data, logos, or marketing assets provided — demo/synthetic book records are allowed and must be labeled as sample where a user could mistake them for real inventory

## Product Principles

1. Offline-first reliability: every core action works with no network and persists across relaunch.
2. Library clarity over database chrome: stats, categories, and stock status should feel like tending a collection.
3. Safe destructive actions: delete and clear-all always confirm.
4. Fast find: search and sort belong on the books surface, not buried.
5. Material Android trust: navigation, back, FAB, dialogs, and snackbars follow Material 3 patterns while brand expresses through glass theming.
