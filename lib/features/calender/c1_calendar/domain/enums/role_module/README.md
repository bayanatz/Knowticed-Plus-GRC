# role_module

Grouping folder for the modules under the **Roles** feature that place entries
on the calendar. Mirrors
`features/notification/domain/enums/role_module/` exactly.

| Folder | Enum | AppModule |
|---|---|---|
| `role_management_module/` | `RoleManagementCalendarEvent` | `AppModule.roleManagement` |
| `user_access_module/` | `UserAccessCalendarEvent` | `AppModule.userAccess` |

`user_management_module` has no calendar entries in the spec, so it has a
folder on the notification side only.

## Organisation only

Two separate `AppModule` values, registered individually in
`calendar_catalog.dart`. Nothing about lookup, keys or behaviour changed —
only the import path gained a segment, and each event file's relative import
of the contract went one level deeper (`../../calendar_event_type.dart`).
