Config = {}

Config.Debug = false

-- Ped preview position (inside the qb-multicharacter interior, world already streamed).
Config.PedCoords = vector4(-763.2816, 330.0418, 199.4865, 177.7942)

-- Camera framings around the preview ped
Config.Cameras = {
    body = { fromOffset = vector3(0.0, 2.4, 0.15),  pointOffset = vector3(0.0, 0.0, 0.05), fov = 42.0 },
    face = { fromOffset = vector3(0.0, 0.95, 0.62), pointOffset = vector3(0.0, 0.0, 0.62), fov = 24.0 },
    legs = { fromOffset = vector3(0.0, 1.9, -0.55), pointOffset = vector3(0.0, 0.0, -0.4),  fov = 38.0 },
}

-- Identity is NOT asked in the creator. The character name comes from the account
-- username (users.username); the fields below fill the rest of QBCore's charinfo.
Config.Character = {
    lastname = '',              -- appended after the username; '' = single-name character
    birthdate = '2000-01-01',   -- YYYY-MM-DD
    nationality = 'România',
}

-- Appearance limits (freemode peds). Ranges are clamped again by the game natives.
Config.Limits = {
    parent      = { min = 0,  max = 45 },  -- heritage mother / father face
    mix         = { min = 0,  max = 100 }, -- resemblance / skin-tone sliders (percent)
    hair        = { min = 0,  max = 80 },
    hairColor   = { min = 0,  max = 63 },
    eyebrows    = { min = -1, max = 33 },
    beard       = { min = -1, max = 28 },
    overlayColor = { min = 0, max = 63 },
    eyeColor    = { min = 0,  max = 31 },
}

-- Fixed default outfit per gender: t-shirt + trousers + sneakers.
-- Applied to the preview and saved with the character; there is no outfit step.
Config.DefaultOutfit = {
    male   = { torso = 0, undershirt = 15, top = 15, pants = 14, shoes = 21 }, -- comps 3 / 8 / 11 / 4 / 6
    female = { torso = 3, undershirt = 14, top = 14, pants = 15, shoes = 35 },
}

-- Starting look per gender (face / hair defaults the player can then tweak)
Config.Defaults = {
    male = {
        heritage = { mother = 0, father = 0, resemblance = 50, skinTone = 50 },
        hair = { style = 2, color = 8, highlight = 8 },
        eyebrows = { style = 5, color = 8 },
        beard = { style = -1, color = 8 },
        eyeColor = 0,
    },
    female = {
        heritage = { mother = 0, father = 0, resemblance = 50, skinTone = 50 },
        hair = { style = 3, color = 8, highlight = 8 },
        eyebrows = { style = 5, color = 8 },
        beard = { style = -1, color = 0 },
        eyeColor = 0,
    },
}

-- qb-clothing / playerskins compatible template. Only the keys the creator drives
-- are overwritten server-side; everything else stays at these neutral defaults so
-- qb-clothing's loadPlayerClothing keeps working when the player visits a store.
Config.SkinTemplate = {
    ['face']       = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['face2']      = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['facemix']    = { shapeMix = 0.5, skinMix = 0.5, defaultShapeMix = 0.5, defaultSkinMix = 0.5 },
    ['hair']       = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['eyebrows']   = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['beard']      = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['blush']      = { item = -1, texture = 1, defaultTexture = 1, defaultItem = -1 },
    ['lipstick']   = { item = -1, texture = 1, defaultTexture = 1, defaultItem = -1 },
    ['makeup']     = { item = -1, texture = 1, defaultTexture = 1, defaultItem = -1 },
    ['ageing']     = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['moles']      = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['eye_color']  = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['arms']       = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['t-shirt']    = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['torso2']     = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['vest']       = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['pants']      = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['shoes']      = { item = 1, texture = 0, defaultTexture = 0, defaultItem = 1 },
    ['mask']       = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['decals']     = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['accessory']  = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['bag']        = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['hat']        = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['glass']      = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['ear']        = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['watch']      = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['bracelet']   = { item = -1, texture = 0, defaultTexture = 0, defaultItem = -1 },
    ['nose_0'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['nose_1'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['nose_2'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['nose_3'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['nose_4'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['nose_5'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['eyebrown_high'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['eyebrown_forward'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['cheek_1'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['cheek_2'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['cheek_3'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['eye_opening'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['lips_thickness'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['jaw_bone_width'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['jaw_bone_back_lenght'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['chimp_bone_lowering'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['chimp_bone_lenght'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['chimp_bone_width'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['chimp_hole'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
    ['neck_thikness'] = { item = 0, texture = 0, defaultTexture = 0, defaultItem = 0 },
}
