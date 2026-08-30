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

local function ensure_font_def(base_hash)
    local Managers = _G.Managers
    if not Managers or not Managers.font then return end
    local defs = Managers.font._font_definitions
    if not defs then return end
    
    if not defs[base_hash] then
        local Gui = _G.Gui
        local paths = { base_hash, "content/ui/fonts/darktide_custom_regular" }
        defs[base_hash] = { path = paths, render_flags = Gui.MultiLine + Gui.FormatDirectives }
        defs[base_hash .. "_no_render_flags"] = { path = paths }
        defs[base_hash .. "_masked"] = { path = paths, render_flags = Gui.MultiLine + Gui.Masked + Gui.FormatDirectives }
        defs[base_hash .. "_write_mask"] = { path = paths, render_flags = Gui.MultiLine + Gui.WriteMask + Gui.FormatDirectives }
    end
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

local function process_text_draw(self, text, font_size, font_type)
    if type(font_type) ~= "string" then 
        return font_size, font_type 
    end

    local font_info = get_custom_font_info(font_type)
    if not font_info then
        return font_size, font_type
    end
    
    if type(text) == "string" and (string.find(text, "\xee\x80") or string.find(text, "{#icon")) then
        return font_size, font_type
    end
    
    if mod:get("use_font_on_hud") == false and is_hud(self) then
        return font_size, font_type
    end

    local target_key = active_font
    if font_info.is_bold then target_key = active_font_bold end
    if font_info.is_mono then target_key = active_font_mono end
    
    local custom_font_type = font_type
    local loaded_hash = loaded_fonts[target_key]
    if loaded_hash and font_info.base_name then
        ensure_font_def(loaded_hash)
        custom_font_type = string.gsub(font_type, font_info.base_name, loaded_hash)
    end

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
    end

    return font_size, custom_font_type
end

mod:hook(UIRenderer, "script_draw_text", function(func, self, text, font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
    local final_size, final_font = process_text_draw(self, text, font_size, font_type)
    return func(self, text, final_size, final_font, gui_position, gui_size, color, options, retained_id, ...)
end)

mod:hook(UIRenderer, "script_draw_text_3d", function(func, self, text, font_size, font_type, ...)
    local final_size, final_font = process_text_draw(self, text, font_size, font_type)
    return func(self, text, final_size, final_font, ...)
end)

mod:hook(UIRenderer, "text_size", function(func, self, text, font_type, font_size, ...)
    local final_size, final_font = process_text_draw(self, text, font_size, font_type)
    return func(self, text, final_font, final_size, ...)
end)

mod:hook(UIRenderer, "styled_text_size", function(func, self, text, style, ...)
    local final_size, final_font = process_text_draw(self, text, style.font_size, style.font_type)
    
    local old_font = style.font_type
    local old_size = style.font_size
    
    style.font_type = final_font
    style.font_size = final_size
    
    local width, height, min, caret = func(self, text, style, ...)
    
    style.font_type = old_font
    style.font_size = old_size
    
    return width, height, min, caret
end)

mod:hook(UIRenderer, "text_height", function(func, self, text, font_type, font_size, ...)
    local final_size, final_font = process_text_draw(self, text, font_size, font_type)
    return func(self, text, final_font, final_size, ...)
end)
