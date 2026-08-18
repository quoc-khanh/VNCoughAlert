# VNCoughAlert

Flutter chat app for respiratory symptom tracking and guidance.

## Quick preview on iPhone

If you want to inspect the UI on your iPhone without making an APK:

1. Run the app in web mode on your dev machine.
2. Open the shown local URL from Safari on the iPhone.
3. If needed, add the page to the home screen for a more app-like view.

Typical commands:

```bash
flutter pub get
flutter run -d chrome
```

If you need to expose it to your phone over the local network:

```bash
./tool/run_web_local.sh
```

Then open `http://<your-computer-lan-ip>:8080` on the iPhone.

The app uses **flutter_riverpod** and **zenrouter**. Every message in a chat uses the Mistral API:

| Mode | Backend | API key |
|------|---------|---------|
| **Chat** | Mistral Small 4 (`mistral-small-2603`) | Required |

Text and voice messages are sent through the same chat history. Voice messages are currently represented
as a text placeholder until audio transcription is connected.

## Contest demo flow

1. Tap **Bắt đầu sàng lọc AI**. The assistant asks for age, medical history and current symptoms.
2. Use the microphone. Recording displays a live waveform and stops/submits automatically at 5 seconds.
3. If the sound level is unusually high, the app asks the user to record again in a quieter place.
4. Continue the conversation for safety guidance, warning signs, recommendations and medical sources.
5. Open **Quyền riêng tư** to show the consent and anonymized audio-processing notice.

The app does not fabricate diagnosis cards or case-study results. The LLM must clearly label its output as
reference-only and state when audio analysis is not available.

## Run with Mistral

Get an API key from [Mistral AI](https://console.mistral.ai/), then:

```sh
flutter run --dart-define=MISTRAL_API_KEY=your_key_here
```

The key is compile-time only (`String.fromEnvironment`). Do not commit it. This client-side key is for local/dev prototype use.

Without `MISTRAL_API_KEY`, assistant bubbles show an error instead of crashing.
