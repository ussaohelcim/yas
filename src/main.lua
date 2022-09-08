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
import "gameStates"

import "game"


function MainMenu()
	local cinematic = Cinematic(
		{
			{
				image = playdate.graphics.image.new("assets/images/mainMenu"),
				-- sound = playdate.sound.sampleplayer.new("assets/sounds/egg.wav")
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

	EnterCinematicState(cinematic)
end


MainMenu()


--TODO criar um sprite para o fundo
--TODO checar se desenhar um rect redondo é mais rapido que um circle

--🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️

-- MUSICAS && sons

-- TODO musica ao morrer
-- musica diferente em cada nivel? talvez 2 ou 3 diferentes

-- FIXME reiniciar jogo ao morrer