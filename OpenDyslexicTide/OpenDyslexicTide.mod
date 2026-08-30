return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`OpenDyslexicTide` mod must be lower than DMF in load order.")

		new_mod("OpenDyslexicTide", {
			mod_script       = "OpenDyslexicTide/scripts/mods/OpenDyslexicTide/OpenDyslexicTide",
			mod_data         = "OpenDyslexicTide/scripts/mods/OpenDyslexicTide/OpenDyslexicTide_data",
			mod_localization = "OpenDyslexicTide/scripts/mods/OpenDyslexicTide/OpenDyslexicTide_localization",
		})
	end,
	packages = {},
}
