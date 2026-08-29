Config = {}

Config.Debug = false

-- Radius (meters) in which the plain (unprefixed) local chat is heard.
Config.LocalRange = 18.0

-- Prepend a HH:MM timestamp to every line (like the reference HUD).
Config.Timestamps = true
Config.TimestampColor = '#8A8698'

-- What the [ID] segment shows:
--   'account' = users.id  (the SQL account id)
--   'server'  = the in-game server id (source)
Config.IdSource = 'account'

-- How colours are emitted into chat text:
--   'hex'   = ^#RRGGBB codes  (exact colours; needs a modern FiveM chat, 2021+)
--   'basic' = nearest ^0-^9 code  (works on every chat build, approximate colours)
-- If colours show up as literal text like "^#FFA64D", switch this to 'basic'.
Config.ColorMode = 'hex'

-- Fallback map for 'basic' mode: hex -> single FiveM colour code digit.
Config.BasicCodes = {
    ['#FFFFFF'] = '0', -- white   (local)
    ['#B57BFF'] = '6', -- purple  (premium text)
    ['#FFA64D'] = '8', -- orange  (admin text)
    ['#C85A00'] = '8', -- orange  (helper text)
    ['#5100FF'] = '6', -- Owner
    ['#DA9DFF'] = '6', -- Developer
    ['#FF0000'] = '1', -- Manager
    ['#00E1FF'] = '5', -- Head Staff
    ['#8F2AD1'] = '6', -- Lead Admin
    ['#FF6A00'] = '8', -- Admin group
    ['#37FF00'] = '2', -- Helper group
    ['#BBE070'] = '2', -- Premium
    ['#F6FF00'] = '3', -- VIP
    ['#C300FF'] = '6', -- Legend
}

-- Base text colour of each channel
Config.Channels = {
    localChat = { color = '#FFFFFF' },            -- white
    premium   = { color = '#B57BFF' },            -- purple / "mov"
    admin     = { color = '#FFA64D', prefix = '/a' },   -- light orange
    helper    = { color = '#C85A00', prefix = '/hc' },  -- dark orange
}

-- Staff ranks. `type` groups them:
--   'admin'  -> access to /a and /hc
--   'helper' -> access to /hc
--   nil/none -> not staff
Config.StaffRanks = {
    none         = { level = 0,  type = nil },
    trialhelper  = { level = 1,  type = 'helper' },
    helper       = { level = 2,  type = 'helper' },
    headhelper   = { level = 3,  type = 'helper' },
    trialadmin   = { level = 4,  type = 'admin'  },
    junioradmin  = { level = 5,  type = 'admin'  },
    generaladmin = { level = 6,  type = 'admin'  },
    headadmin    = { level = 7,  type = 'admin'  },
    leadadmin    = { level = 8,  type = 'admin'  },
    headstaff    = { level = 9,  type = 'admin'  },
    manager      = { level = 10, type = 'admin'  },
    developer    = { level = 11, type = 'admin'  },
    owner        = { level = 12, type = 'admin'  },
}

-- Exact [Grad] badge for /a and /hc  (rank -> label + colour)
Config.RankBadge = {
    owner        = { label = 'Owner',         color = '#5100FF' },
    developer    = { label = 'Developer',     color = '#DA9DFF' },
    manager      = { label = 'Manager',       color = '#FF0000' },
    headstaff    = { label = 'Head Staff',    color = '#00E1FF' },
    leadadmin    = { label = 'Lead Admin',    color = '#8F2AD1' },
    headadmin    = { label = 'Head Admin',    color = '#FF6A00' },
    generaladmin = { label = 'General Admin', color = '#FF6A00' },
    junioradmin  = { label = 'Junior Admin',  color = '#FF6A00' },
    trialadmin   = { label = 'Trial Admin',   color = '#FF6A00' },
    headhelper   = { label = 'Head Helper',   color = '#37FF00' },
    helper       = { label = 'Helper',        color = '#37FF00' },
    trialhelper  = { label = 'Trial Helper',  color = '#37FF00' },
}

-- [subscriptie] badge shown in /pc.
Config.PremiumBadge = {
    -- non-staff subscribers
    subscription = {
        premium = { label = 'Premium', color = '#BBE070' },
        vip     = { label = 'VIP',     color = '#F6FF00' },
        legend  = { label = 'Legend',  color = '#C300FF' },
    },
    -- staff members collapse into these groups (checked before subscription)
    staffGroup = {
        owner        = { label = 'Owner',      color = '#5100FF' },
        developer    = { label = 'Developer',  color = '#DA9DFF' },
        manager      = { label = 'Manager',    color = '#FF0000' },
        headstaff    = { label = 'Head Staff', color = '#00E1FF' },
        leadadmin    = { label = 'Lead Admin', color = '#8F2AD1' },
        headadmin    = { label = 'Admin',      color = '#FF6A00' },
        generaladmin = { label = 'Admin',      color = '#FF6A00' },
        junioradmin  = { label = 'Admin',      color = '#FF6A00' },
        trialadmin   = { label = 'Admin',      color = '#FF6A00' },
        headhelper   = { label = 'Helper',     color = '#37FF00' },
        helper       = { label = 'Helper',     color = '#37FF00' },
        trialhelper  = { label = 'Helper',     color = '#37FF00' },
    },
}

-- Valid subscription tiers (order = ascending)
Config.Subscriptions = { 'premium', 'vip', 'legend' }

-- Rank allowed to use /setstaff and /setsub in-game (besides the server console).
Config.ManageRank = 'owner'
