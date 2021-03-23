-- defines all ore patches to be generated. Add as many clusters as
-- needed. Clusters listed first have a higher placement priority over
-- the latter clusters
--
-- TODO update and document all configuration settings
--
-- noise types:
--   cluster: same as vanilla factorio generation
--   skip: skips this cluster
--   connected_tendril: long ribbons of ore
--   fragmented_tendril: long ribbons of ore that occur when inside another
--       region of ribbons
--
-- noise source types and configurations
--   perlin: same as vanilla factorio generation
--     variance: increase to make patches closer together and smaller
--         note that this is the inverse of the cluster_mode variance
--     threshold: increase to shrink size of patches
--   simplex: similar to perlin
--   zero: does nothing with this source
--   one: adds the weight directly to the noise calculation
--
-- weights:  recommend having resource weights for each cluster add up to 1000
--           so that it is apparent that every 10 weight = 1%.  eg. weight 860 (86%) + weight 80 (8%) + weight 60 (6%) = 100%

local simplex_sources = {
    {variance=350, weight = 1.000, offset = 000, type="simplex"},
    {variance=200, weight = 0.350, offset = 150, type="simplex"},
    {variance=050, weight = 0.050, offset = 300, type="simplex"},
    {variance=020, weight = 0.015, offset = 450, type="simplex"},
}
local simplex_scarce_sources = {
    {variance=120, weight = 1.000, offset = 000, type="simplex"},
    {variance=060, weight = 0.300, offset = 150, type="simplex"},
    {variance=040, weight = 0.200, offset = 300, type="simplex"},
    {variance=020, weight = 0.090, offset = 450, type="simplex"},
}
local distances = {
    ['stone']       = 15,
    ['coal']        = 16,
    ['copper-ore']  = 18,
    ['tin-ore']     = 18,
    ['iron-ore']    = 64,   --not in starting area
    ['gold-ore']    = 64,   --not in starting area
--    ['uranium-ore'] = 86,
--    ['crude-oil']   = 57,
    ['iron-gem-ore']= 128,
    ['copper-gem-ore']= 128,
    ['gold-gem-ore']= 128,
    ['tin-gem-ore'] = 128,
    ['coal-gem-ore']= 128,
}


return {
    { -- tendril water 
        yield=1,
        min_distance=40,
        distance_richness=1,
        color={r=0/255, g=0/255, b=255/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.05,
            sources = {
                {variance=800, weight = 1.000, offset = 000, type="simplex"},
                {variance=350, weight = 0.350, offset = 150, type="simplex"},
                {variance=200, weight = 0.050, offset = 300, type="simplex"},
                {variance=050, weight = 0.015, offset = 450, type="simplex"},
            },
        },
        weights = {
            ['deepwater-green']    = 1000,
        },
        distances = {
            ['deepwater-green']    = 40
        },
    },
    { -- tendril medium impure coal
        yield=0.55,
        min_distance=25,
        distance_richness=11,
        color={r=0/255, g=0/255, b=0/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.03,
            sources = simplex_sources,
        },
        weights = {
            ['coal']        = 780,
            ['iron-ore']    = 160,
            ['stone']       = 50,
            ['coal-gem-ore']= 10,
        },
        distances = distances,
    },
    { -- tendril medium impure stone
        yield=0.38,
        min_distance=25,
        distance_richness=11,
        color={r=100/255, g=100/255, b=100/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.028,
            sources = simplex_sources,
        },
        weights = {
            ['stone']       = 790,
            ['copper-ore']  = 126,
            ['coal']        = 84,
        },
        distances = distances,
    },
    { -- tendril medium large impure copper
      -- 07/09/2000 start with a little less yeild near origin but grow in richness faster with distance
        yield=0.85,
        min_distance=25,
        distance_richness=6,
        color={r=255/255, g=55/255, b=0/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.05,
            sources = simplex_sources,
        },
        weights = {
            ['copper-ore']  = 890,
            ['coal']        = 61,
            ['stone']       = 39,
            ['copper-gem-ore']= 10,
        },
        distances = distances,
    },
    { -- tendril medium impure tin
        yield=0.7,
        min_distance=25,
        distance_richness=15,
        color={r=0.3, g=0.3, b=0.6},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.04,
            sources = simplex_sources,
        },
        weights = {
            ['tin-ore']     = 890,
            ['coal']        = 61,
            ['stone']       = 39,
            ['tin-gem-ore'] = 10,
        },
        distances = distances,
    },
    { -- tendril medium large impure iron
        yield=1.15,
        min_distance=64,
        distance_richness=9,
        color={r=0/255, g=140/255, b=255/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.05,
            sources = simplex_sources,
        },
        weights = {
            ['iron-ore']    = 893,
            ['coal']        = 61,
            ['stone']       = 39,
            ['iron-gem-ore']= 7,
        },
        distances = distances,
    },
    { -- tendril small gold 
        yield=0.25,
        min_distance=128,
        distance_richness=12,
        color={r=0.9, g=0.85, b=0.1},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.025,
            sources = simplex_scarce_sources,
        },
        weights = {
            ['gold-ore'] =  993,
            ['gold-gem-ore']= 7,
        },
        distances = distances,
    },
    { -- tendril small uranium
        yield=0.2,
        min_distance=128,
        distance_richness=12,
        color={r=0/255, g=0/255, b=0/255},
        noise_settings = {
            type = "connected_tendril",
            threshold = 0.025,
            sources = simplex_scarce_sources,
        },
        weights = {
            ['uranium-ore'] =  1,
        },
        distances = {
            ['uranium-ore'] = 86,
        },
    },
    { -- scattered tendril fragments
        yield=0.22,
        min_distance=10,
        distance_richness=12,
        color={r=0/255, g=0/255, b=0/255},
        noise_settings = {
            type = "fragmented_tendril",
            threshold = 0.06,
            discriminator_threshold = 1.2,
            sources = {
                {variance=025, weight = 1.000, offset = 600, type="simplex"},
                {variance=015, weight = 0.500, offset = 750, type="simplex"},
                {variance=010, weight = 0.250, offset = 900, type="simplex"},
                {variance=05, weight = 0.100, offset =1050, type="simplex"},
            },
            discriminator = {
                {variance=120, weight = 1.000, offset = 000, type="simplex"},
                {variance=060, weight = 0.300, offset = 150, type="simplex"},
                {variance=040, weight = 0.200, offset = 300, type="simplex"},
                {variance=020, weight = 0.090, offset = 450, type="simplex"},
            },
        },
        weights = {
            ['coal']        = 151,
            ['copper-ore']  = 201,
            ['iron-ore']    = 332,
            ['tin-ore']     = 132,
            ['gold-ore']    =  91,
            ['stone']       =  93,
        },
        distances = distances,
    },
    { -- crude oil
        yield=1.2,
        min_distance=57,
        distance_richness=9,
        color={r=0/255, g=255/255, b=255/255},
        noise_settings = {
            type = "cluster",
            threshold = 0.40,
            sources = {
                {variance=25, weight = 1, offset = 000, type="perlin"},
            },
        },
        weights = {
            ['skip']        = 990,
            ['crude-oil']   =  10,
        },
        distances = {
            ['crude-oil']   = 57,
        },
    },
}
