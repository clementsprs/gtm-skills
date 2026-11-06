# Dialogue, voice, lip sync

## Decide who speaks, and how, before choosing a model

| Who | Voice source | Why |
|---|---|---|
| Character on screen, mouth visible, English (or a language the model handles well) | **native audio of the take** | dubbing a visible mouth with TTS is instantly uncanny; reviewers reject it |
| Character on screen, language the model mispronounces | TTS in that language + lip-sync model on the approved silent or native take | native speech garbles names, numbers, loanwords |
| Narrator never on screen | TTS | full control, easy retiming |
| Character heard but not seen (back turned, off-screen) | their main voice: instant clone from their clearest native take + speech-to-speech on the line | keeps the voice consistent across takes |
| Nobody (silent b-roll) | audio off | silent takes with "voices" in the prompt invent gibberish |

## Writing lines for native audio

- `Dialogue: "..."` label; two speakers: `Host: "..." / Guest: "..."`.
- **Write it spoken:** fillers ("okay so..."), ellipses for pauses, CAPS on the stressed word
  ("for ONE call").
- **Word budget:** ≤3 words per second. 10s ≈ 25-30 words, 12s ≤ 38, 15s ≤ 45. Above that,
  models either rush the lip sync or silently drop a phrase.
- **Key phrase early.** If anything gets dropped, it's the end.
- Anchor gestures to words in the timed beats (`on "NOT YET", raises eyebrows`).
- Describe the voice as a person, not a voiceover: "a regular guy's speaking voice, natural
  American accent, casual and a bit fast, not a voiceover".
- Describe the room in the sound line: "phone-mic voice, room tone", "handheld mic outdoors,
  traffic, light wind".
- Brand names: spell them phonetically if the model mangles them, and check the transcript.
  Transcription often misspells a correctly spoken brand name; listen before reshooting.

## Voice consistency across takes

Each take invents a new voice for the same character. Before the edit:
1. Listen to every recurring character across all their takes back to back.
2. If one take drifts and the mouth is visible: pick another take or cut around the line.
3. If the line is off-screen or the face is turned: clone the character's voice from the
   clearest take and run speech-to-speech on the drifting line (keeps timing and delivery).
4. Never apply this to a visible mouth.

## Non-English dialogue pipeline (when native speech fails)

Proven for French; applies to any language the model mispronounces.

1. Write lines in plain native vocabulary. Replace every anglicism and jargon loanword with a
   native word ("onboarder" → "former", "coacher" → "accompagner", "call" → "appel"). Prefer
   long words over short numerals ("un", "deux" blur).
2. Generate the take with the native-language prompt anyway; if the picture is right and the
   speech is wrong, keep the picture.
3. Audition 2-3 warm, natural TTS voices on line 1 only; the owner picks one before anything
   else is generated.
4. TTS each line from the corrected script, phonetic spellings for brand names and acronyms
   ("C.R.M.").
5. Lip-sync the TTS onto the approved take with a dedicated lip-sync model (a few dollars per
   ad, minutes per clip).
6. EQ so it sounds like the room: cut 250-1,000 Hz boxiness, small presence lift around
   2.5-3 kHz, no high cut. Lay an ambience bed underneath.
7. QA: transcribe twice, plain then with the script as the prompt. An error that survives the
   prompted pass is real.

## Narration (TTS)

- Ad VO is energetic and specific, never a calm monotone narrator. Generate 2-3 samples with
  different voices/settings; the owner picks before the render.
- Product film narration: steady, warm, slightly faster than default.
- Settings that worked as a starting point on ElevenLabs-class models: stability ~0.35,
  style 0.35-0.55, similarity ~0.8, speaker boost on, speed 1.0-1.12 for ads.
- Every VO line ≤ ~2/3 of its beat slot. Measure the generated clip durations; don't
  estimate. A voice change retimes the whole film.
- Spell URLs for TTS ("example dot com slash demo").

## UGC voices that sound real

- Design or pick voices described as "ordinary person, medium pitch, handheld mic outdoors".
  Studio voices read as "a call box" or "a video-call recording".
- Push a street or office ambience bed forward under the voice.
- A light everyday accent beats a neutral broadcast accent.

## Subtitles aligned to the word

See `post-production.md` → captions. Use word timestamps from a Whisper-class model, never
sentence timestamps, for anything a viewer reads while someone speaks.
