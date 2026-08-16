---
name: use-superellipse-radius
description: >-
  Applies VNCoughAlert iOS-style continuous corners via AppRadius.superellipse
  (RoundedSuperellipseBorder) on sheets, cards, bubbles, and floating panels.
  Use when adding border radius, RoundedRectangleBorder, ClipRRect, sheet/card
  corners, superellipse, squircles, or ellipsis border radius.
---

# Use superellipse radius

## When

Rounding a **sheet, card, bubble, or floating panel** (including the chat card over the sidebar).

Pills stay `BorderRadius.circular(AppRadius.pill)` (search chip, upgrade pill, voice button).

## Steps

1. Import tokens from `package:vncoughalert/design_system/`.
2. Pick a size token: `AppRadius.bubble` (sheets/bubbles) or `AppRadius.control` (smaller tiles).
3. Shape with `AppRadius.superellipse(radius)` — never `RoundedRectangleBorder` / `BorderRadius.circular` for these surfaces.
4. Clip children with `ClipPath(clipper: ShapeBorderClipper(shape: shape))` or `Material(shape: shape, clipBehavior: Clip.antiAlias)`.

## Material

```dart
Material(
  color: AppColor.canvas,
  shape: AppRadius.superellipse(AppRadius.bubble),
  clipBehavior: Clip.antiAlias,
  child: child,
)
```

## DecoratedBox + shadow

```dart
final shape = AppRadius.superellipse(AppRadius.bubble);
DecoratedBox(
  decoration: ShapeDecoration(
    color: AppColor.canvas,
    shape: shape,
    shadows: [
      BoxShadow(
        color: AppColor.textHigh.withValues(alpha: 0.18),
        blurRadius: 24,
      ),
    ],
  ),
  child: ClipPath(
    clipper: ShapeBorderClipper(shape: shape),
    child: child,
  ),
)
```
