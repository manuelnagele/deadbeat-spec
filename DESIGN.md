# Deadbeat design language

*Draft, 2026-11-22. The rules every module follows on the bar, like a small Human Interface Guidelines. It defines
what can be on the bar, how it looks, how people use and arrange it, and how the bar grows as modules are added.
It replaces the shared fields of spec 1.0; the API that follows from it is spec 2.0 (§9).*

## 1. Principles

1. **Every pixel has an owner.** Everything on the bar belongs to exactly one module, and you can see which. Nothing
   is shared or competed for.
2. **Glance, then go deeper.** The bar shows a number or a state; hover shows the module's details; a click does the
   one obvious thing; right-click opens its settings. Always in that order, always the same.
3. **The player arranges, modules don't.** Modules offer items; the player decides where they sit, and which
   ones show.
4. **Calm by default.** Warm bronze and cream; colour only to mean something (good, warning, bad); motion only when
   something changed.
5. **It grows without getting messy.** A new module adds a group at the end; nothing else moves.

## 2. Anatomy of the bar

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│  [◉] run 0:34 · 3g 12s   ┆   ◆◆◆◆◇   ┆   [◉] 400   ┆   [◉] 34   [◉] 23%   [◉]   ┆  ▦  ⚙ │
└──────────────────────────────────────────────────────────────────────────────────────┘
   └──── Haul group ───┘       Lockout       Catch       └──── Hearth group ────┘    tray gear
```

- **Item:** the smallest unit. One idea, one glance: a value, a state or a launcher.
- **Group:** all items of one module, side by side, separated from the next group by a **divider**.
- **Zones:** left, centre, right (full-width layout); the compact layout has one zone.
- **System items** (always at the right end, not movable): the **tray** (LDB launchers) and the **gear** (settings,
  edit mode).

## 3. Items

### 3.1 Anatomy

```
 ╭──╮
 │◉ │ 34   bags        icon · value · label
 ╰──╯
```

| Part | Rules |
|---|---|
| **Icon** | A WoW icon, 14 px, cropped round with a 1 px bronze ring. Required: it says which item this is when space is short. |
| **Value** | The thing you glance at: a number, a short state, a time. Cream; 12 px (`GameFontHighlightSmall`). Short: aim for ≤ 8 characters, at most 16. |
| **Label** | Optional, warm grey, 11 px, after the value. Off by default; the player can switch labels on per item in edit mode. |
| **State** | `normal` (cream), `good` (soft green), `warn` (gold), `bad` (soft red). Colours the value only, never the icon. Never the only signal: the value itself must say it too ("23%", "no flask"). |

Spacing: 4 px icon → value, 4 px value → label, 12 px between items, 10 px between an item and a divider, 10 px
padding at the bar's ends. Everything vertically centred.

### 3.2 Kinds

| Kind | What it is | Example |
|---|---|---|
| **value** | icon + value (+ label) | bags `34`, durability `23%`, fishing `400` |
| **launcher** | icon only; click opens something | an LDB launcher pinned from the tray |
| **widget** | the module draws a small custom graphic, max 64 × 14 px | Lockout's five diamonds, Haul's run sparkline |

Widgets follow the same colours and size; they are the exception, not the rule.

### 3.3 How many

A module offers as many items as make sense, but **shows at most three by default**. More can exist on the shelf
(§6) for players who want them.

## 4. Groups and dividers

- A module's items always sit together; they never mix with another module's items. That is what makes ownership
  visible.
- Between groups: a 1 × 12 px divider in `bronze2` at 70 %.
- Hovering any item of a group lights the whole group softly (white at 4 %), so you see where the module begins and ends.
- A group whose items are all hidden (by context or by the player) takes no space, and its divider goes too.

## 5. Interaction: the same everywhere

| Gesture | Does | Module may change it? |
|---|---|---|
| **Hover** | The module's tooltip for that item | content only |
| **Hover + Shift** | Details ("nerd stats") | content only |
| **Left-click** | The item's one main action (open its window, start/stop, put on the lure) | which action; or none |
| **Right-click** | The module's settings page in the console | no |
| **Shift-drag** (on the bar) | Move the compact bar | no |
| **Gear** | Settings; **Edit bar** from there | no |

### Tooltips

One tooltip per item, from its own module only. Shape:

```
[◉] Hearth · Bags                       ← module icon + module name · item name (bronze)
  34 free of 84                         ← the module's lines: two-space indent, label left, value right
  …
Click: open bags  ·  Right-click: settings   ← hint line (warm grey), the module supplies the click text
```

Keep it short (≤ 8 lines without Shift). Return nothing for an item that has nothing to say in this context.

## 6. Arranging: edit mode

Entered from the gear → **Edit bar** (or right-click the gear).

- The bar gets a dashed bronze outline; each group gets a soft frame; items breathe gently (alpha 1 ↔ 0.8).
- **Drag a group** to reorder groups, or into another zone (full-width).
- **Drag an item** within its group to reorder it. Items never leave their group.
- **Drag an item off the bar** to hide it; it goes to the **shelf**.
- **The shelf** opens under the bar while editing: every hidden item, grouped by module, with its icon and name;
  drag one onto the bar to show it.
- **Item options** on click while editing: show label, which places it shows in (the context grid for this item).
- **Done** (or Esc) leaves edit mode. The arrangement is saved for the account: the same bar on every character.

The console keeps a list view of the same (for controller players): groups and items with ↑ ↓, zone, show/hide.

## 7. How the bar evolves

- **A new module** appears as a new group at the right end of the right zone (before the system items), with its
  default items (≤ 3). Nothing else moves.
- **A new item** of an existing module appears at the end of its group if it's a default item, else on the shelf.
- **Contexts** (farm, raid, dungeon, city, world) hide and show items; the arrangement never changes with them.
- **Full bar:** in compact layout the bar grows up to 760 px, then the rightmost groups move into an overflow `…`
  item that opens a drop-down with the rest. Full-width has room for about twice as much.

## 8. Look

| Token | Value | Use |
|---|---|---|
| `ground` | #0D0A08 at 90 % | bar background |
| `bronze3` | #A67D45 | border, icon rings |
| `bronze2` | #805F35 | dividers |
| `bronze4` | #CC9957 | module names, headers |
| `cream` | #FFEDCC | values |
| `warmGrey` | #8F8275 | labels, hints |
| `good` / `warn` / `bad` | soft green / gold #FFD140 / soft red | states |

- Heights: compact bar 26 px; full-width 22 px.
- Motion: 150 ms fades; a short warm flash when a value changes meaningfully (a new catch, a slot freed); never
  bouncing, blinking or sliding.
- Sound: none from the bar itself.

## 9. Spec 2.0 (the API this needs)

```lua
local m = Deadbeat.Register("Hearth", { icon = "Interface\\Icons\\INV_Misc_Rune_01", spec = "2.0" })

local bags = m:Item("bags", {
    name = "Bags",                                    -- shown in tooltips, edit mode, the shelf
    icon = "Interface\\Icons\\INV_Misc_Bag_08",
    default = true,                                   -- on the bar out of the box (else on the shelf)
    contexts = { raid = true, world = true },         -- where it shows by default
})
bags:Set("34", "normal")                              -- value, state: normal | good | warn | bad
bags:SetIcon(path)                                    -- if the icon follows the content

m:Tooltip(function(tip, item, shift) end)             -- lines for this item (header and hints are drawn for you)
m:Click(function(item, button) end, "open bags")      -- left-click action + its hint text
m:Options(page)                                       -- right-click opens it (as in 1.0)

local w = m:Widget("slots", { name = "Slots", width = 60, default = true })   -- a frame to draw into
m:Claim("farm", on)  ·  m:OnContext(fn)  ·  m:Dock(frame)                     -- as in 1.0
```

- **Gone:** the shared fields (`Set("label" …)`, priorities), `Badge`, `Band`, `Section`, `OnClick`. Deadbeat 2.x
  keeps them working one more major as a **legacy item** per module (its fields joined into one value), with a
  one-time chat note to the module's author.
- **Order** is no longer passed: the player arranges; new modules append.

## 10. Rules for module authors

- One module = one group. Name it after your addon; give it an icon.
- Items say one thing each; values short; a state colour always backed by the text.
- At most three default items; the rest on the shelf.
- Tooltips: your module only, ≤ 8 lines, details behind Shift, nothing outside your context.
- Left-click: one obvious action, or none; never a menu of ten things (put those in your settings page).
- Never draw outside your items; never move, hide or restyle other groups or the bar.
