Config = {}

--- Server type: single character per account (RPG).
--- On Register the player builds the character immediately and it is bound to the account.
--- On Login the player is put straight into that character.

Config.Debug = false

-- Validation rules for the Register form
Config.Username = { min = 3, max = 24, pattern = '^[%w_%.]+$' } -- letters, numbers, underscore, dot
Config.Password = { min = 6, max = 64 }
Config.EmailPattern = "^[%w%.%-_]+@[%w%.%-]+%.%a%a+$"

-- Password hashing (pure-lua PBKDF2-HMAC-SHA256, no external dependency).
-- Higher = more secure but slower. This runs on the (single-threaded) server Lua
-- during register/login only, so keep it modest. ~2000-4000 ≈ 100-250 ms.
Config.HashIterations = 2500

-- Where the hidden ped sits while the auth / creator UI is open
-- (re-using the qb-multicharacter preview interior so the world is loaded).
Config.HiddenCoords = vector4(-779.0154, 326.1801, 196.0860, 91.0454)

-- Scenic camera shown behind the blurred UI
Config.Camera = {
    coords = vector3(-763.1219, 326.8112, 202.0),
    rotation = vector3(-6.0, 0.0, 176.0),
    fov = 55.0,
}

-- Fixed spawn used for a freshly created character (RPG start point).
Config.NewCharacterSpawn = vector4(-1037.30, -2737.99, 20.16, 328.29) -- LSIA main entrance

-- Returning login behaviour.
--  true  = spawn where the player logged off (players.position), fallback to NewCharacterSpawn
--  false = always spawn at NewCharacterSpawn
Config.UseLastLocationOnLogin = true

-- Give qb-core StarterItems to a brand-new character
Config.GiveStarterItems = true
