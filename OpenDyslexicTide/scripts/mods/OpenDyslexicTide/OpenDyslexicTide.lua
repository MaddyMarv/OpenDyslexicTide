local mod = get_mod("OpenDyslexicTide")

local SimpleAssets = get_mod("SimpleAssets")
if not SimpleAssets then
    mod:echo("OpenDyslexicTide: SimpleAssets not found. Font replacement failed.")
else
    local source_font = "fonts/opendyslexic3.slug"

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
        SimpleAssets.replace_font(target_resource, source_font):next(function(result)
        end):catch(function(err)
            mod:echo("OpenDyslexicTide Error: Failed to replace " .. font_name .. " - " .. tostring(err.error or "Unknown error"))
        end)
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
