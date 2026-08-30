local mod = get_mod("OpenDyslexicTide")

local SimpleAssets = get_mod("SimpleAssets")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

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

local function update_active_font()
    local ver = mod:get("font_version") or "opendyslexic3"
    active_font = ver
    active_font_bold = ver .. "_bold"
end

function mod.on_all_mods_loaded()
    update_active_font()

    if not SimpleAssets then
        mod:echo("OpenDyslexicTide: SimpleAssets not found. Font functionality disabled.")
        return
    end

    SimpleAssets.load_font("opendyslexic3", "fonts/opendyslexic3.slug"):next(function(res) loaded_fonts.opendyslexic3 = res.resource_name end)
    SimpleAssets.load_font("opendyslexic3_bold", "fonts/opendyslexic3-bold.slug"):next(function(res) loaded_fonts.opendyslexic3_bold = res.resource_name end)
    
    SimpleAssets.load_font("opendyslexic2", "fonts/opendyslexic2.slug"):next(function(res) loaded_fonts.opendyslexic2 = res.resource_name end)
    SimpleAssets.load_font("opendyslexic2_bold", "fonts/opendyslexic2-bold.slug"):next(function(res) loaded_fonts.opendyslexic2_bold = res.resource_name end)
    
    SimpleAssets.load_font("opendyslexic", "fonts/opendyslexic.slug"):next(function(res) loaded_fonts.opendyslexic = res.resource_name end)
    SimpleAssets.load_font("opendyslexic_bold", "fonts/opendyslexic-bold.slug"):next(function(res) loaded_fonts.opendyslexic_bold = res.resource_name end)
    
    SimpleAssets.load_font("opendyslexic_mono", "fonts/opendyslexic-mono.slug"):next(function(res) loaded_fonts.opendyslexic_mono = res.resource_name end)
end

function mod.on_setting_changed(setting_id)
    if setting_id == "font_version" then
        update_active_font()
    end
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
        if string.find(font_type, font) then
            is_scalable = true
            base_name = font
            if string.find(font_type, "bold") then is_bold = true end
            if string.find(font_type, "mono") then is_mono = true end
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

local function is_hud(renderer)
    if not renderer then return false end
    if is_hud_cache[renderer] ~= nil then
        return is_hud_cache[renderer]
    end
    
    local name = renderer.name
    if type(name) == "string" and string.find(name, "UIHud") then
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

    local font_info = get_custom_font_info(font_type)
    if not font_info then
        return font_size, font_type, text
    end
    
    if mod:get("use_font_on_hud") == false and is_hud(self) then
        return font_size, font_type, text
    end

    local target_key = active_font
    if font_info.is_bold then target_key = active_font_bold end
    if font_info.is_mono then target_key = active_font_mono end
    
    local custom_font_type = font_type
    local loaded_hash = loaded_fonts[target_key]
    if loaded_hash then
        custom_font_type = get_or_create_custom_font(font_type, loaded_hash)
    end

    local original_font_size = font_size
    if type(font_size) == "number" then
        local small = (mod:get("small_font_scale") or 100) / 100
        local medium = (mod:get("medium_font_scale") or 100) / 100
        local large = (mod:get("large_font_scale") or 100) / 100
        local huge = (mod:get("huge_font_scale") or 100) / 100

        if font_size <= 24 then
            font_size = font_size * small
        elseif font_size <= 35 then
            font_size = font_size * medium
        elseif font_size <= 50 then
            font_size = font_size * large
        else
            font_size = font_size * huge
        end
        if is_hud(self) then
            local hud_scale = (mod:get("hud_font_scale") or 100) / 100
            font_size = font_size * hud_scale
        end
    end

    if type(text) == "string" and type(font_size) == "number" and type(original_font_size) == "number" and font_size ~= original_font_size then
        if string.find(text, "\xee[\x80-\xbf]") or string.find(text, "{#icon") then
            local cache_key = text .. "_" .. tostring(font_size) .. "_" .. tostring(original_font_size)
            if icon_string_cache[cache_key] then
                text = icon_string_cache[cache_key]
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

mod:hook(UIRenderer, "script_draw_text", function(func, self, text, font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
    local final_size, final_font, final_text = process_text_draw(self, text, font_size, font_type)
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
