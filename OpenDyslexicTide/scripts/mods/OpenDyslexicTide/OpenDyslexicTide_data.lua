local mod = get_mod("OpenDyslexicTide")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "group_font_settings",
                type = "group",
                tab = mod:localize("tab_font_settings"),
                sub_widgets = {
                    {
                        setting_id = "font_version",
                        type = "dropdown",
                        default_value = "opendyslexic3",
                        options = {
                            { text = "font_version_default", value = "default" },
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
                        step_size_value = 5,
                    },
                    {
                        setting_id = "small_font_scale",
                        type = "numeric",
                        default_value = 80,
                        range = { 50, 150 },
                        decimals_number = 0,
                        step_size_value = 5,
                    },
                    {
                        setting_id = "medium_font_scale",
                        type = "numeric",
                        default_value = 80,
                        range = { 50, 150 },
                        decimals_number = 0,
                        step_size_value = 5,
                    },
                    {
                        setting_id = "large_font_scale",
                        type = "numeric",
                        default_value = 85,
                        range = { 50, 150 },
                        decimals_number = 0,
                        step_size_value = 5,
                    },
                    {
                        setting_id = "huge_font_scale",
                        type = "numeric",
                        default_value = 85,
                        range = { 50, 150 },
                        decimals_number = 0,
                        step_size_value = 5,
                    },
                    {
                        setting_id = "disable_font_in_chat_input",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "disable_cjk_scaling",
                        type = "checkbox",
                        default_value = true,
                    },
                },
            },
            {
                setting_id = "group_high_contrast",
                type = "group",
                tab = mod:localize("tab_high_contrast"),
                sub_widgets = {
                    {
                        setting_id = "enable_high_contrast_bg",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "high_contrast_opacity",
                        type = "numeric",
                        default_value = 230,
                        range = { 0, 255 },
                        decimals_number = 0,
                        step_size_value = 5,
                    },
                    {
                        setting_id = "high_contrast_padding_x",
                        type = "numeric",
                        default_value = 10,
                        range = { 0, 20 },
                        decimals_number = 0,
                        step_size_value = 1,
                    },
                    {
                        setting_id = "high_contrast_padding_y",
                        type = "numeric",
                        default_value = 2,
                        range = { 0, 15 },
                        decimals_number = 0,
                        step_size_value = 1,
                    },
                    {
                        setting_id = "high_contrast_on_hud",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "high_contrast_on_chat",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_killfeed",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_world_markers",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_pings",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_nameplates",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_interactions",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "high_contrast_on_objectives",
                        type = "checkbox",
                        default_value = true,
                    },
                },
            },
        },
    },
}
