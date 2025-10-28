[![release](https://release-badges-generator.vercel.app/api/releases.svg?user=ukuroks-games&repo=2d-adventure&gradient=4259f7,8bfaec)](https://github.com/Ukuroks-games/2d-adventure/releases/latest)
[![Tests](https://github.com/Ukuroks-games/2d-adventure/actions/workflows/tests.yaml/badge.svg)](https://github.com/Ukuroks-games/2d-adventure/actions/workflows/tests.yaml)
[![Lint](https://github.com/Ukuroks-games/2d-adventure/actions/workflows/Lint.yaml/badge.svg)](https://github.com/Ukuroks-games/2d-adventure/actions/workflows/Lint.yaml)
[![Docs](https://github.com/Ukuroks-games/2d-adventure/actions/workflows/publish-docs.yaml/badge.svg)](https://ukuroks-games.github.io/2d-adventure/)

# 2d Adventure

This is "Engine" for creating 2d isometric game in roblox. Not platformer(may be added later).

It provide 2d objects, physic, audio, player controls(keyboard, gamepad and touchpad), animations.

It can create game on any surfaces, just provide `GuiObject` as surface for game. 



[demo](https://www.roblox.com/games/81880122162557/2d-Adventure-demo)

## Get it

You can get [wally](https://github.com/upliftgames/wally) package.
```toml
adventure2d = "egor00f/2d-adventure@version"
```

Or download `rbxm` file from [releases](https://github.com/Ukuroks-games/2d-adventure/releases). `rbxm` version contain all depends.

## Docs
You can read more in the [docs](https://ukuroks-games.github.io/2d-adventure/).

### Build docs

needed installed [`npm`](https://nodejs.org) and `make`

```sh
make docs
```

It automatically installing [`monnwave`](https://github.com/evaera/moonwave) if it not been installed yet and put html docs to `build` directory.

## Contribution

Just crate pull request apt explain what you done and why. It might be accepted. 


## Versions

Versioning tends to be as follows:

`A.B.C` versions

`A` — Major changes. Possible compatibility with previous versions.

`B` — Minor changes. Possibly a new feature. Might need to change function calls/arguments slightly.

`C` — Minor changes/bug fixes.

