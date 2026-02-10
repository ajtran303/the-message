# The Message

## Overview

The Message is a short narrative game built with LOVE 2D (Lua). It's inspired by a 1993 report from Sandia National Laboratories about how to warn future civilizations about buried nuclear waste. The problem the report tackled was: how do you tell people thousands of years from now that a place is dangerous, when they might not speak your language or recognize your symbols? This game turns that idea into something you can play.

You walk to the right through a mostly empty landscape. Along the way, you find five campfires. At each one, the game shows you a row of strange symbols and lets you rearrange them by clicking. There's no explanation of what the symbols mean or what the "right" order is. After you confirm your arrangement, a new visual effect gets added to the screen. Colors start shifting. The edges of the screen get darker. Color drains out. The image starts splitting apart. The whole screen begins to wobble. By the time you reach the fifth campfire, the world looks broken. Past the last campfire, the screen fades to black. You hear a heartbeat, then a Geiger counter. Then the heartbeat fades away and only the Geiger counter remains. The game stays like that forever. You have to close it yourself.

The main idea behind the game is "go right, but it's wrong." Moving right feels fast and easy. Moving left is slow and heavy. But you can't actually escape by going left. It just delays you. The center is the only ending.

## How to Play

- **Arrow keys / A, D**: Move right (fast) or left (slow)
- **Mouse click**: Select and swap symbols at campfires
- **Enter**: Confirm your symbol arrangement, or start the game from the title screen
- **Esc**: Go back to the title screen at any point

## File Structure

The game code is in `game/src/`, assets are in `game/assets/`, and build tools are in `tools/`.

### Source Files

**`main.lua`** is where the game starts. It sets up all the other systems, keeps track of the camera position, draws the world in the right order (sky, ground, spikes, campfires, player, then UI on top), and passes input events to whatever state is currently active. It also handles resetting everything when you go back to the title screen.

**`states.lua`** is a simple state machine. The game has five states: `start` (title screen), `walking` (moving around), `campfire` (arranging symbols), `transition` (brief pause after confirming), and `center` (the ending). Each state has its own update, draw, and input functions. When the game switches states, it just starts calling a different set of functions. I used this instead of a class-based approach because there are only five states and none of them share behavior, so a lookup table is simpler and easier to follow.

**`player.lua`** controls the player character and draws it. Instead of a sprite image, the player is a stick figure drawn with lines and circles. It has a head, body, arms, and legs that swing back and forth when you walk. The animation speed matches your movement: faster when going right, slower when going left. When you stop, the figure stands still.

**`campfires.lua`** places the five campfires and handles everything about them. They're spaced using the Fibonacci sequence (1, 1, 2, 3, 5 times a base distance), so the first two are close together but the gaps get bigger as you go. Each campfire is drawn as an animated flame with three layers that flicker at different speeds, plus little ember particles that float upward. After you visit a campfire, it turns into a pile of charred logs and ash. Later campfires are also drawn dimmer than earlier ones to make the world feel like it's getting darker.

**`symbols.lua`** manages the symbol data. There are 20 symbols total, and at the start of each playthrough they get shuffled randomly and dealt out to the five campfires (3, 3, 4, 4, and 5 symbols each). This means you see different symbols in different positions every time you play. The click-to-swap logic is here too: click one symbol to highlight it, click another to swap them, or click the same one again to deselect it. When you press Enter, the position of the first symbol in the row gets converted into a number between 0 and 1, and that number controls how strong the shader effect is for that campfire.

**`glyphs.lua`** draws the 20 symbols. Each one is a small icon made entirely from basic shapes like lines, circles, arcs, and polygons. They include things like a pentagram, concentric circles, an eye shape, a spiral, an ankh, a crescent, a hexagon, an hourglass, and a trident. I drew them procedurally in code instead of using image files so the project doesn't need any external art assets. This file also handles the layout of the symbol slots on screen and figuring out which slot you clicked on.

**`postfx.lua`** handles the visual effects pipeline. Every frame, the game draws the world onto a hidden canvas first, then runs a shader over that canvas to apply all the distortion effects, and finally draws the result to the screen. This way all five effects (color shift, darkening, desaturation, channel splitting, wobble) can be applied in a single step.

**`audio.lua`** creates all the game's sounds using math instead of audio files. The heartbeat sound is made from low-frequency sine waves shaped into two quick thumps. The Geiger counter is random bursts of noise. Footsteps are short crunchy sounds with slightly different pitch each time. The UI click is a quick tone. During the ending sequence, the heartbeat plays alone for about 6 seconds, then the Geiger counter slowly fades in over about 14 seconds, and then the heartbeat gradually gets quieter until only the Geiger counter is left.

**`spikes.lua`** creates the background scenery. Dark triangular spikes stick up from the ground, and they get taller, denser, and more visible the further right you go. Near the start of the game you can barely see them, but by the end they fill up most of the background. Each spike is placed with a little bit of random offset so they don't look too uniform.

**`environment.lua`** adds atmospheric detail to the world. It manages four effects: stars in the sky that twinkle and gradually fade out as you visit campfires, dust particles that drift across the screen and get thicker as you progress, a warm orange ground glow beneath each unvisited campfire, and cracks in the ground that appear in the later part of the world and get denser toward the center. All four effects reinforce the feeling that the world is getting worse the further right you go. By the ending, the sky is empty and the ground is fractured.

### Shader

**`assets/shaders/uber.glsl`** is a single shader file that handles all five visual effects. It takes in six numbers (one for each effect plus a time value for animation) and applies them all in one pass. The effects are: rotating the hue of every pixel, darkening the edges of the screen, pulling colors toward gray, splitting the red/green/blue channels apart, and wobbling the whole image with a wave pattern. Once an effect is turned on, it never turns off. By the end of the game, all five are stacked on top of each other.

## Design Decisions

**Fibonacci spacing for campfires** (1, 1, 2, 3, 5 times a base distance) means the first couple of campfires come quickly, which makes you feel like you're making progress. Then the gaps get longer, which builds tension and gives each new shader effect time to settle in before the next one hits.

**Everything is procedural.** The symbols, sounds, player character, and campfire animations are all generated in code. There are no image files or audio files in the project. This keeps the project simple to manage and means there are no external assets to worry about. The slightly rough quality of code-drawn art also fits the game's minimal style.

**Swap instead of drag-and-drop** for symbol interaction. Clicking to select and clicking again to swap is straightforward and hard to mess up. Drag-and-drop would have been harder to build and easier for players to fumble with.

**One shader instead of multiple passes.** All five visual effects run in a single shader applied once per frame. This is simpler than chaining multiple shaders together. The tradeoff is that the effects can't build on each other's output individually, but in practice the stacking looks fine for this game.

## Running

Requires [LOVE 2D](https://love2d.org/) 11.4+:

```bash
cd game
love .
```

## Building

Requires [Makelove](https://github.com/pfirsich/makelove) and Node.js:

```bash
cd tools
npm run Build
```

Outputs to `builds/` for Windows (32/64-bit), macOS, and web (lovejs).

## Credits

Game design, architecture, and creative decisions by Jamie "AJ" Tran.

AI tools used in development: Claude (Anthropic) for design planning, specifications, and code generation.

## License

MIT
