# VNCoughAlert

Flutter chat app (ChatGPT-like UI) using **flutter_riverpod** and **zenrouter**. Two modes share the same chat screen:

| Mode | How to start | Backend | API key |
|------|----------------|---------|---------|
| **Free chat** | New chat or type a normal message | Mistral Small 4 (`mistral-small-2603`) | Required |
| **Diagnosis demo** | Chip **Chẩn đoán mới** | Scripted intake → 5s cough record → mock result cards | Not required |

After a demo diagnosis finishes, follow-up messages in that session go to Mistral.

## Run with Mistral

Get an API key from [Mistral AI](https://console.mistral.ai/), then:

```sh
flutter run --dart-define=MISTRAL_API_KEY=your_key_here
```

The key is compile-time only (`String.fromEnvironment`). Do not commit it. This client-side key is for local/dev prototype use.

Without `MISTRAL_API_KEY`, free-chat assistant bubbles show an error instead of crashing. The **Chẩn đoán mới** demo still works.

## Diagnosis demo (~90s video)

1. Open the app and tap **Chẩn đoán mới**.
2. Paste: `45 tuổi, tiền sử hen suyễn, đang ho có đờm 2 tuần, khó thở, tức ngực, sốt nhẹ`
3. Tap the mic and wait 5 seconds (auto-submit in this phase).
4. Wait for analyzing, then mock cards (Viêm phế quản / Hen suyễn ~80%).
5. Tap **Xem case study** or **Kết nối bác sĩ**.

Demo-only chips **Xu hướng** and **Báo cáo** show a placeholder snackbar.
