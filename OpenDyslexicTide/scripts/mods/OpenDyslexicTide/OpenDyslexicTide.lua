local mod = get_mod("OpenDyslexicTide")

local SimpleAssets = get_mod("SimpleAssets")
local function apply_fonts()
    if not SimpleAssets then return end
    
    local font_version = mod:get("font_version") or "opendyslexic3"
    local source_font = "fonts/" .. font_version .. ".slug"
    local source_font_bold = "fonts/" .. font_version .. "-bold.slug"
    local source_font_mono = "fonts/opendyslexic-mono.slug"

    local engine_fonts = {
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
        "mono_tide_light"
    }

    for _, font_name in ipairs(engine_fonts) do
        local target_resource = "content/ui/fonts/" .. font_name .. ".slug"
        local replacement_font = source_font
        
        if string.find(font_name, "mono_tide") then
            replacement_font = source_font_mono
        elseif string.find(font_name, "bold") then
            replacement_font = source_font_bold
        end

        SimpleAssets.replace_font(target_resource, replacement_font):next(function(result)
        end):catch(function(err)
            mod:echo("OpenDyslexicTide Error: Failed to replace " .. font_name .. " - " .. tostring(err.error or "Unknown error"))
        end)
    end
end

function mod.on_all_mods_loaded()
    if not SimpleAssets then
        mod:echo("OpenDyslexicTide: SimpleAssets not found. Font replacement failed.")
    else
        apply_fonts()
    end
end

function mod.on_setting_changed(setting_id)
    if setting_id == "font_version" then
        apply_fonts()
    end
end

local UIRenderer = require("scripts/managers/ui/ui_renderer")

local function apply_font_scale(font_size)
    if type(font_size) ~= "number" then
        return font_size
    end

    local small = (mod:get("small_font_scale") or 100) / 100
    local medium = (mod:get("medium_font_scale") or 100) / 100
    local large = (mod:get("large_font_scale") or 100) / 100
    local huge = (mod:get("huge_font_scale") or 100) / 100

    if font_size <= 24 then
        return font_size * small
    elseif font_size <= 35 then
        return font_size * medium
    elseif font_size <= 50 then
        return font_size * large
    else
        return font_size * huge
    end
end

mod:hook(UIRenderer, "script_draw_text", function(func, self, text, font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
    local scaled_font_size = apply_font_scale(font_size)
    return func(self, text, scaled_font_size, font_type, gui_position, gui_size, color, options, retained_id, ...)
end)

mod:hook(UIRenderer, "script_draw_text_3d", function(func, self, text, font_size, ...)
    return func(self, text, apply_font_scale(font_size), ...)
end)

mod:hook(UIRenderer, "text_size", function(func, self, text, font_type, font_size, ...)
    return func(self, text, font_type, apply_font_scale(font_size), ...)
end)
