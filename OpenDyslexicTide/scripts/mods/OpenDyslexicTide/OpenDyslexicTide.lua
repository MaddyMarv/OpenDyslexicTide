local mod = get_mod("OpenDyslexicTide")

local SimpleAssets = get_mod("SimpleAssets")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIWidget = require("scripts/managers/ui/ui_widget")
local HudElementWorldMarkersSettings = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")
local GuiMaterialFlag = _G.GuiMaterialFlag

local scalable_fonts = {
    arial = true,
    itc_novarese_medium = true,
    itc_novarese_bold = true,
    proxima_nova_light = true,
    proxima_nova_medium = true,
    proxima_nova_bold = true,
    friz_quadrata = true,
    rexlia = true,
    machine_medium = true,
    mono_tide_regular = true,
    mono_tide_medium = true,
    mono_tide_bold = true,
    mono_tide_light = true
}

local loaded_fonts = {
    opendyslexic3 = nil,
    opendyslexic3_bold = nil,
    opendyslexic2 = nil,
    opendyslexic2_bold = nil,
    opendyslexic = nil,
    opendyslexic_bold = nil,
    opendyslexic_mono = nil
}

local active_font = "opendyslexic3"
local active_font_bold = "opendyslexic3_bold"
local active_font_mono = "opendyslexic_mono"

local setting_use_font_on_hud = true
local setting_hud_font_scale = 1.0
local setting_small_font_scale = 0.8
local setting_medium_font_scale = 0.8
local setting_large_font_scale = 0.85
local setting_huge_font_scale = 0.85

local setting_enable_high_contrast_bg = false
local setting_high_contrast_opacity = 230
local setting_high_contrast_padding_x = 10
local setting_high_contrast_padding_y = 2
local setting_high_contrast_on_hud = false
local setting_high_contrast_on_killfeed = true
local setting_high_contrast_on_world_markers = true
local setting_high_contrast_on_pings = true
local setting_high_contrast_on_nameplates = true
local setting_high_contrast_on_interactions = true
local setting_high_contrast_on_objectives = true

local is_drawing_feed = false
local is_drawing_world_markers = false
local is_drawing_pings = false
local is_drawing_nameplates = false
local is_drawing_interactions = false
local is_drawing_objectives = false
local custom_font_cache = {}

local function update_all_cached_settings()
    local ver = mod:get("font_version") or "opendyslexic3"
    active_font = ver
    active_font_bold = (ver == "default") and "default" or (ver .. "_bold")
    active_font_mono = (ver == "default") and "default" or "opendyslexic_mono"

    local hud_val = mod:get("use_font_on_hud")
    setting_use_font_on_hud = (hud_val == nil) and true or not not hud_val

    setting_hud_font_scale = (mod:get("hud_font_scale") or 100) / 100
    setting_small_font_scale = (mod:get("small_font_scale") or 80) / 100
    setting_medium_font_scale = (mod:get("medium_font_scale") or 80) / 100
    setting_large_font_scale = (mod:get("large_font_scale") or 85) / 100
    setting_huge_font_scale = (mod:get("huge_font_scale") or 85) / 100

    setting_enable_high_contrast_bg = not not mod:get("enable_high_contrast_bg")
    setting_high_contrast_opacity = mod:get("high_contrast_opacity") or 230
    setting_high_contrast_padding_x = mod:get("high_contrast_padding_x") or 10
    setting_high_contrast_padding_y = mod:get("high_contrast_padding_y") or 2

    local hc_hud_val = mod:get("high_contrast_on_hud")
    setting_high_contrast_on_hud = (hc_hud_val == nil) and false or not not hc_hud_val

    local hc_kf_val = mod:get("high_contrast_on_killfeed")
    setting_high_contrast_on_killfeed = (hc_kf_val == nil) and true or not not hc_kf_val

    local hc_wm_val = mod:get("high_contrast_on_world_markers")
    setting_high_contrast_on_world_markers = (hc_wm_val == nil) and true or not not hc_wm_val

    local hc_pings_val = mod:get("high_contrast_on_pings")
    setting_high_contrast_on_pings = (hc_pings_val == nil) and true or not not hc_pings_val

    local hc_names_val = mod:get("high_contrast_on_nameplates")
    setting_high_contrast_on_nameplates = (hc_names_val == nil) and true or not not hc_names_val

    local hc_inter_val = mod:get("high_contrast_on_interactions")
    setting_high_contrast_on_interactions = (hc_inter_val == nil) and true or not not hc_inter_val

    local hc_obj_val = mod:get("high_contrast_on_objectives")
    setting_high_contrast_on_objectives = (hc_obj_val == nil) and true or not not hc_obj_val

    table.clear(custom_font_cache)
end

function mod.on_all_mods_loaded()
    update_all_cached_settings()

    if not SimpleAssets then
        mod:echo("OpenDyslexicTide: SimpleAssets not found. Font functionality disabled.")
        return
    end

    SimpleAssets.load_font("opendyslexic3", "fonts/opendyslexic3.slug"):next(function(res) loaded_fonts.opendyslexic3 = res.resource_name; table.clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic3_bold", "fonts/opendyslexic3-bold.slug"):next(function(res) loaded_fonts.opendyslexic3_bold = res.resource_name; table.clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic2", "fonts/opendyslexic2.slug"):next(function(res) loaded_fonts.opendyslexic2 = res.resource_name; table.clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic2_bold", "fonts/opendyslexic2-bold.slug"):next(function(res) loaded_fonts.opendyslexic2_bold = res.resource_name; table.clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic", "fonts/opendyslexic.slug"):next(function(res) loaded_fonts.opendyslexic = res.resource_name; table.clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic_bold", "fonts/opendyslexic-bold.slug"):next(function(res) loaded_fonts.opendyslexic_bold = res.resource_name; table.clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic_mono", "fonts/opendyslexic-mono.slug"):next(function(res) loaded_fonts.opendyslexic_mono = res.resource_name; table.clear(custom_font_cache) end)

    local hooked_elements = {}
    local function hook_hud_element(element_class, flag_name)
        if element_class and not hooked_elements[element_class] then
            hooked_elements[element_class] = true
            mod:hook(element_class, "_draw_widgets", function(func, self, ...)
                if flag_name == "feed" then is_drawing_feed = true
                elseif flag_name == "pings" then is_drawing_pings = true
                elseif flag_name == "nameplates" then is_drawing_nameplates = true
                elseif flag_name == "interactions" then is_drawing_interactions = true
                elseif flag_name == "objectives" then is_drawing_objectives = true
                end

                local r1, r2, r3, r4 = func(self, ...)

                if flag_name == "feed" then is_drawing_feed = false
                elseif flag_name == "pings" then is_drawing_pings = false
                elseif flag_name == "nameplates" then is_drawing_nameplates = false
                elseif flag_name == "interactions" then is_drawing_interactions = false
                elseif flag_name == "objectives" then is_drawing_objectives = false
                end

                return r1, r2, r3, r4
            end)
        end
    end

    local elements_to_hook = {
        { name = "HudElementCombatFeed", file = "scripts/ui/hud/elements/combat_feed/hud_element_combat_feed", flag = "feed" },
        { name = "ConstantElementNotificationFeed", file = "scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed", flag = "feed" },
        { name = "HudElementSmartTagging", file = "scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging", flag = "pings" },
        { name = "HudElementInteraction", file = "scripts/ui/hud/elements/interaction/hud_element_interaction", flag = "interactions" },
        { name = "HudElementPlayerCompass", file = "scripts/ui/hud/elements/player_compass/hud_element_player_compass", flag = "objectives" },
        { name = "HudElementMissionObjectiveFeed", file = "scripts/ui/hud/elements/mission_objective_feed/hud_element_mission_objective_feed", flag = "objectives" },
        { name = "HudElementMissionObjectivePopup", file = "scripts/ui/hud/elements/mission_objective_popup/hud_element_mission_objective_popup", flag = "objectives" },
        { name = "HudElementObjectiveProgressBar", file = "scripts/ui/hud/elements/objective_progress_bar/hud_element_objective_progress_bar", flag = "objectives" },
        { name = "HudElementAreaNotificationPopup", file = "scripts/ui/hud/elements/area_notification_popup/hud_element_area_notification_popup", flag = "objectives" },
    }

    for _, entry in ipairs(elements_to_hook) do
        if _G[entry.name] then
            hook_hud_element(_G[entry.name], entry.flag)
        else
            mod:hook_require(entry.file, function(cls) hook_hud_element(cls, entry.flag) end)
        end
    end

    local hooked_wm_managers = {}
    local function hook_world_markers_manager(element_class)
        if element_class and not hooked_wm_managers[element_class] then
            hooked_wm_managers[element_class] = true
            mod:hook(element_class, "_draw_markers", function(func, self, dt, t, input_service, ui_renderer, render_settings)
                local camera = self:_get_camera()
                if not camera then return end
                local markers_by_type = self._markers_by_type
                if not markers_by_type then
                    return func(self, dt, t, input_service, ui_renderer, render_settings)
                end

                local layer_offset = 0
                local max_layer = HudElementWorldMarkersSettings.max_marker_draw_layer
                local layer_inc = HudElementWorldMarkersSettings.marker_draw_layer_increment

                for marker_type, markers in pairs(markers_by_type) do
                    local prev_pings = is_drawing_pings
                    local prev_names = is_drawing_nameplates
                    local prev_inter = is_drawing_interactions
                    local prev_obj = is_drawing_objectives
                    local prev_wm = is_drawing_world_markers

                    if string.find(marker_type, "ping", 1, true) or string.find(marker_type, "threat", 1, true) or string.find(marker_type, "smart_tag", 1, true) then
                        is_drawing_pings = true
                    elseif string.find(marker_type, "nameplate", 1, true) then
                        is_drawing_nameplates = true
                    elseif string.find(marker_type, "interaction", 1, true) then
                        is_drawing_interactions = true
                    elseif string.find(marker_type, "objective", 1, true) then
                        is_drawing_objectives = true
                    else
                        is_drawing_world_markers = true
                    end

                    for i = 1, #markers do
                        local marker = markers[i]
                        local draw = marker.draw
                        if draw then
                            local widget = marker.widget
                            local content = widget.content
                            local distance = content.distance
                            local template = marker.template
                            local scale_settings = template.scale_settings
                            local fade_settings = template.fade_settings

                            if scale_settings then
                                marker.scale = self:_get_scale(scale_settings, distance)
                                local new_scale = marker.ignore_scale and 1 or marker.scale
                                self:_apply_scale(widget, new_scale)
                            end

                            local alpha_multiplier = 1
                            if fade_settings and not marker.block_fade_settings then
                                alpha_multiplier = self:_get_fade(fade_settings, distance)
                            end

                            if draw then
                                local offset = widget.offset
                                offset[3] = math.min(layer_offset, max_layer)
                                layer_offset = layer_offset + layer_inc

                                local previous_alpha_multiplier = widget.alpha_multiplier
                                widget.alpha_multiplier = (previous_alpha_multiplier or 1) * alpha_multiplier
                                UIWidget.draw(widget, ui_renderer)
                                widget.alpha_multiplier = previous_alpha_multiplier
                            end
                        end
                    end

                    is_drawing_pings = prev_pings
                    is_drawing_nameplates = prev_names
                    is_drawing_interactions = prev_inter
                    is_drawing_objectives = prev_obj
                    is_drawing_world_markers = prev_wm
                end
            end)
        end
    end

    if _G.HudElementWorldMarkers then
        hook_world_markers_manager(_G.HudElementWorldMarkers)
    else
        mod:hook_require("scripts/ui/hud/elements/world_markers/hud_element_world_markers", hook_world_markers_manager)
    end
end

local previous_font = mod:get("font_version") or "opendyslexic3"

function mod.on_setting_changed(setting_id)
    if setting_id == "font_version" then
        local new_font = mod:get("font_version")
        if new_font == "default" and previous_font ~= "default" then
            mod:set("hud_font_scale", 100)
            mod:set("small_font_scale", 100)
            mod:set("medium_font_scale", 100)
            mod:set("large_font_scale", 100)
            mod:set("huge_font_scale", 100)
        elseif new_font ~= "default" and previous_font == "default" then
            mod:set("hud_font_scale", 100)
            mod:set("small_font_scale", 80)
            mod:set("medium_font_scale", 80)
            mod:set("large_font_scale", 85)
            mod:set("huge_font_scale", 85)
        end
        previous_font = new_font
    end

    update_all_cached_settings()
end

local font_type_cache = {}
local is_hud_cache = {}

local function get_custom_font_info(font_type)
    if font_type_cache[font_type] ~= nil then
        return font_type_cache[font_type]
    end

    local is_scalable = false
    local is_bold = false
    local is_mono = false
    local base_name = nil
    
    for font, _ in pairs(scalable_fonts) do
        if string.find(font_type, font, 1, true) then
            is_scalable = true
            base_name = font
            if string.find(font_type, "bold", 1, true) then is_bold = true end
            if string.find(font_type, "mono", 1, true) then is_mono = true end
            break
        end
    end

    if is_scalable then
        font_type_cache[font_type] = { is_bold = is_bold, is_mono = is_mono, base_name = base_name }
    else
        font_type_cache[font_type] = false
    end
    
    return font_type_cache[font_type]
end

local function get_or_create_custom_font(font_type, loaded_hash)
    local Managers = _G.Managers
    if not Managers or not Managers.font then return loaded_hash end
    local defs = Managers.font._font_definitions
    if not defs then return loaded_hash end
    
    local custom_font_type = loaded_hash .. "_" .. font_type
    if not defs[custom_font_type] then
        local original_def = defs[font_type]
        local paths = { loaded_hash }
        local flags = _G.Gui.MultiLine + _G.Gui.FormatDirectives
        
        if original_def then
            flags = original_def.render_flags or flags
            if original_def.path then
                for i = 1, #original_def.path do
                    if original_def.path[i] ~= loaded_hash then
                        paths[#paths + 1] = original_def.path[i]
                    end
                end
            end
        else
            paths[#paths + 1] = "content/ui/fonts/darktide_custom_regular"
        end
        
        defs[custom_font_type] = { path = paths, render_flags = flags }
    end
    return custom_font_type
end

local function resolve_custom_font(font_type)
    if active_font == "default" then
        return font_type
    end

    local cached = custom_font_cache[font_type]
    if cached ~= nil then
        return cached
    end

    local font_info = get_custom_font_info(font_type)
    if not font_info then
        custom_font_cache[font_type] = false
        return false
    end

    local target_key = active_font
    if font_info.is_bold then target_key = active_font_bold end
    if font_info.is_mono then target_key = active_font_mono end

    local loaded_hash = loaded_fonts[target_key]
    if not loaded_hash then
        custom_font_cache[font_type] = font_type
        return font_type
    end

    local result = get_or_create_custom_font(font_type, loaded_hash)
    custom_font_cache[font_type] = result
    return result
end

local function is_hud(renderer)
    if not renderer then return false end
    if is_hud_cache[renderer] ~= nil then
        return is_hud_cache[renderer]
    end
    
    local name = renderer.name
    if type(name) == "string" and string.find(name, "UIHud", 1, true) then
        is_hud_cache[renderer] = true
    else
        is_hud_cache[renderer] = false
    end
    return is_hud_cache[renderer]
end

local icon_string_cache = {}

local function process_text_draw(self, text, font_size, font_type)
    if type(font_type) ~= "string" then 
        return font_size, font_type, text
    end

    if not setting_use_font_on_hud and is_hud(self) then
        return font_size, font_type, text
    end

    local custom_font_type = resolve_custom_font(font_type)
    if custom_font_type == false then
        return font_size, font_type, text
    end

    local original_font_size = font_size
    if type(font_size) == "number" then
        if font_size <= 24 then
            font_size = font_size * setting_small_font_scale
        elseif font_size <= 35 then
            font_size = font_size * setting_medium_font_scale
        elseif font_size <= 50 then
            font_size = font_size * setting_large_font_scale
        else
            font_size = font_size * setting_huge_font_scale
        end

        if is_hud(self) then
            font_size = font_size * setting_hud_font_scale
        end
    end

    if type(text) == "string" and type(font_size) == "number" and type(original_font_size) == "number" and font_size ~= original_font_size then
        if string.find(text, "\xee", 1, true) or string.find(text, "{#icon", 1, true) then
            local cache_key = text .. "_" .. tostring(font_size) .. "_" .. tostring(original_font_size)
            local cached = icon_string_cache[cache_key]
            if cached then
                text = cached
            else
                local new_text = string.gsub(text, "(\xee[\x80-\xbf][\x80-\xbf])", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                new_text = string.gsub(new_text, "({#icon.-})", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                icon_string_cache[cache_key] = new_text
                text = new_text
            end
        end
    end

    return font_size, custom_font_type, text
end

local ext_options = {}
local rect_options = {}

local function draw_text_background(self, text, font_size, font_type, gui_position, gui_size, color, options)
    if not setting_enable_high_contrast_bg then
        return
    end

    if not setting_high_contrast_on_hud and is_hud(self) then
        local is_allowed = (setting_high_contrast_on_killfeed and is_drawing_feed) or
                           (setting_high_contrast_on_world_markers and is_drawing_world_markers) or
                           (setting_high_contrast_on_pings and is_drawing_pings) or
                           (setting_high_contrast_on_nameplates and is_drawing_nameplates) or
                           (setting_high_contrast_on_interactions and is_drawing_interactions) or
                           (setting_high_contrast_on_objectives and is_drawing_objectives)
        if not is_allowed then
            return
        end
    end

    if not text or type(text) ~= "string" or text == "" or not string.find(text, "%S") or not gui_position then
        return
    end

    if color and type(color) == "table" and color[1] == 0 then
        return
    end

    local gui = self.gui
    if not gui then
        return
    end

    local font_data = UIFonts.data_by_type(font_type)
    local font_path = font_data and font_data.path
    if not font_path then
        return
    end

    local flags = font_data.render_flags or 0
    if self.render_pass_flag then
        flags = flags + Gui.RenderPass
    end

    table.clear(ext_options)
    ext_options.flags = flags
    if options then
        ext_options.horizontal_alignment = options.horizontal_alignment
        ext_options.vertical_alignment = options.vertical_alignment
        ext_options.line_spacing = options.line_spacing
        ext_options.character_spacing = options.character_spacing
    end
    if gui_size then
        ext_options.optional_size = Vector2(gui_size[1], gui_size[2])
    end

    local min, max = Gui2.slug_text_max_extents(gui, text, font_path, font_size, ext_options)
    if not min or not max then
        return
    end

    local text_w = max.x - min.x
    local text_h = max.y - min.y
    if text_w <= 0 or text_h <= 0 then
        return
    end

    local pad_x = setting_high_contrast_padding_x
    local pad_y = setting_high_contrast_padding_y
    local render_settings = self.render_settings
    local start_layer = (render_settings and render_settings.start_layer) or 0
    local z = (gui_position[3] or 0) + start_layer - 0.01

    local box_pos = Vector3(gui_position[1] + min.x - pad_x, gui_position[2] + min.y - pad_y, math.max(z, 0))
    local box_sz = Vector2(text_w + (pad_x * 2), text_h + (pad_y * 2))

    local opacity = setting_high_contrast_opacity
    local alpha_mult = (render_settings and render_settings.alpha_multiplier) or 1

    local material_flags = 0
    if render_settings and render_settings.material_flags then
        material_flags = render_settings.material_flags
    end
    if bit.band(flags, Gui.Masked) == Gui.Masked and GuiMaterialFlag then
        material_flags = bit.bor(material_flags, GuiMaterialFlag.GUI_MASK_LAYER)
    end
    if self.render_pass_flag and GuiMaterialFlag then
        material_flags = bit.bor(material_flags, GuiMaterialFlag.GUI_RENDER_PASS_LAYER)
    end

    table.clear(rect_options)
    rect_options.color = Color(opacity * alpha_mult, 0, 0, 0)
    rect_options.snap_pixel_positions = (render_settings and render_settings.snap_pixel_positions) ~= false
    rect_options.flags = flags
    rect_options.material_flags = material_flags

    local render_pass = self.base_render_pass
    if render_pass and render_settings and render_settings.hdr then
        render_pass = render_pass .. "_hdr"
    end
    rect_options.render_pass = render_pass

    Gui2.rect(gui, box_pos, box_sz, rect_options)
end

mod:hook(UIRenderer, "script_draw_text", function(func, self, text, font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
    draw_text_background(self, final_text, final_size, final_font, gui_position, gui_size, color, options)
    return func(self, final_text, final_size, final_font, gui_position, gui_size, color, options, retained_id, ...)
end)

mod:hook(UIRenderer, "script_draw_text_3d", function(func, self, text, font_size, font_type, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
    return func(self, final_text, final_size, final_font, ...)
end)

mod:hook(UIRenderer, "text_size", function(func, self, text, font_type, font_size, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
    return func(self, final_text, final_font, final_size, ...)
end)

mod:hook(UIRenderer, "styled_text_size", function(func, self, text, style, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, style.font_size, style.font_type)
    
    local old_font = style.font_type
    local old_size = style.font_size
    
    style.font_type = final_font
    style.font_size = final_size
    
    local width, height, min, caret = func(self, final_text, style, ...)
    
    style.font_type = old_font
    style.font_size = old_size
    
    return width, height, min, caret
end)

mod:hook(UIRenderer, "text_height", function(func, self, text, font_type, font_size, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
    return func(self, final_text, final_font, final_size, ...)
end)
