# FiveM QBCore Heist Creator Resource

HeistForge QBCore is a FiveM resource for QBCore servers that provides a secure in-game heist creator, editor, tester, and runtime system written in Lua, allowing authorized administrators to create and manage configurable multiplayer heists without editing configuration files or restarting the server.

## Install

1. Copy the resource folder into your FiveM server's resources directory.
2. Ensure the resource folder is named `heistcreator`.
3. Add the following lines to `server.cfg`:

```cfg
ensure qb-core
ensure heistcreator
```

4. Grant ACE access if required:

```cfg
add_ace group.admin heistcreator.admin allow
```

5. Restart the resource or server once. Heist data is stored in `heists.json`.

Requirements:

- FiveM artifact with Lua 5.4 support
- `qb-core`
- QBCore permissions of `admin` or `god`, or the configured ACE permission
- A QBCore item entry for every item reward used in a heist

## Use

1. An authorized administrator opens the creator in-game with `F6`.
2. Select `New` to create a heist or select an existing heist to edit.
3. Enter the heist name, description, cooldown, minimum police requirement, and maximum participant count.
4. Set the entry coordinates manually or select `Use current position`.
5. Add objectives with a label, objective type, and coordinates.
6. Add cash, bank, or item rewards.
7. Save the heist. Changes are written to `heists.json` and become available immediately.
8. Use `Test` to run a saved heist without issuing rewards.
9. Players start a published heist by approaching its entry point and pressing `E`.
10. The starting player becomes the team leader and can invite nearby players with:

```text
/heistinvite [server id]
```

11. Invited players respond with:

```text
/heistaccept
/heistdecline
```

12. Participants can leave a team with:

```text
/heistleave
```

Objectives are shared by the team and validated server-side. Each participant receives a map marker and GPS route for the current objective. The route updates as objectives are completed. Once all objectives are complete, only the team leader can finish the heist at the entry point. Configured rewards are then issued to all participants, except during test runs.

Server-side validation includes administrator access, request throttling, entry distance, objective distance, objective order, minimum on-duty police count, cooldowns, maximum team size, run expiration, reward limits, and heist data limits. Runtime and blip settings can be adjusted in `config.lua`.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/362f7822-b1d5-4ebf-a3b9-643a934873b8?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=362f7822-b1d5-4ebf-a3b9-643a934873b8
