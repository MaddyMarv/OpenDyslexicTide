local mod = get_mod("OpenDyslexicTide")

local SimpleAssets = get_mod("SimpleAssets")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIWidget = require("scripts/managers/ui/ui_widget")
local HudElementWorldMarkersSettings = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")

local GuiMaterialFlag = _G.GuiMaterialFlag
local Gui = _G.Gui
local Gui2 = _G.Gui2
local Vector2 = _G.Vector2
local Vector3 = _G.Vector3
local Color = _G.Color
local Managers = _G.Managers
local Utf8 = _G.Utf8

local type = type
local tostring = tostring
local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_clamp = math.clamp
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local bit_band = bit.band
local bit_bor = bit.bor
local table_clear = table.clear
local Utf8_string_length = Utf8.string_length
local Utf8_sub_string = Utf8.sub_string

local scalable_fonts_list = {
    "arial",
    "itc_novarese_medium",
    "itc_novarese_bold",
    "proxima_nova_light",
    "proxima_nova_medium",
    "proxima_nova_bold",
    "friz_quadrata",
    "rexlia",
    "machine_medium",
    "mono_tide_regular",
    "mono_tide_medium",
    "mono_tide_bold",
    "mono_tide_light",
}
local num_scalable_fonts = #scalable_fonts_list

local loaded_fonts = {
    opendyslexic3 = nil,
    opendyslexic3_bold = nil,
    opendyslexic2 = nil,
    opendyslexic2_bold = nil,
    opendyslexic = nil,
    opendyslexic_bold = nil,
    opendyslexic_mono = nil,
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
local setting_disable_font_in_chat_input = false
local setting_disable_cjk_scaling = true

local setting_enable_high_contrast_bg = false
local setting_high_contrast_opacity = 200
local setting_high_contrast_padding_x = 10
local setting_high_contrast_padding_y = 8
local setting_high_contrast_on_hud = false
local setting_high_contrast_on_chat = true
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
local icon_string_cache = {}
local cjk_string_cache = {}
local clean_text_cache = {}
local font_type_cache = {}
local renderer_info_cache = setmetatable({}, { __mode = "k" })
local marker_type_flags = {}

local cached_is_cjk_locale = false
local cached_maelstrom_header = nil
local cached_event_header = nil

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

    local chat_font_val = mod:get("disable_font_in_chat_input")
    setting_disable_font_in_chat_input = not not chat_font_val

    local cjk_scale_val = mod:get("disable_cjk_scaling")
    setting_disable_cjk_scaling = (cjk_scale_val == nil) and true or not not cjk_scale_val

    setting_enable_high_contrast_bg = not not mod:get("enable_high_contrast_bg")
    setting_high_contrast_opacity = mod:get("high_contrast_opacity") or 200
    setting_high_contrast_padding_x = mod:get("high_contrast_padding_x") or 10
    setting_high_contrast_padding_y = mod:get("high_contrast_padding_y") or 8

    local hc_hud_val = mod:get("high_contrast_on_hud")
    setting_high_contrast_on_hud = (hc_hud_val == nil) and false or not not hc_hud_val

    local hc_chat_val = mod:get("high_contrast_on_chat")
    setting_high_contrast_on_chat = (hc_chat_val == nil) and true or not not hc_chat_val

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

    local localization_manager = Managers.localization
    if localization_manager then
        local current_locale = localization_manager:language()
        cached_is_cjk_locale = (current_locale == "zh-cn" or current_locale == "zh-tw" or current_locale == "ja" or current_locale == "ko")
        cached_maelstrom_header = localization_manager:localize("loc_mission_board_maelstrom_header")
        cached_event_header = localization_manager:localize("loc_mission_board_mission_category_event")
    else
        cached_is_cjk_locale = false
        cached_maelstrom_header = nil
        cached_event_header = nil
    end

    table_clear(custom_font_cache)
    table_clear(icon_string_cache)
    table_clear(cjk_string_cache)
    table_clear(clean_text_cache)
end

local function _custom_crop_text_width(ui_renderer, text, max_width, last_start_position, caret_position, font_type, font_size)
    text = text or ""
    max_width = max_width > 0 and max_width or 0

    local original_text_length = Utf8_string_length(text)
    caret_position = caret_position or (original_text_length + 1)

    local prefix = ""
    local suffix = ""
    local start_index = 1
    local cropped_text = text
    local _ellipsis = "…"
    local _ellipsis_length = 1

    local _1, _2, _3, caret_offset = UIRenderer.text_size(ui_renderer, text, font_type, font_size)
    local ellipsis_width = UIRenderer.text_size(ui_renderer, _ellipsis, font_type, font_size)
    local actual_text_width = caret_offset and caret_offset[1] or 0

    if actual_text_width > 0 and max_width < actual_text_width then
        start_index = last_start_position or start_index

        if caret_position <= start_index then
            start_index = math_max(caret_position - 1, 1)
        end

        if start_index > 1 then
            prefix = _ellipsis
        end

        repeat
            local width_percent = 1 - (1 - (max_width - ellipsis_width) / actual_text_width) * 0.5
            local num_char = Utf8_string_length(cropped_text)
            local number_of_characters_to_show = math_floor(num_char * width_percent)
            local last_index = start_index + number_of_characters_to_show - 1

            if original_text_length < last_index then
                last_index = original_text_length
            elseif last_index < caret_position - 1 then
                last_index = caret_position - 1
                start_index = last_index - number_of_characters_to_show + 1
            end

            if start_index > 1 then
                prefix = _ellipsis
            else
                prefix = ""
            end

            if last_index < original_text_length then
                suffix = _ellipsis
            else
                suffix = ""
            end

            cropped_text = Utf8_sub_string(text, start_index, last_index)
            _1, _2, _3, caret_offset = UIRenderer.text_size(ui_renderer, prefix .. cropped_text .. suffix, font_type, font_size)
            actual_text_width = caret_offset and math_floor(caret_offset[1]) or 0
        until actual_text_width <= max_width

        cropped_text = prefix .. cropped_text .. suffix
    end

    if caret_position <= original_text_length then
        local num_chars_before_caret_pos = caret_position - start_index

        if prefix == _ellipsis then
            num_chars_before_caret_pos = num_chars_before_caret_pos + _ellipsis_length
        end

        local text_til_caret_pos = Utf8_sub_string(cropped_text, 1, num_chars_before_caret_pos)
        _1, _2, _3, caret_offset = UIRenderer.text_size(ui_renderer, text_til_caret_pos, font_type, font_size)
    end

    return cropped_text, (caret_offset and caret_offset[1] or 0), start_index
end

local function _custom_caret_logic_pass(pass, ui_renderer, ui_style, content, position, size)
    local old_input_text = content._input_text
    local new_input_text = content.input_text
    local old_active_placeholder_text = content._active_placeholder_text
    local new_active_placeholder_text = content.active_placeholder_text
    local old_caret_position = content._caret_position
    local new_caret_position = content.caret_position
    local force_caret_update = content.force_caret_update
    local is_text_box = content.is_text_box
    local text_has_changed = new_input_text ~= old_input_text
    local placeholder_text_has_changed = new_active_placeholder_text ~= old_active_placeholder_text
    local caret_position_has_changed = new_caret_position ~= old_caret_position
    local text_length = new_input_text and Utf8_string_length(new_input_text) or 0

    if not text_has_changed and not placeholder_text_has_changed and not caret_position_has_changed and not force_caret_update then
        return
    elseif content.max_length and text_length > content.max_length then
        content.input_text = old_input_text
        return
    end

    new_caret_position = new_caret_position and math_clamp(new_caret_position, 1, text_length + 1)

    local display_text_style = ui_style.parent.display_text
    local caret_style = ui_style.parent.input_caret
    local max_text_width = size[1] - 1

    if display_text_style.size_addition then
        max_text_width = max_text_width + display_text_style.size_addition[1]
    end

    local display_text, caret_offset, first_pos = _custom_crop_text_width(ui_renderer, new_input_text, max_text_width, content._input_text_first_visible_pos, new_caret_position, display_text_style.font_type, display_text_style.font_size)

    if is_text_box then
        caret_offset = caret_offset % (size[1] - 1)
    end

    content.caret_position = new_caret_position
    content._input_text = new_input_text
    content.display_text = display_text
    content._caret_position = new_caret_position
    content._input_text_first_visible_pos = first_pos
    content._active_placeholder_text = new_active_placeholder_text
    content.force_caret_update = nil
    caret_style.offset[1] = display_text_style.offset[1] + caret_offset
end

local function _custom_selection_logic_pass(pass, ui_renderer, ui_style, content, position, size)
    if not content._selection_changed then
        return
    end

    content._selection_changed = nil

    local selection_start = content._selection_start
    local selection_end = content._selection_end
    local display_text = content.display_text
    local display_text_style = ui_style.parent.display_text
    local first_visible_character_pos = content._input_text_first_visible_pos or 1
    local _ellipsis = "…"
    local _ellipsis_length = 1

    if first_visible_character_pos > 1 then
        local offset = first_visible_character_pos - _ellipsis_length - 1
        selection_start = math_max(selection_start - offset, 1)
        selection_end = selection_end - offset
    end

    local text_up_to_selection_start = Utf8_sub_string(display_text, 1, selection_start - 1)
    local _1, _2, _3, select_start_offset = UIRenderer.text_size(ui_renderer, text_up_to_selection_start, display_text_style.font_type, display_text_style.font_size)
    local last_visible_character_pos = Utf8_string_length(display_text) + first_visible_character_pos

    if last_visible_character_pos < selection_end then
        selection_end = last_visible_character_pos
    end

    local visibly_selected_text = Utf8_sub_string(display_text, selection_start, selection_end - 1)
    local _1, _2, _3, selection_width = UIRenderer.text_size(ui_renderer, visibly_selected_text, display_text_style.font_type, display_text_style.font_size)
    local selection_style = ui_style.parent.selection
    local selection_offset = selection_style.offset
    if not selection_offset then
        selection_offset = {}
        selection_style.offset = selection_offset
    end
    local selection_size = selection_style.size
    if not selection_size then
        selection_size = {}
        selection_style.size = selection_size
    end

    selection_offset[1] = display_text_style.offset[1] + (select_start_offset and select_start_offset[1] or 0)
    selection_size[1] = selection_width and selection_width[1] or 0
end

local function patch_text_input_templates(TextInputPassTemplates)
    if not TextInputPassTemplates then
        local success, t = pcall(require, "scripts/ui/pass_templates/text_input_pass_templates")
        if success then TextInputPassTemplates = t end
    end
    if TextInputPassTemplates then
        local templates = {
            TextInputPassTemplates.chat_input_field,
            TextInputPassTemplates.simple_input_field,
            TextInputPassTemplates.simple_input_box,
            TextInputPassTemplates.terminal_input_field,
        }
        for i = 1, #templates do
            local template = templates[i]
            if type(template) == "table" then
                if template[4] and template[4].pass_type == "logic" then
                    template[4].value = _custom_caret_logic_pass
                end
                if template[5] and template[5].pass_type == "logic" then
                    template[5].value = _custom_selection_logic_pass
                end
            end
        end
    end

    local constant_elements = Managers.ui and Managers.ui:ui_constant_elements()
    local chat = constant_elements and constant_elements._elements and constant_elements._elements.ConstantElementChat
    if chat and chat._input_field_widget and chat._input_field_widget.content then
        chat._input_field_widget.content.value_id_4 = _custom_caret_logic_pass
        chat._input_field_widget.content.value_id_5 = _custom_selection_logic_pass
        chat._input_field_widget.content.force_caret_update = true
    end
end

local function get_marker_category(marker_type)
    local cached = marker_type_flags[marker_type]
    if cached ~= nil then
        return cached
    end

    local cat
    if string_find(marker_type, "ping", 1, true) or string_find(marker_type, "threat", 1, true) or string_find(marker_type, "smart_tag", 1, true) then
        cat = "pings"
    elseif string_find(marker_type, "nameplate", 1, true) then
        cat = "nameplates"
    elseif string_find(marker_type, "interaction", 1, true) then
        cat = "interactions"
    elseif string_find(marker_type, "objective", 1, true) then
        cat = "objectives"
    else
        cat = "world_markers"
    end

    marker_type_flags[marker_type] = cat
    return cat
end

local function get_renderer_info(renderer)
    if not renderer then
        return nil
    end
    local cached = renderer_info_cache[renderer]
    if cached ~= nil then
        return cached
    end

    local name = renderer.name
    local name_str = type(name) == "string" and string_lower(name) or ""
    local is_hud = string_find(name_str, "uihud", 1, true) ~= nil
    local is_chat = string_find(name_str, "chat", 1, true) ~= nil or string_find(name_str, "constant_element", 1, true) ~= nil
    local is_mission = string_find(name_str, "mission", 1, true) ~= nil

    local info = {
        is_hud = is_hud,
        is_chat = is_chat,
        is_mission = is_mission,
    }
    renderer_info_cache[renderer] = info
    return info
end

function mod.on_all_mods_loaded()
    update_all_cached_settings()

    if not SimpleAssets then
        mod:echo("OpenDyslexicTide: SimpleAssets not found. Font functionality disabled.")
        return
    end

    SimpleAssets.load_font("opendyslexic3", "fonts/opendyslexic3.slug"):next(function(res) loaded_fonts.opendyslexic3 = res.resource_name; table_clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic3_bold", "fonts/opendyslexic3-bold.slug"):next(function(res) loaded_fonts.opendyslexic3_bold = res.resource_name; table_clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic2", "fonts/opendyslexic2.slug"):next(function(res) loaded_fonts.opendyslexic2 = res.resource_name; table_clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic2_bold", "fonts/opendyslexic2-bold.slug"):next(function(res) loaded_fonts.opendyslexic2_bold = res.resource_name; table_clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic", "fonts/opendyslexic.slug"):next(function(res) loaded_fonts.opendyslexic = res.resource_name; table_clear(custom_font_cache) end)
    SimpleAssets.load_font("opendyslexic_bold", "fonts/opendyslexic-bold.slug"):next(function(res) loaded_fonts.opendyslexic_bold = res.resource_name; table_clear(custom_font_cache) end)
    
    SimpleAssets.load_font("opendyslexic_mono", "fonts/opendyslexic-mono.slug"):next(function(res) loaded_fonts.opendyslexic_mono = res.resource_name; table_clear(custom_font_cache) end)

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

    for i = 1, #elements_to_hook do
        local entry = elements_to_hook[i]
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

                    local cat = get_marker_category(marker_type)
                    if cat == "pings" then
                        is_drawing_pings = true
                    elseif cat == "nameplates" then
                        is_drawing_nameplates = true
                    elseif cat == "interactions" then
                        is_drawing_interactions = true
                    elseif cat == "objectives" then
                        is_drawing_objectives = true
                    else
                        is_drawing_world_markers = true
                    end

                    local num_markers = #markers
                    for i = 1, num_markers do
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
                                offset[3] = math_min(layer_offset, max_layer)
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

    patch_text_input_templates()
    mod:hook_require("scripts/ui/pass_templates/text_input_pass_templates", function(templates)
        patch_text_input_templates(templates)
    end)

    local function hook_chat_element(cls)
        if cls then
            mod:hook_safe(cls, "init", function(self)
                if self._input_field_widget and self._input_field_widget.content then
                    self._input_field_widget.content.value_id_4 = _custom_caret_logic_pass
                    self._input_field_widget.content.value_id_5 = _custom_selection_logic_pass
                end
            end)

            mod:hook(cls, "_update_input_field", function(func, self, ui_renderer, widget)
                func(self, ui_renderer, widget)

                local to_channel_text = widget.content.to_channel
                if to_channel_text and to_channel_text ~= "" then
                    local extra_spacing = 10
                    local style = widget.style
                    local text_style = style.display_text

                    text_style.offset[1] = text_style.offset[1] + extra_spacing
                    if text_style.size_addition then
                        text_style.size_addition[1] = text_style.size_addition[1] - extra_spacing
                    end
                    if style.active_placeholder then
                        style.active_placeholder.offset[1] = style.active_placeholder.offset[1] + extra_spacing
                    end
                    widget.content.force_caret_update = true
                end
            end)
        end
    end

    if _G.ConstantElementChat then
        hook_chat_element(_G.ConstantElementChat)
    else
        mod:hook_require("scripts/ui/constant_elements/elements/chat/constant_element_chat", hook_chat_element)
    end
end

local previous_font = mod:get("font_version") or "opendyslexic3"

function mod.on_setting_changed(setting_id)
    if setting_id == "font_version" then
        local new_font = mod:get("font_version")
        if new_font == "default" then
            mod:set("hud_font_scale", 100)
            mod:set("small_font_scale", 100)
            mod:set("medium_font_scale", 100)
            mod:set("large_font_scale", 100)
            mod:set("huge_font_scale", 100)
        elseif new_font == "opendyslexic" then
            mod:set("hud_font_scale", 100)
            mod:set("small_font_scale", 72)
            mod:set("medium_font_scale", 72)
            mod:set("large_font_scale", 72)
            mod:set("huge_font_scale", 72)
        elseif new_font == "opendyslexic3" or new_font == "opendyslexic2" then
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

local function get_custom_font_info(font_type)
    local cached = font_type_cache[font_type]
    if cached ~= nil then
        return cached
    end

    local is_scalable = false
    local is_bold = false
    local is_mono = false
    local base_name = nil

    for i = 1, num_scalable_fonts do
        local font = scalable_fonts_list[i]
        if string_find(font_type, font, 1, true) then
            is_scalable = true
            base_name = font
            if string_find(font_type, "bold", 1, true) then is_bold = true end
            if string_find(font_type, "mono", 1, true) then is_mono = true end
            break
        end
    end

    if is_scalable then
        cached = { is_bold = is_bold, is_mono = is_mono, base_name = base_name }
    else
        cached = false
    end

    font_type_cache[font_type] = cached
    return cached
end

local function get_or_create_custom_font(font_type, loaded_hash)
    local font_manager = Managers.font
    if not font_manager then return loaded_hash end
    local defs = font_manager._font_definitions
    if not defs then return loaded_hash end

    local custom_font_type = loaded_hash .. "_" .. font_type
    if not defs[custom_font_type] then
        local original_def = defs[font_type]
        local paths = { loaded_hash }
        local flags = Gui.MultiLine + Gui.FormatDirectives

        if original_def then
            flags = original_def.render_flags or flags
            local orig_paths = original_def.path
            if orig_paths then
                local num_orig_paths = #orig_paths
                for i = 1, num_orig_paths do
                    if orig_paths[i] ~= loaded_hash then
                        paths[#paths + 1] = orig_paths[i]
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

local function process_text_draw(self, text, font_size, font_type)
    if type(font_type) ~= "string" then
        return font_size, font_type, text
    end

    local renderer_info = get_renderer_info(self)
    local is_hud_renderer = renderer_info and renderer_info.is_hud

    if not setting_use_font_on_hud and is_hud_renderer then
        return font_size, font_type, text
    end

    if setting_disable_font_in_chat_input and string_find(font_type, "no_render_flags", 1, true) then
        return font_size, font_type, text
    end

    local custom_font_type = resolve_custom_font(font_type)
    if custom_font_type == false then
        return font_size, font_type, text
    end

    local original_font_size = font_size

    if type(font_size) == "number" then
        if not (cached_is_cjk_locale and setting_disable_cjk_scaling) then
            if font_size <= 24 then
                font_size = font_size * setting_small_font_scale
            elseif font_size <= 35 then
                font_size = font_size * setting_medium_font_scale
            elseif font_size <= 50 then
                font_size = font_size * setting_large_font_scale
            else
                font_size = font_size * setting_huge_font_scale
            end

            if is_hud_renderer then
                font_size = font_size * setting_hud_font_scale
            end
        end
    end

    if font_size ~= original_font_size and type(text) == "string" and type(font_size) == "number" and type(original_font_size) == "number" then
        local is_clean = clean_text_cache[text]
        if is_clean == nil then
            local has_icon = string_find(text, "\xee", 1, true) or string_find(text, "{#icon", 1, true)
            local has_cjk = setting_disable_cjk_scaling and (string_find(text, "[\xE1-\xED\xEF\xF0]") ~= nil)
            if not has_icon and not has_cjk then
                clean_text_cache[text] = true
                is_clean = true
            else
                clean_text_cache[text] = false
                is_clean = false
            end
        end

        if not is_clean then
            if string_find(text, "\xee", 1, true) or string_find(text, "{#icon", 1, true) then
                local icon_cache_by_size = icon_string_cache[font_size]
                if not icon_cache_by_size then
                    icon_cache_by_size = {}
                    icon_string_cache[font_size] = icon_cache_by_size
                end

                local cached = icon_cache_by_size[text]
                if cached then
                    text = cached
                else
                    local new_text = string_gsub(text, "(\xee[\x80-\xbf][\x80-\xbf])", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    new_text = string_gsub(new_text, "({#icon.-})", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    icon_cache_by_size[text] = new_text
                    text = new_text
                end
            end

            if setting_disable_cjk_scaling and string_find(text, "[\xE1-\xED\xEF\xF0]") then
                local cjk_cache_by_size = cjk_string_cache[font_size]
                if not cjk_cache_by_size then
                    cjk_cache_by_size = {}
                    cjk_string_cache[font_size] = cjk_cache_by_size
                end

                local cached = cjk_cache_by_size[text]
                if cached then
                    text = cached
                else
                    local new_text = string_gsub(text, "([\xE2-\xED][\x80-\xBF][\x80-\xBF]+)", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    new_text = string_gsub(new_text, "(\xEF[\xA4-\xBF][\x80-\xBF]+)", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    new_text = string_gsub(new_text, "(\xE1[\x84-\x87][\x80-\xBF]+)", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    new_text = string_gsub(new_text, "(\xF0[\xA0-\xAA][\x80-\xBF][\x80-\xBF]+)", "{#size(" .. original_font_size .. ")}%1{#size(" .. font_size .. ")}")
                    cjk_cache_by_size[text] = new_text
                    text = new_text
                end
            end
        end
    end

    return font_size, custom_font_type, text
end

local ext_options = {}
local rect_options = {}

local function draw_text_background(self, text, font_size, font_type, gui_position, gui_size, color, options)
    local renderer_info = get_renderer_info(self)

    if renderer_info and renderer_info.is_chat and not setting_high_contrast_on_chat then
        return
    end

    if not setting_high_contrast_on_hud and renderer_info and renderer_info.is_hud then
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

    if renderer_info and renderer_info.is_mission then
        local is_banner = false
        if (cached_maelstrom_header and string_find(text, cached_maelstrom_header, 1, true)) or 
           (cached_event_header and string_find(text, cached_event_header, 1, true)) then
            is_banner = true
        else
            local lower_text = string_lower(text)
            if string_find(lower_text, "maelstrom", 1, true) or string_find(lower_text, "event", 1, true) then
                is_banner = true
            end
        end
        
        if is_banner then
            return
        end
    end

    if not text or type(text) ~= "string" or text == "" or not string_find(text, "%S") or not gui_position then
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

    table_clear(ext_options)
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

    local extents_func = Gui2.slug_text_extents or Gui.slug_text_extents or Gui2.slug_text_max_extents
    local min, max = extents_func(gui, text, font_path, font_size, ext_options)
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

    local box_pos = Vector3(gui_position[1] + min.x - pad_x, gui_position[2] + min.y - pad_y, math_max(z, 0))
    local box_sz = Vector2(text_w + (pad_x * 2), text_h + (pad_y * 2))

    local opacity = setting_high_contrast_opacity
    local alpha_mult = (render_settings and render_settings.alpha_multiplier) or 1

    local material_flags = 0
    if render_settings and render_settings.material_flags then
        material_flags = render_settings.material_flags
    end
    if bit_band(flags, Gui.Masked) == Gui.Masked and GuiMaterialFlag then
        material_flags = bit_bor(material_flags, GuiMaterialFlag.GUI_MASK_LAYER)
    end
    if self.render_pass_flag and GuiMaterialFlag then
        material_flags = bit_bor(material_flags, GuiMaterialFlag.GUI_RENDER_PASS_LAYER)
    end

    table_clear(rect_options)
    rect_options.color = Color(opacity * alpha_mult, 0, 0, 0)
    rect_options.snap_pixel_positions = (render_settings and render_settings.snap_pixel_positions) ~= false

    if material_flags and material_flags ~= 0 then
        rect_options.material_flags = material_flags
    end

    local render_pass = self.base_render_pass
    if render_pass and render_settings and render_settings.hdr then
        render_pass = render_pass .. "_hdr"
    end
    rect_options.render_pass = render_pass

    Gui2.rect(gui, box_pos, box_sz, rect_options)
end

mod:hook(UIRenderer, "script_draw_text", function(func, self, text, font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
    if setting_enable_high_contrast_bg then
        draw_text_background(self, final_text, final_size, final_font, gui_position, gui_size, color, options)
    end
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
