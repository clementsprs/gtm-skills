# Review and QA

Every take is reviewed before it enters the edit, and every master is checked before it is
delivered. Log every verdict with the task ID so no one pays for the same judgement twice.

## 1. Contact sheet (every take)

```bash
scripts/contact-sheet.sh take.mp4            # 1 fps, 5x2 grid → take.sheet.png
scripts/contact-sheet.sh take.mp4 4 6x4      # 4 fps face scrub for speaking takes
```

Look at the sheet, not the video at full speed: drift and morphs hide in motion.

## 2. Reject criteria (any one is a reject or a cut)

**Identity and continuity**
- Face changes (jaw, nose, eye shape, age) within the take or vs. the locked still
- Hair, outfit, accessories change between shots
- Set changes: furniture, window side, wall colour, props appear or vanish
- Light direction flips between consecutive shots

**Bodies and physics**
- Extra or missing fingers, merged hands, a third arm
- An extra person enters, a background figure duplicates, ghosting
- Props slide, crawl, rotate, morph or melt
- Liquids, paper, cables behaving wrongly

**Direction**
- Someone looks at the lens who shouldn't (scrub the face at 4 fps)
- Eyeline doesn't meet the other character
- The predictable wrong action happened (stood up, opened the laptop, walked out)
- The end pose isn't stable when the take must chain

**Text and marks**
- Any readable generated text, gibberish UI, garbled logo, stray third-party brand

**Audio**
- Mispronounced words, dropped phrases, gibberish in silent takes
- Voice of a recurring character differs from their other takes
- Sudden room-tone or level jumps

## 3. Transcribe every spoken take

```bash
# whisper.cpp example; any Whisper-class model works
whisper-cli -m ggml-large-v3-turbo.bin -f take.wav -ojf        # word-level JSON
whisper-cli -m ggml-large-v3-turbo.bin -f take.wav --prompt "$(cat script.txt)"
```

Compare to the script. Transcription often misspells correct brand names: listen before you
reshoot. For non-native-language takes, run plain and prompted; errors in both are real.

## 4. Fix ladder (cheapest first)

1. **Cut around it.** Trim the bad second, use another take, cover with an insert or a
   reaction.
2. **Fix in the edit.** Punch-in to crop a stray hand or logo, slow to 0.75-0.8x to keep a
   logo in frame, paint out a flat prop's printed text (colour mask, refill, 2px rim), cover
   with a composited element.
3. **Edit the clip** (video-to-video) for one change: object, outfit, background. Not for
   eyelines or faces.
4. **Re-roll** the same prompt once.
5. **Rewrite** the prompt, one variable at a time.
6. **Rebuild the still** and re-animate.

## 5. Master QA (every deliverable)

```bash
ffprobe -v error -show_entries stream=codec_name,width,height,pix_fmt,color_space,color_primaries,color_transfer,r_frame_rate -show_entries format=duration out.mp4
ffmpeg -i out.mp4 -af ebur128=peak=true -f null - 2>&1 | tail -12      # integrated LUFS, true peak
ffmpeg -i out.mp4 -vf cropdetect -f null - 2>&1 | tail -3             # no unexpected black bars
```

Check:
- [ ] Duration matches the plan; frame 0 is a complete readable frame
- [ ] Colour tags bt709 / tv range, pix_fmt yuv420p
- [ ] Loudness on target (-14 LUFS social, -16 web), true peak ≤ -1 dBTP
- [ ] Captions present, in safe zones, each ≥ the reading minimum, brand words spelled right
      (re-transcribe the master)
- [ ] No black bars, no last-frame flash, audio doesn't cut on the final frame
- [ ] Watch it once on a phone, sound off, then sound on

## 6. Review cut before finals

Send a review cut (≤1080p, a link playable on a phone) and wait for approval. Render 4K or
all the ratio/language variants only after approval. Every correction from the review goes
into the project doc and, if it's a general rule, into this skill.
