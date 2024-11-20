local types_module = {}

---Create a new player_data structure
---@return player_data
function types_module.new_player_data()
    ---@class player_data
    local player_data = {
        current_site = nil, ---@type yarm_site?
        gui_update_ticks = 300,
        overlays = {},
        renaming_site = nil, ---@type string? Name of the site being renamed, if any
        todo = {}, ---@type LuaEntity[]
        ui = types_module.new_player_data_ui(),
    }
    return player_data
end

---Create a new player_data.ui structure
---@return player_data_ui
function types_module.new_player_data_ui()
    ---@class player_data_ui
    local player_data_ui = {
        active_filter = resmon.ui.FILTER_WARNINGS,
        enable_hud_background = false,
        first_site = nil, -- when rendering sites, the first one is recorded so it can have a special display (e.g., surface name)
        split_by_surface = false,
        show_compact_columns = false,
        site_colors = {},
    }
    return player_data_ui
end

---Create a new force_data structure
---@return force_data
function types_module.new_force_data()
    ---@class force_data
    local force_data = {
        ---@type yarm_site[]
        ore_sites = {},
    }
    return force_data
end

---Create a new site structure from a given player and starting resource entity
---@param player LuaPlayer
---@param entity LuaEntity
---@return yarm_site
function types_module.new_site(player, entity)
    ---@class yarm_site
    local site = {
        is_summary = false, -- true for summary sites generated by resmon.sites.generate_summaries
        site_count = 0,     -- nonzero only for summaries (see above), where it contains the number of sites being summarized
        name = "New site for " .. player.name,
        added_at = game.tick,
        surface = entity.surface, ---@type LuaSurface
        force = player.force,
        center = { x = 0, y = 0 },
        first_center = { x = 0, y = 0 },
        ore_type = entity.name, ---@type string Resource entity prototype name
        ore_name = entity.prototype.localised_name,
        tracker_indices = {},
        entity_count = 0,
        initial_amount = 0,
        amount = 0,
        amount_left = 0,   -- like amount, but for infinite resources it excludes that minimum that the resource will always contain
        update_amount = 0, -- intermediate value while updating a site amount
        extents = {
            left = entity.position.x,
            right = entity.position.x,
            top = entity.position.y,
            bottom = entity.position.y,
        },
        next_to_scan = {},
        is_overlay_being_created = false,
        entities_to_be_overlaid = {},
        entities_to_be_overlaid_count = 0,
        next_to_overlay = {},
        next_to_overlay_count = 0,
        etd_minutes = -1,
        scanned_etd_minutes = -1,
        lifetime_etd_minutes = -1,
        ore_per_minute = 0, ---@type integer The current ore depletion rate, as of the last time the site was updated
        scanned_ore_per_minute = 0,
        lifetime_ore_per_minute = 0,
        etd_is_lifetime = true,
        last_ore_check = nil,       -- used for ETD easing; initialized when needed,
        last_modified_amount = nil, -- but I wanted to _show_ that they can exist.
        last_modified_tick = nil,   -- essentially the same as last_ore_check
        etd_minutes_delta = 0,
        ore_per_minute_delta = 0, ---@type integer The change in ore-per-minute since the last time we updated the site
        finalizing = false,        -- true after finishing on-tick scans while waiting for player confirmation/cancellation
        finalizing_since = nil,    -- tick number when finalizing turned true
        is_site_expanding = false, -- true when expanding an existing site
        has_expanded = false,
        original_amount = 0,
        remaining_permille = 1000,
        deleting_since = nil,      -- tick number when player presses "delete" for the first time; if not pressed for the second time within 120 ticks, deletion is cancelled
        chart_tag = nil, ---@type LuaCustomChartTag? the associated chart tag (aka map marker) with the site name and amount
        iter_key = nil,            -- used when iterating the site contents, along with iter_state
        iter_state = nil,          -- also used when iterating the site contents, along with iter_key
    }
    return site
end

---Create a new summary based on the given site
---@param site yarm_site
---@param summary_id string An identifier to distinguish this summary from others
---@return table
function types_module.new_summary_site_from(site, summary_id)
    return {
        name = "Total " .. summary_id,
        ore_type = site.ore_type,
        ore_name = site.ore_name,
        initial_amount = 0,
        amount = 0,
        ore_per_minute = 0,
        etd_minutes = 0,
        is_summary = 1,
        entity_count = 0,
        remaining_permille = 0,
        site_count = 0,
        etd_minutes_delta = 0,
        ore_per_minute_delta = 0,
        surface = site.surface,
    }
end

return types_module