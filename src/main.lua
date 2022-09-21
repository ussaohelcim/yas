import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "utils"

import "cinematic"

import "menu"
import "timedFunctions"
import "bullets"
import "enemies"
import "player"

import "levels"

import "game"


local mainMusic = playdate.sound.sampleplayer.new("assets/sounds/mainMenu.wav")

mainMusic:setVolume(0.6)

function MainMenu()
	local cinematic = Cinematic(
		{
			{
				image = playdate.graphics.image.new("assets/images/mainMenu"),
				sound = mainMusic,
				loopSound = true
			},
			{
				image = playdate.graphics.image.new("assets/images/begin")
			},
			{
				image = playdate.graphics.image.new("assets/images/ok"),
			},
		},
		NewGame
	)

	print("on menu", collectgarbage("count"))

	playdate.update = cinematic.update
end

MainMenu()

--🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️

-- FIXME aparentemente, sempre que reinicia o jogo aloca mais memoria (acho que so ocorre com o malloc log ligado)

-- FIXME impossibilitar de andar durante cinematicas
