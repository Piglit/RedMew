local ob = require 'map_gen.maps.crash_site.outpost_builder'
local Token = require 'utils.token'

local loot = {
    {weight = 10},
    {stack = {name = 'coin', count = 50, distance_factor = 1 / 20}, weight = 5},
    {stack = {name = 'crude-oil-barrel', count = 100, distance_factor = 1 / 20}, weight = 5},
    {stack = {name = 'heavy-oil-barrel', count = 100, distance_factor = 1 / 20}, weight = 2},
    {stack = {name = 'light-oil-barrel', count = 100, distance_factor = 1 / 20}, weight = 2},
    {stack = {name = 'petroleum-gas-barrel', count = 100, distance_factor = 1 / 20}, weight = 5},
    {stack = {name = 'lubricant-barrel', count = 100, distance_factor = 1 / 20}, weight = 1},
    {stack = {name = 'sulfuric-acid-barrel', count = 100, distance_factor = 1 / 20}, weight = 1}
}

local weights = ob.prepare_weighted_loot(loot)

local loot_callback =
    Token.register(
    function(chest)
        ob.do_random_loot(chest, weights, loot)
    end
)

local fluid_loot = {
    {weight = 5},
    {stack = {name = 'crude-oil', count = 12500, distance_factor = 5}, weight = 10}
}

local fluid_weights = ob.prepare_weighted_loot(fluid_loot)

local fluid_loot_callback =
    Token.register(
    function(chest)
        ob.do_random_fluid_loot(chest, fluid_weights, fluid_loot)
    end
)

local factory = {
    callback = ob.magic_item_crafting_callback,
    data = {
        recipe = 'basic-oil-processing',
        has_fluid_output = true,
        output = {
            {min_rate = 4.5 / 60, distance_factor = 4.5 / 60 / 512, item = 'petroleum-gas', fluidbox_index = 2}
        }
    }
}

local market = {
    callback = ob.market_set_items_callback,
    data = {
        market_name = 'Small Oil Refinery',
        upgrade_rate = 0.5,
        upgrade_base_cost = 150,
        upgrade_cost_base = 2,
        {
            name = 'crude-oil-barrel',
            price = 10,
            distance_factor = 5 / 512,
            min_price = 1
        },
        {
            name = 'heavy-oil-barrel',
            price = 15,
            distance_factor = 7.5 / 512,
            min_price = 1.5
        },
        {
            name = 'light-oil-barrel',
            price = 20,
            distance_factor = 10 / 512,
            min_price = 2
        },
        {
            name = 'petroleum-gas-barrel',
            price = 25,
            distance_factor = 12.5 / 512,
            min_price = 2.5
        },
        {
            name = 'lubricant-barrel',
            price = 15,
            distance_factor = 7.5 / 512,
            min_price = 1.5
        },
        {
            name = 'sulfuric-acid-barrel',
            price = 40,
            distance_factor = 20 / 512,
            min_price = 4
        }
    }
}

local base_factory = require 'map_gen.maps.crash_site.outpost_data.small_refinery'
local storage_tank = require 'map_gen.maps.crash_site.outpost_data.storage_tank_block'

local level2 = ob.extend_1_way(base_factory[1], {loot = {callback = loot_callback}})

local level2b =
    ob.extend_1_way(
    storage_tank,
    {
        tank = {callback = fluid_loot_callback},
        fallback = level2,
        max_count = 2
    }
)

local level3 =
    ob.extend_1_way(
    base_factory[2],
    {
        factory = factory,
        max_count = 2,
        fallback = level2b
    }
)
local level4 =
    ob.extend_1_way(
    base_factory[3],
    {
        market = market,
        fallback = level3
    }
)
return {
    settings = {
        blocks = 6,
        variance = 3,
        min_step = 2,
        max_level = 2
    },
    walls = {
        require 'map_gen.maps.crash_site.outpost_data.light_flame_turrets'
    },
    bases = {
        {level4, level2}
    }
}
