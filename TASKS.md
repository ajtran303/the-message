# The Message — Trello Board Breakdown

## Week 1 — Vertical Slice

[x] 1. Project setup
Init LÖVE project, folder structure, main.lua, conf.lua.

[x] 2. Game state manager
String-based state variable, update/draw branching for all 4 states (walking, campfire, transition, center).

[x] 3. Player movement
Rectangle player, right fast (~100px/sec), left slow (~50px/sec), basic input handling.

[x] 4. Camera system
Camera follows player horizontally.

[x] 5. Campfire placement
Place 2 test campfires at fixed positions, proximity detection.

[x] 6. Walking → campfire state transition
Movement stops, campfire state activates on proximity.

[x] 7. Symbol data structure
Campfire table with pre-authored symbol sets, progress table with shader params.

[x] 8. Symbol display
Render symbols as horizontal row centered on screen. Placeholder art ok.

[x] 9. Swap interaction
Click to select, click to swap, visual highlight on selected symbol.

[x] 10. Confirm and transition
Enter key locks arrangement, writes shader param, enters transition state.

[x] 11. Transition → walking
Brief timer, resume movement, advance campfire index.

[x] 12. Basic uber-shader
Canvas rendering pipeline, one shader with hue shift uniform.

[x] 13. Symbol → shader mapping
First symbol index / total = float, feed to shader uniform.

[x] 14. End-to-end test
Walk → campfire → arrange → shader applies → next campfire. Verify full loop works.

---

## Week 2 — Complete

[x] 15. Expand to 5 campfires
Fibonacci spacing (1, 1, 2, 3, 5), all 5 symbol sets defined.

[x] 16. Add vignette effect
Second uniform in uber-shader. Darken screen edges.

[x] 17. Add saturation drain
Third uniform. Pull toward grayscale.

[x] 18. Add chromatic aberration
Fourth uniform. Split RGB channels.

[x] 19. Add screen wobble
Fifth uniform. Sine-based position offset.

[x] 20. Shader stacking tuning
Test all 5 effects together, adjust intensity curves, ensure screen stays readable.

[x] 21. Background spikes
Visual only, no collision. Increasing density toward center.

[x] 22. Campfire dimming
Progressive darkness on later campfires.

[x] 23. Symbol art
Create or source 20-25 occult/mystical icons.

[x] 24. Center ending — visual
Screen fades to black after campfire 5. All inputs dead.

[x] 25. Center ending — audio
Heartbeat loop, Geiger counter loop, three-phase crossfade (heartbeat only → overlap → heartbeat fades to quiet, Geiger alone).

[x] 26. Player sprite
Replace rectangle with actual art.

[x] 27. Campfire sprite
Replace placeholder with actual art.

[x] 28. UI feedback sounds
Click/swap sound effects for symbol interaction.

[] 29. Pacing pass
Tune movement speeds, Fibonacci spacing base unit, transition timing. Target 5-10 minute playthrough.

[x] 30. Final playthrough test
Full 5-campfire run. Verify pacing, shader stacking, center ending, overall feel.

---

## Backlog / Nice-to-Have

[x] 31. Randomized symbol assignment
Shuffle symbol pool and deal per playthrough instead of pre-authored sets.

[] 32. Ambient background audio
Optional background tone during walking segments.

[] 33. Expand to 9 campfires
Restore full Sandia warning structure if time allows.

[] 34. Additional shader effects
Scanlines, pixelation, glitch effects as extra shader uniforms.

[] 35. Environmental detail polish
Additional visual elements, particle effects, environmental storytelling details.
