# VNCoughAlert — agent notes

Flutter chat app (ChatGPT-like UI). Stack: **flutter_riverpod** + **zenrouter** Coordinator. Data is **mock** until a real API exists.

## Design system

- Tokens: `lib/design_system/tokens/` (`AppColor`, `AppTextStyle`, `AppSpace`, `AppRadius`)
- Components: `lib/design_system/components/`
- Theme: `lib/design_system/theme/app_theme.dart`
- Previews: `lib/design_system/preview/ds_previews.dart`

UI must use tokens. New shared widgets → skill **add-ds-component**. New colors → skill **sync-color-tokens**.

## Layout

```
lib/
  design_system/
  router/                 # zenrouter Coordinator, ChatRoute
  features/chat/          # page + providers + mock repository
```

## Official skills

Installed under `.agents/skills/` (`flutter/agent-plugins`, `dart-lang/skills`). Prefer those for tests, layout fixes, widget preview. **Do not** switch routing to go_router.

## MCP

Project `.cursor/mcp.json` runs `dart mcp-server`.
