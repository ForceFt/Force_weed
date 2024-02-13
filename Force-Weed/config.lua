Config = {}

Config.PickingItems = {
    [1] = {
        name = "raw_weed_skunk",
        threshold = 80,
        max = 1,
        remove = nil,
    },
}

Config.BaggingItems = {
    [1] = {
        name = "weed_skunk",
        threshold = 80,
        max = 5,
        remove = "raw_weed_skunk",
    },
}


Config.Picking = {
    {
        zones = { 
            vector2(2214.28, 5574.71),
            vector2(2214.69, 5580.0),
            vector2(2235.22, 5579.36),
            vector2(2234.75, 5573.2),
        },
        minz = 52.0,
        maxz = 55.0,
    },
}


Config.RednecksLocations = {
    ["Redneck1"] = {
        ["coords"] = vector4(2221.97, 5614.75, 54.9, 111.3),
        ["ped"] = 'a_m_m_farmer_01',
        ["gun"] = 'weapon_sawnoffshotgun',
    },
    ["Redneck2"] = {
        ["coords"] = vector4(2232.32, 5611.44, 54.91, 212.29),
        ["ped"] = 'cs_old_man2',
        ["gun"] = 'weapon_sawnoffshotgun',
    },
    ["Redneck3"] = {
        ["coords"] = vector4(2186.19, 5591.42, 54.06, 245.29),
        ["ped"] = 'cs_old_man1a',
        ["gun"] = 'weapon_sawnoffshotgun',
    },
    ["Redneck4"] = {
        ["coords"] = vector4(2223.13, 5559.92, 53.94, 25.87),
        ["ped"] = 'cs_old_man1a',
        ["gun"] = 'weapon_sawnoffshotgun',
    },

}

