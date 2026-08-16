---
name: add-ds-component
description: >-
  Adds a shared VNCoughAlert design-system Flutter widget under
  lib/design_system/components/, wired to AppColor/AppTextStyle/AppSpace/AppRadius
  and registered in Widget Preview. Use when creating or updating a reusable UI
  component, catalog widget, button, input, bubble, sidebar item, or when the
  user says add-ds-component / thêm component design system.
---

# Add design-system component

## When

Any **shared** UI widget (used by more than one screen, or clearly a DS primitive). Feature-only one-off layout stays in `lib/features/{feature}/`.

## Steps

1. Confirm tokens exist. Missing color/type/space/radius → use skill `sync-color-tokens` (or ask the user). **Never** `Color(0x…)` in the component.
2. Create `lib/design_system/components/ds_{name}.dart` (`snake_case` file, `Ds{Name}` class).
3. Public API: named params, `const` constructor when possible, `VoidCallback?` for actions.
4. Export from `lib/design_system/design_system.dart`.
5. Add `@Preview` functions in `lib/design_system/preview/ds_previews.dart` (group `Design System`): idle, disabled, and key variants (e.g. user vs assistant bubble). Wrap with `AppTheme.light` via existing preview helpers.
6. Feature screens **import the DS widget**; do not duplicate the layout.

## Preview import

```dart
import 'package:flutter/widget_previews.dart';
```
