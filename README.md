# The Message

A short experimental narrative game built with LOVE 2D. Inspired by the Sandia National Laboratories 1993 nuclear waste warning message.

Walk right through a decaying landscape. Arrange unknown symbols at campfires. Watch the world distort around you. Reach the center.

**Runtime:** 5-10 minutes
**Engine:** LOVE 2D (Lua)

## How to Play

**Arrow keys / A,D** - Move (right is fast, left is slow)
**Mouse click** - Select and swap symbols at campfires
**Enter** - Confirm symbol arrangement / Start game
**Esc** - Return to title screen

## Running

Requires [LOVE 2D](https://love2d.org/) 11.4+

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

Builds to `builds/` for Windows (32/64), macOS, and web (lovejs).

## Credits

Game design, architecture, and creative decisions by Jamie "AJ" Tran.

AI tools used in development: Claude (Anthropic) for design planning, specifications, and code generation.

## License

MIT
