Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = {}

Config.Locale = "nl"

Config.NotificationType = { --[ 'esx' / 'qbus' / 'mythic_old' / 'mythic_new' / 'chat' / 'other' ] Choose your notification script.
    client = 'mythic_new' 
}

-- mysqlasync
-- oxmysql

Config.MYSQLUsage = "mysqlasync"

--Linden_inventory = linden
--br-menu = br-menu
--ESX Menu = esx(W.I.P)

Config.UseMenu = "br-menu"

Config.ZOffset = 1000

-- Webhook --
Config.WebHook = "https://discord.com/api/webhooks/872867340654628915/RtQc6LQz71QoVV1j2OOFkV51bwgLr7zxe7tkLZvPlP973JDV5aRyiypXn312OSfovsfo"

-- Offsets --

Config.Offsets = { -- PAS HIER NIET ZOMAAR WAT AAN ALLEEN ALS JE WEET WAT JE DOET!
    ['stashhouse1_shell'] = {
        exitloods = {x =21.720528, y = -0.470337, z = -2.062134, 		text = "[~g~E~w~] · Verlaten",  usage = true},
		laptop = {x = -2.882645, y = 7.151733, z = -2.060783, 			text = "[~g~E~w~] · Laptop", 	usage = true},
		computer = {x = -13.084320, y = 7.862427, z = -2.060783,		text = "[~g~E~w~] · Computer", 	usage = false}, -- SOON
		crafting = {x = -13.084320, y = 7.862427, z = -2.060783,		text = "[~g~E~w~] · Crafting", 	usage = false}, -- SOON
		opslag = {x = -19.200275, y = 1.087158, z = -2.060783,			text = "[~g~E~w~] · Opslag", 	usage = true},
		garage = {x = 15.068146, y = -0.265625, z = -2.060875,			text = "[~g~E~w~] · Garage", 	usage = true}
    },
    ['stashhouse3_shell'] = {
		upgradeto = 'stashhouse1_shell',
        exitloods = {x = -0.005981445, y = -5.400391, z = 26.95317,		text = "[~g~E~w~] · Verlaten", 	usage = true},
    },
    ['container2_shell'] = {
		upgradeto = 'stashhouse3_shell',
        exitloods = {x = -0.03210449, y = 5.44165,z = 28.87602,			text = "[~g~E~w~] · Verlaten"},
    }
}

-- Garage

Config.Garage = {
	{label = 'DAGGER', value = 'dagger', gang = 'cityangels', job_grade = -1},
}

-- Locale

function _(str, ...)  -- Translate string

	if Locales[Config.Locale] ~= nil then

		if Locales[Config.Locale][str] ~= nil then
			return string.format(Locales[Config.Locale][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end