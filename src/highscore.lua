local password = "hahaha"
local website = "https://18945641561631/"

function HighscoreLink(content)
	--content é uma table

	local params = Encrypt(password,content)

	

	return website..params
end

function Encrypt(password,content)
	return ""
end