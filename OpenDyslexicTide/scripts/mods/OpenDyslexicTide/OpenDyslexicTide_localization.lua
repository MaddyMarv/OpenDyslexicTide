local mod = get_mod("OpenDyslexicTide")

return {
    mod_name = {
        en = "OpenDyslexicTide",
    },
    mod_description = {
        en = "Replaces the game's default fonts with OpenDyslexic.",
    },
    font_version = {
        en = "Font Version",
    },
    font_version_default = {
        en = "Default (Game Font)",
    },
    font_version_v3 = {
        en = "OpenDyslexic Version 3",
    },
    font_version_v2 = {
        en = "OpenDyslexic Version 2",
    },
    font_version_v1 = {
        en = "OpenDyslexic Regular",
    },
    use_font_on_hud = {
        en = "Use Font on HUD",
    },
    hud_font_scale = {
        en = "HUD Specific Scale (Multiplier)",
    },
    small_font_scale = {
        en = "Small Text Scale (<= 24)",
    },
    medium_font_scale = {
        en = "Medium Text Scale (25-35)",
    },
    large_font_scale = {
        en = "Large Text Scale (36-50)",
    },
    huge_font_scale = {
        en = "Huge Text Scale (> 50)",
    },
    tab_font_settings = {
        en = "Font Settings",
    },
    group_font_settings = {
        en = "Font Configuration",
    },
    disable_font_in_chat_input = {
        en = "Disable Font in Chat Input",
    },
    disable_font_in_chat_input_description = {
        en = "Keeps the game's default font and size in the chat typing field.",
    },
    disable_cjk_scaling = {
        en = "Full Scale for CJK Glyphs",
    },
    disable_cjk_scaling_description = {
        en = "Prevents Chinese, Japanese, and Korean characters from shrinking when font scale reduction is active.",
    },
    tab_high_contrast = {
        en = "High Contrast",
    },
    group_high_contrast = {
        en = "Text Background Boxes",
    },
    enable_high_contrast_bg = {
        en = "Enable Text Background Boxes",
    },
    enable_high_contrast_bg_description = {
        en = "Renders solid high-contrast black boxes behind all text elements for improved readability.",
    },
    high_contrast_opacity = {
        en = "Box Opacity (0 - 255)",
    },
    high_contrast_opacity_description = {
        en = "Alpha opacity of the background box (255 is fully solid black).",
    },
    high_contrast_padding_x = {
        en = "Horizontal Padding",
    },
    high_contrast_padding_x_description = {
        en = "Extra horizontal coverage (pixels) around letters to prevent clipping with wide font kerning.",
    },
    high_contrast_padding_y = {
        en = "Vertical Padding",
    },
    high_contrast_padding_y_description = {
        en = "Extra vertical coverage (pixels) around font ascenders and descenders.",
    },
    high_contrast_on_hud = {
        en = "Enable on General HUD",
    },
    high_contrast_on_hud_description = {
        en = "Renders background boxes behind general HUD text (ability icons, stamina, weapon counters, health/toughness meters).",
    },
    high_contrast_on_chat = {
        en = "Always on Chat Messages",
    },
    high_contrast_on_chat_description = {
        en = "Always renders background boxes behind chat messages, even when General HUD is disabled.",
    },
    high_contrast_on_killfeed = {
        en = "Always on Killfeed",
    },
    high_contrast_on_killfeed_description = {
        en = "Always renders background boxes behind killfeed and combat feed notifications, even when General HUD is disabled.",
    },
    high_contrast_on_world_markers = {
        en = "Always on World Markers",
    },
    high_contrast_on_world_markers_description = {
        en = "Always renders background boxes behind world markers (item pickups, player assistance, beacons, health bars), even when General HUD is disabled.",
    },
    high_contrast_on_pings = {
        en = "Always on Pings & Smart Tags",
    },
    high_contrast_on_pings_description = {
        en = "Always renders background boxes behind location pings, smart tag radial wheel, and enemy tags, even when General HUD is disabled.",
    },
    high_contrast_on_nameplates = {
        en = "Always on Nameplates",
    },
    high_contrast_on_nameplates_description = {
        en = "Always renders background boxes behind player and companion nameplates in-world, even when General HUD is disabled.",
    },
    high_contrast_on_interactions = {
        en = "Always on Interaction Prompts",
    },
    high_contrast_on_interactions_description = {
        en = "Always renders background boxes behind interactive world prompts (pickup, open chest, revive), even when General HUD is disabled.",
    },
    high_contrast_on_objectives = {
        en = "Always on Compass & Objectives",
    },
    high_contrast_on_objectives_description = {
        en = "Always renders background boxes behind compass waypoints, mission objectives, and area notifications, even when General HUD is disabled.",
    },
}
