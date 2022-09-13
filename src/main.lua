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

	print("ta no menu")

	playdate.update = cinematic.update
end

print("testing level5 with turretDumb as the last enemy")

MainMenu()

--🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️

-- MUSICAS && sons

-- musica diferente em cada nivel? talvez 2 ou 3 diferentes

--TODO voice acting
-- Its time to KILL (barulho de recarregando arma)
-- (barulho de riscando) that was easy
-- (barulho de riscando) damn, that was hard
-- its my pleasure (?)

-- FIXME tiros muito rapidos?
-- FIXME turret normal não é usado nenhuma vez
-- TODO arrumar uma maneira de não deixar o jogador ganhar parado
-- FIXME 2 dumbturrets é MUITO DIFICIL
-- FIXME diminuir tempo de spawn
-- TODO criar novo

-- TODO adicionar novas armas?
-- TODO adicionar dash
