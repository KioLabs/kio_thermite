# Changelog

## 1.1.0
- The character holds the charge while placing it, then pulls a lighter that shows a flame when the strike catches; the charge and the burn land on the door/gate surface in front of them
- The character plants the charge (Pacific Standard thermal charge animation), a thermite prop goes on the door, and they shield their eyes while the real thermite burn plays; pass `coords`/`heading` to put it on an exact door
- Difficulty presets: easy, normal, hard, vault (pass a name or a table to `Start`)
- Sound effects: lighter strike, fuse hiss, a burn that rises with the heat, win and fail stings (no audio files)
- Every word moved to `config.lua` (`Config.Locale`) for translation
- Theme: accent/good/bad colors, size on screen, background dim
- New exports: `StartAsync(opts, cb)` and `IsOpen()`
- `/thermitetest [preset]` command (admins by default)

## 1.0.0
- First version: place the charges, light the fuse, control the burn
