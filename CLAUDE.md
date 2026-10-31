# sketchy-gamey: notes for Claude

Godot 4.7, typed GDScript. The full design lives in `project_plan.txt`; the work queue is `ralph_prd.json` (do one feature per iteration and log it in `ralph_progress.txt`).

## Rules
- **Placeholders only.** Every image is a PlaceholderBox (white box, gray border, gray label naming the art that goes there) sized and positioned where the real art will go. Audio calls go through AudioManager and silently do nothing if the file is missing.
- **Composition over inheritance.** Build behaviour from small reusable component nodes/Resources in `components/` (HealthComponent, StatsComponent, SkillSetComponent, InteractionComponent...) attached as children. Extend only Godot built-ins plus at most one thin project base class. No Hero/Enemy subclass trees.
- **Folder structure.** Put every file where the tree below says. Keep a scene's script next to its `.tscn` with the same name (`main_menu.tscn` + `main_menu.gd`). Empty folders keep a `.gitkeep`.
- **Navigation** goes through the SceneRouter autoload with `SceneRouter.go_to(GameEnums.SceneId.OVERWORLD)`, never raw `change_scene_to_file` calls scattered around.
- **Slots.** Hero slots are 1-3 (3 = front/tank, 1 = back); enemy slots 4-7 (4 = front, 7 = back). In code use `GameEnums.HeroSlot` (1-3), `GameEnums.EnemySlot` (4-7) or `GameEnums.Slot` (all of 1-7, built from those two), whose values equal the slot numbers. Use these numbers in UI and docs; code may use 0-based indexes but must say so in a comment.
- **Ids are enums.** Refer to scenes, classes, weapons, skills, enemies and other fixed game choices through `GameEnums` (`resources/game_enums.gd`), never as strings like `"fighter"`. Add new ones there. Save files store the enum's name (`"FIGHTER"`), never its number, so entries can be reordered safely. Slot enums are the one exception: their values are pinned to the slot numbers, so saves store those numbers.
- **Out of scope for now:** Status and Quest tabs (show "Coming soon").
- **Target:** Windows (Steam) first, iPad maybe later. Base resolution 1920x1080, stretch mode `canvas_items`, aspect `expand`.

## Input actions (project.godot)
move_up / move_down / move_left / move_right (WASD, arrows, left stick), interact (E, Space, pad A), menu (Esc, pad Start), confirm (Enter, Space, pad A), cancel (Esc, Backspace, pad B).

## Checking your work
Run `godot_console --headless --path . --import` (imports assets and loads scripts without needing a main scene) and fix every error it prints. Once a main scene exists, `godot_console --headless --path . --quit-after 120` also runs the game briefly.

## Folder structure
```
res://
├── _production_files/      source files that are not imported into the game
│   ├── assets/             raw sketches / source art
│   └── mockups/            screen mockups
├── assets/                 imported art, audio, fonts
│   ├── art/
│   │   ├── characters/
│   │   ├── objects/
│   │   ├── tilesets/
│   │   └── placeholder/    gray-box placeholder images
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
├── autoloads/              global singletons (GameState, SceneRouter, AudioManager, SaveManager)
├── characters/             scenes built from components
│   ├── heroes/             overworld player, hero doll (rag doll shown wherever a hero appears in UI), hero combat units
│   ├── enemies/            Muck Ball etc.
│   └── npcs/
├── components/             small reusable nodes (composition over inheritance)
│   ├── combat_stats/
│   ├── health/
│   ├── interaction/
│   ├── inventory/
│   ├── movement/
│   └── skill_set/
├── resources/              game data (.gd data / .tres)
│   ├── classes/            Fighter, Mage, Priest
│   ├── enemies/
│   ├── items/              weapons, gear, trinkets, combat items
│   ├── skills/             every skill; classes, weapons and enemies reference them by id
│   └── tilesets/
├── systems/                game logic
│   ├── combat/             combat scene + turn loop
│   ├── dialogue/
│   ├── encounter/          encounter zones + random rolls
│   └── party/
├── ui/
│   ├── combat/
│   ├── common/             PlaceholderBox, theme, shared widgets
│   ├── dialogue/
│   ├── hud/                overworld HUD, hero status widget
│   ├── inventory/
│   └── menus/
│       ├── main_menu/
│       ├── load_game/
│       ├── new_game/       create party screen
│       └── escape_menu/
└── world/                  overworld map scenes
```

`_production_files/` has a `.gdignore`, so Godot never imports it.
