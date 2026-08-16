---
name: sync-color-tokens
description: >-
  Adds or updates VNCoughAlert semantic color tokens in
  lib/design_system/tokens/app_color.dart (surface, text, icon, accent, message,
  border). Use when the user asks for a new color, sync tokens, sync-color-tokens,
  or a widget needs a color that does not exist yet. Do not hardcode Color(0x…)
  in features.
---

# Sync color tokens

## When

Need a new semantic color, rename a token, or map a screenshot/Figma value into the DS.

## Rules

- Edit **only** `lib/design_system/tokens/app_color.dart` (and `app_theme.dart` if `ColorScheme` mapping must change).
- Keep a **flat** API: `AppColor.canvas`, `AppColor.textHigh` — no nested `AppColor.text.high`.
- Groups: surface, text, icon, accent, message, border.
- If the user did not specify a hex, **ask** before inventing a token.
- After adding a getter, use it at call sites. Do not leave `Color(0x…)` in `lib/features/` or `lib/design_system/components/`.
- Light is source of truth. Dark theme stays a skeleton unless the user asks to fill it.

## Hex lives only in `app_color.dart`

```dart
static const Color canvas = Color(0xFFFFFFFF);
```
