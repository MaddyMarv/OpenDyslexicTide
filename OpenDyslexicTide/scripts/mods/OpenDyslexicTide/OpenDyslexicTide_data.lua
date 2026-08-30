local mod = get_mod("OpenDyslexicTide")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "font_version",
                type = "dropdown",
                default_value = "opendyslexic3",
                options = {
                    { text = "font_version_v3", value = "opendyslexic3" },
                    { text = "font_version_v2", value = "opendyslexic2" },
                    { text = "font_version_v1", value = "opendyslexic" },
                },
            },
            {
                setting_id = "use_font_on_hud",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "hud_font_scale",
                type = "numeric",
                default_value = 100,
                range = { 50, 150 },
                decimals_number = 0,
            },
            {
                setting_id = "small_font_scale",
                type = "numeric",
                default_value = 75,
                range = { 50, 150 },
                decimals_number = 0,
            },
            {
                setting_id = "medium_font_scale",
                type = "numeric",
                default_value = 70,
                range = { 50, 150 },
                decimals_number = 0,
            },
            {
                setting_id = "large_font_scale",
                type = "numeric",
                default_value = 72,
                range = { 50, 150 },
                decimals_number = 0,
            },
            {
                setting_id = "huge_font_scale",
                type = "numeric",
                default_value = 85,
                range = { 50, 150 },
                decimals_number = 0,
            },
        },
    },
}
