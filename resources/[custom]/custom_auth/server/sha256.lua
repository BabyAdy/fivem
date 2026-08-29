--[[
    Pure-Lua SHA-256 + HMAC-SHA256 + PBKDF2-HMAC-SHA256.
    Self-contained, no native crypto / external resource required.
    Requires Lua 5.4 (fxmanifest: lua54 'yes') for native bitwise operators.

    Exposes a global table `Hash` used by server/main.lua.

    Storage format for the users.password column:
        pbkdf2$sha256$<iterations>$<saltHex>$<derivedKeyHex>
]]

local MASK = 0xFFFFFFFF

local function rrot(x, n)
    return ((x >> n) | (x << (32 - n))) & MASK
end

local K = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function sha256_bin(msg)
    local h0, h1, h2, h3 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
    local h4, h5, h6, h7 = 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19

    local bitLen = #msg * 8
    msg = msg .. '\128'
    while (#msg % 64) ~= 56 do msg = msg .. '\0' end
    local hi = (bitLen // 0x100000000) & MASK
    local lo = bitLen & MASK
    msg = msg .. string.char(
        (hi >> 24) & 0xff, (hi >> 16) & 0xff, (hi >> 8) & 0xff, hi & 0xff,
        (lo >> 24) & 0xff, (lo >> 16) & 0xff, (lo >> 8) & 0xff, lo & 0xff
    )

    local w = {}
    for chunkStart = 1, #msg, 64 do
        local bytes = { string.byte(msg, chunkStart, chunkStart + 63) }
        for i = 0, 15 do
            local b = i * 4
            w[i] = ((bytes[b + 1] << 24) | (bytes[b + 2] << 16) | (bytes[b + 3] << 8) | bytes[b + 4]) & MASK
        end
        for i = 16, 63 do
            local x = w[i - 15]
            local s0 = rrot(x, 7) ~ rrot(x, 18) ~ (x >> 3)
            local y = w[i - 2]
            local s1 = rrot(y, 17) ~ rrot(y, 19) ~ (y >> 10)
            w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & MASK
        end

        local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
        for i = 0, 63 do
            local S1 = rrot(e, 6) ~ rrot(e, 11) ~ rrot(e, 25)
            local ch = (e & f) ~ ((~e & MASK) & g)
            local temp1 = (h + S1 + ch + K[i + 1] + w[i]) & MASK
            local S0 = rrot(a, 2) ~ rrot(a, 13) ~ rrot(a, 22)
            local maj = (a & b) ~ (a & c) ~ (b & c)
            local temp2 = (S0 + maj) & MASK
            h = g; g = f; f = e
            e = (d + temp1) & MASK
            d = c; c = b; b = a
            a = (temp1 + temp2) & MASK
        end

        h0 = (h0 + a) & MASK; h1 = (h1 + b) & MASK; h2 = (h2 + c) & MASK; h3 = (h3 + d) & MASK
        h4 = (h4 + e) & MASK; h5 = (h5 + f) & MASK; h6 = (h6 + g) & MASK; h7 = (h7 + h) & MASK
    end

    local function w2s(n)
        return string.char((n >> 24) & 0xff, (n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff)
    end
    return w2s(h0) .. w2s(h1) .. w2s(h2) .. w2s(h3) .. w2s(h4) .. w2s(h5) .. w2s(h6) .. w2s(h7)
end

local function toHex(bin)
    return (bin:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
end

local function fromHex(hex)
    return (hex:gsub('%x%x', function(cc) return string.char(tonumber(cc, 16)) end))
end

local function hmac_sha256(key, message)
    if #key > 64 then key = sha256_bin(key) end
    key = key .. string.rep('\0', 64 - #key)
    local opad, ipad = {}, {}
    for i = 1, 64 do
        local byte = string.byte(key, i)
        opad[i] = string.char(byte ~ 0x5c)
        ipad[i] = string.char(byte ~ 0x36)
    end
    return sha256_bin(table.concat(opad) .. sha256_bin(table.concat(ipad) .. message))
end

local function pbkdf2_sha256(password, salt, iterations, dkLen)
    dkLen = dkLen or 32
    local blocks = math.ceil(dkLen / 32)
    local out = {}
    for i = 1, blocks do
        local u = hmac_sha256(password, salt .. string.char(
            (i >> 24) & 0xff, (i >> 16) & 0xff, (i >> 8) & 0xff, i & 0xff))
        local t = { string.byte(u, 1, 32) }
        for _ = 2, iterations do
            u = hmac_sha256(password, u)
            local ub = { string.byte(u, 1, 32) }
            for j = 1, 32 do t[j] = t[j] ~ ub[j] end
        end
        for j = 1, 32 do out[#out + 1] = string.char(t[j]) end
    end
    return table.concat(out):sub(1, dkLen)
end

math.randomseed(os.time() + (GetGameTimer and GetGameTimer() or 0))

local function randomSalt(bytes)
    bytes = bytes or 16
    local t = {}
    for i = 1, bytes do t[i] = string.char(math.random(0, 255)) end
    return table.concat(t)
end

local function equal(a, b)
    if #a ~= #b then return false end
    local diff = 0
    for i = 1, #a do diff = diff | (string.byte(a, i) ~ string.byte(b, i)) end
    return diff == 0
end

Hash = {}

--- Create a storable hash string for a plaintext password.
function Hash.create(password, iterations)
    iterations = iterations or 6000
    local salt = randomSalt(16)
    local dk = pbkdf2_sha256(password, salt, iterations, 32)
    return string.format('pbkdf2$sha256$%d$%s$%s', iterations, toHex(salt), toHex(dk))
end

--- Verify a plaintext password against a stored hash string.
function Hash.verify(password, stored)
    if type(stored) ~= 'string' then return false end
    local algo, _, iterStr, saltHex, dkHex = stored:match('^(pbkdf2)%$(sha256)%$(%d+)%$(%x+)%$(%x+)$')
    if not algo then
        -- Legacy fallback: plain SHA-256 hex (old stub used SHA2 in SQL)
        return toHex(sha256_bin(password)) == stored
    end
    local expected = fromHex(dkHex)
    local dk = pbkdf2_sha256(password, fromHex(saltHex), tonumber(iterStr), #expected)
    return equal(dk, expected)
end

function Hash.sha256Hex(str) return toHex(sha256_bin(str)) end
