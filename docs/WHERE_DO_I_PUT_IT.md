# Where do I put it?

Every module has the same structure (rulebook K-26). You work **only** inside your module's folder and your module's slots below. You never edit another module or the shared core (K-22). If the shared core needs a change, ask Moataz.

Module names: `crm · database · form_builder · grc · hr · inventory · knowledge_hub · qiyas · services · time_tracker · todo`
Screen prefixes: `crm · db · fb · grc · hr · inv · kh · qy · sv · tt · td`

## Inside your module: `lib/features/<module>/`

| I need to add… | Put it in |
|---|---|
| The page the drawer opens | `<module>_entry.dart` exports it (one per module) |
| get_it registrations (data source, repository, cubit) | `<module>_get_it.dart` → `setup<Module>Dependencies(GetIt)` |
| A new screen | `<px><next number>_<screen>/` with `data/ domain/ presentation/` |
| A Firestore data source | `<screen>/data/data_source/remote_data_source/` |
| A model (fromJson / toMap) | `<screen>/data/models/` |
| A repository implementation | `<screen>/data/repository/` |
| The repository interface | `<screen>/domain/base_repository/` |
| An entity / enum / use case | `<screen>/domain/entities/` · `enums/` · `use_cases/` |
| A cubit + state (Cubit only, K-01) | `<screen>/presentation/controller/` |
| A page / a widget | `<screen>/presentation/ui/pages/` · `ui/widgets/` |
| Something several of my screens share | module root `data/ domain/ presentation/` |
| A helper only my module uses (routes, constants, formatters) | `helpers/` (K-25) |
| Old core files my module still needs | `data/legacy_core/` (temporary, replace with the shared core) |

## Your slots in the shared part (already created for every module)

| I need to add… | Put it in |
|---|---|
| Permission sections / switches | `lib/features/roles/r1_role_management/domain/enums/<module>/` |
| Notification events + the pages they open (also shown in Notification Control) | `lib/features/notification/domain/enums/<module>/` |
| Home cards | `lib/features/home/h1_home_page/presentation/ui/widgets/module_widget/<module>/` |
| Calendar entries | `lib/features/calendar/data/data_source/<module>/` |
| Icons / images | `assets/icons_assets/<module>_assets/`. Add the folder to `pubspec.yaml` if it is new. |

## Never
- Edit `lib/core/` or another module's folder.
- Use GetX, `print`, inline colours or text styles, or hard-coded strings (K-01, K-06, K-07).
- Put a module helper in `lib/core/helper/` (K-25).

## Module split (Demo-App + one repo per module) — 17 Oct 2026

The combined project is the source. Demo-App = the shared modules only; each
module repo = Demo-App + that module. They are CUT from this project, never
edited separately.

- Optional modules: crm, database, form_builder, grc, hr, inventory,
  knowledge_hub, qiyas, services, time_tracker. Everything else is shared.
- Shared code that touches an optional module carries a marker (comments only):
  - `<code> // [module:x]` — line removed when x is cut
  - `<code> // [module:x|<replacement>]` — line replaced (e.g. `RemovedModulePage`)
  - `// [module:x]` … `// [/module:x]` — block removed
  - `// [module-file:x]` near the top — file removed
- A NEW link from shared code into an optional module needs a marker, or the
  split for every other repo stops compiling. Better: put module-only code in
  the module, and shared constants / entities in `core/` or the shared module.
- Cutting: `WORK/1. Knowticed Plus/Platform Merge/tools/split_modules.py <copy> <modules to remove…>`;
  uploading: `tools/upload_split.sh` (new branch, 0 analyze errors required).
