# Prompt library (shipped prompts, generalized)

Every prompt here produced footage that shipped in a real ad or film. Brand and product names
are replaced with placeholders in `[brackets]`. They are model-agnostic: reuse them on
whatever model `models-and-costs.md` picks. Adapt the subject and the line; keep the
structure and the realism vocabulary.

## Stills

### Street host, 9:16 (the version that fixed "not realistic enough")
> Unretouched frame grab from a real New York street segment filmed handheld on a Sony FX3,
> vertical 9:16, eye level, framed from the waist up, subject slightly off-center. An ordinary
> American man around 32, short dark hair slightly messy, light stubble, warm brown skin with
> visible pores, friendly but not polished. Wearing a navy hoodie under an unzipped tan canvas
> jacket. He holds a black handheld interview mic with a foam windscreen a bit below his chin
> and looks straight into the lens like a casual street-content host, mid-word with a
> half-smile. Background: a Manhattan sidewalk with brownstones and a coffee cart, pedestrians
> and a yellow cab out of focus. Flat overcast autumn daylight, slight sensor noise,
> documentary color grading. Not a model, not posed, not glamorous. No text, no logos.

Variant imperfections for a woman host: "dark curly hair with frizz and flyaway strands blown
by the wind, light olive skin with visible pores, faint under-eye shadows, a small mole on her
cheek, natural uneven skin tone, no makeup look, slightly chapped lips, mild motion blur on
hands".

### Video-call participant (webcam), 16:9
> Webcam view of a video call participant: a man in his late 20s, account executive at a
> startup, sitting in a small office phone booth with acoustic felt panels behind him, wearing
> a grey hoodie, listening attentively and nodding with a slight smile, looking at his screen
> not into the lens. Realistic laptop webcam framing at eye level, warm practical light,
> natural skin texture, candid documentary look, subtle webcam grain. Full-frame feed, no
> device. No headset, no text, no logos, no UI overlays.

### Team scene with a real logo in the set
Pass the logo PNG as a reference tagged `logo`.
> Candid photo of a small startup team mid-discussion around a standing desk, three people
> in their late 20s and 30s in sweaters and sneakers, one pointing at a laptop turned away from
> camera. On the raw concrete wall behind them the exact @logo is hand-painted large, slightly
> imperfect, partly hidden behind people. Shot on 35mm, handheld, natural mixed light, slight
> grain, muted realistic colours, imperfect framing. No call-center headsets, no suits, no
> stock-photo smiles.

### Fix-up edit: remove a fake film-strip border and extend the frame
Reference the bad still as `shot`.
> @shot as a clean full-frame cinematic still: remove the black film-strip border and all text,
> and extend the scene naturally to fill the whole 16:9 frame edge to edge. Keep the person,
> face, expression, clothes, framing and lighting exactly the same. No text, no borders, no
> letterbox.

### New angle from a locked hero still
Reference the hero still as `maya`.
> The same woman as @maya, same face, same curly hair, same rust sweater, now seen in a medium
> two-shot from over the shoulder of a colleague sitting across the table from her (his
> shoulder and the back of his head soft in the left foreground). She looks at him, not at the
> camera. Same meeting room, window light from frame right. Candid documentary, 35mm, grain.
> No text, no logos.

## Takes, silent b-roll (for the edit)

### People tile, text-to-video, 1:1 480p
> Candid documentary footage shot on 35mm film, handheld, slight natural camera sway. A young
> account executive in a charcoal hoodie sits inside a small glass phone booth in a busy
> startup office, on a video sales call with an open laptop, white earbuds in. He talks and
> gestures naturally mid-sentence, listens, nods, leans back, then answers again. He never
> looks at the camera. Warm practical light, soft film grain, shallow depth of field, a coffee
> cup and sticky notes on the little desk, blurred coworkers passing behind the glass. No text,
> no logos, no readable screen content.

> Candid documentary footage shot on 35mm film, handheld, slight natural camera sway. A manager
> in her thirties, sweater and sneakers, sits sideways on a worn lounge sofa in a startup
> office with a laptop on her knees and wired earphones, listening closely to a recording. She
> pauses it, frowns slightly, scribbles a short note in a paper notebook, presses play again
> and gives a small nod. She never looks at the camera. Late-afternoon window light, soft film
> grain, shallow depth of field, plants and a cluttered side table. No text, no logos, no
> readable screen content.

### Webcam feed, image-to-video, 480p
> Static locked-off laptop webcam shot, the camera never moves. The woman keeps talking
> naturally on a video call, explaining her budget and timeline, small natural hand gestures,
> slight head movements, occasional brief glance down at her notes, lips moving as she speaks,
> relaxed and confident. Background stays still, soft daylight. Realistic, candid, subtle
> webcam grain.

### Seamless hero loop (start frame = end frame)
> Static locked-off webcam shot of this woman on a video call, listening, a small nod, a brief
> smile, a glance down at her notes and back, returning exactly to the starting pose. Candid,
> natural, not posed, no camera movement, no zoom, no cuts, background unchanged.

## Takes with native audio

### Street host talking to camera, 9:16, lip-synced
> Real handheld New York street footage, subtle natural camera shake, no zoom, no cuts. The man
> is a casual street-content host holding the mic below his chin and talking straight into the
> lens to the viewer, counting the three examples on his free hand, then a knowing nod at the
> end. His voice is a regular guy's speaking voice, not a voiceover: natural American accent,
> casual and a bit fast. He says: "Ask it why you lost your last five deals, build a
> battlecard from real buyer quotes, or update the deal for you. Your AI, finally with
> context." Real street audio through a handheld mic: traffic, a car horn far away, people
> walking, light wind. No music. Accurate lip sync, natural blinking.

~25 words in 10s. This is a host addressing the viewer, not a customer testimonial (see
`compliance.md`).

### Story beat with a sound hit to cut on
> The young man in the hoodie strikes the brass gong once with the mallet; the gong shudders
> and rings with a deep resonant boom. The people around him stay perfectly still, heads
> slightly bowed, completely deadpan. Steady light rain, mist drifting. Slow, subtle camera
> push-in on a tripod. Realistic, cinematic, 35mm. Sound: rain on umbrellas, one deep gong
> strike ringing out.

> The young woman swings the mallet and strikes the gong hard right away; it booms. The whole
> team erupts: jumping, cheering, high-fives, someone hugs her, arms in the air. Joyful,
> chaotic, real. Handheld documentary camera with a quick energetic push-in. Realistic, 35mm.
> Sound: loud gong boom, cheering, clapping, laughter.

### Silent reaction for a VO to sit on (nothing to lip-sync)
> Mockumentary confessional. The woman keeps her lips closed and stares into the camera,
> deadpan and tired. She raises one eyebrow slightly, lets out a slow sigh through her nose,
> glances sideways at the scene behind her, then looks back into the camera with a flat,
> knowing expression. She does not speak. Very slow push-in. Realistic, cinematic, 35mm.
> Sound: room tone, distant murmurs, no music, no speech.

### Two-person dialogue, OTS with pinned head (timed beats)
> References: @maya is the start frame.
> 16:9, 8 seconds, one continuous take, handheld 35mm, no cuts.
> Maya talks to her colleague across the table; his shoulder and the back of his head stay
> soft in the left foreground. For the ENTIRE take her head stays turned three-quarters toward
> frame LEFT, eyes on him, exactly like the first frame. She never looks at the camera.
> Candid documentary, 35mm film grain, natural window light.
> Dialogue (Maya): "So I listened to the call again... and they never said no. They said NOT
> YET."
> 0:00-0:02 | Leans in slightly, both forearms on the table.
> 0:02-0:05 | Says the first line, small open-palm gesture with her right hand.
> 0:05-0:08 | Stresses "not yet", raises her eyebrows, settles back into a stable pose. Does NOT
> look at the camera.
> Sound: quiet room tone, faint office murmur through the door. No music. Clean frame, no text
> overlays.
> Total: 8s / 1 take / 16:9

### UGC talking head, timed beats, 9:16
> 9:16, 12 seconds, single take, smartphone front camera, handheld.
> Small office phone booth, felt panels, late-afternoon window light.
> UGC talking head, raw phone footage, candid documentary, talking to camera like a colleague.
> Dialogue: "Okay so... I stopped re-listening to my calls. Like, COMPLETELY."
> 0:00-0:02 | Hook: leans in, forearms on the desk, locked eye contact.
> 0:02-0:06 | Glances at the laptop beside him, screen turned away, back to the lens.
> 0:06-0:10 | Animated gestures, counts two points on his left hand.
> 0:10-0:12 | Landing: small shrug, half-smile, like it should be obvious. Does NOT turn the
> laptop.
> Sound: room tone, faint office murmur, phone-mic voice. No music. Clean frame, no text
> overlays.
> Total: 12s / 1 take / 9:16

## Consistency blocks (append to story takes)

- Open with: `ONE CONTINUOUS TEN-SECOND TAKE, no cuts, no jumps, a single scene, not a montage.`
- `Exactly one person in frame; nobody else enters, no silhouette. Exactly two hands with five
  fingers each. Nothing slides, crawls, floats, morphs or disappears. No text, no graphics, no
  visual effects.`
- Pin props: `The phone lies flat and completely STILL; it must not slide, wriggle, rotate or
  flip; the only thing that changes is its screen lighting up.`

## Music and sound

### Product film bed
> Instrumental, no vocals. Modern tech product launch soundtrack, confident and uplifting, 118
> BPM. Opens with a soft pulsing synth and muted plucks for 4 seconds, then a crisp punchy drum
> groove with tight claps and a deep warm sub bass kicks in. Glassy arpeggiated synths, subtle
> risers building in the middle section, a drop around 28 seconds with bright layered synth
> chords, then a clean resolved ending with a final hit and short tail around 44 seconds.
> Minimal, energetic but not aggressive.

Rules: name the BPM and the second of the drop, then cut on it. Under a voiceover ask for
"even dynamics throughout, no builds, no drops, keep the top end soft and the mids
uncluttered". Describe music only (genre, instruments, BPM, structure); marketing words like
"premium SaaS energy" can trip moderation on some music models.

### Ambience bed
> Outdoor city street ambience recorded on a handheld interview mic, distant traffic, a café
> terrace with cups and murmurs, footsteps, light wind.

Push it forward in the mix under UGC voices so the voice sits outdoors.
