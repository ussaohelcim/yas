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


function MainMenu()
	local cinematic = Cinematic(
		{
			{
				image = playdate.graphics.image.new("assets/images/mainMenu"),
				sound = playdate.sound.sampleplayer.new("assets/sounds/mainMenu.wav"),
				loopSound = true
			},
			{
				image = playdate.graphics.image.new("assets/images/begin")
			},
			{
				image = playdate.graphics.image.new("assets/images/ok"),
				-- sound = playdate.sound.sampleplayer.new("assets/sounds/egg.wav")
			},
		},
		NewGame
	)

	print("on menu", collectgarbage("count"))

	playdate.update = cinematic.update
end

print("testing memory leak on new game")

MainMenu()

--🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️

-- musica diferente em cada nivel? talvez 2 ou 3 diferentes

--TODO voice acting
-- Its time to KILL (barulho de recarregando arma)
-- (barulho de riscando) that was easy
-- (barulho de riscando) damn, that was hard
-- its my pleasure (?)

-- TODO criar sprites para a caixa de arma

-- FIXME utilizar funcoes locais todo onde

-- FIXME aparentemente, sempre que reinicia o jogo aloca mais memoria (acho que so ocorre com o malloc log ligado)
