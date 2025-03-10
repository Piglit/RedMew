local Declare = require 'utils.test.declare'
local EventFactory = require 'utils.test.event_factory'
local Assert = require 'utils.test.assert'
local Helper = require 'utils.test.helper'
local Settings = require 'utils.redmew_settings'
local CorpseUtil = require 'features.corpse_util'
local DeathCorpseTags = require 'features.death_corpse_tags'

local function test_teardown(context)
    context:add_teardown(CorpseUtil.clear)
end

local function declare_test(name, func)
    local function test_func(context)
        test_teardown(context)
        func(context)
    end

    Declare.test(name, test_func)
end

Declare.module({'features', 'death_corpse_tags'}, function()
    local teardown

    Declare.module_startup(function(context)
        teardown = Helper.startup_test_surface(context)

        -- wait for surface to be charted, needed before a tag can be created.
        context:next(function()
            local player = context.player
            Helper.wait_for_chunk_to_be_charted(context, player.force, player.surface, {0, 0})
        end)
    end)

    Declare.module_teardown(function()
        teardown()
    end)

    local function change_settings_for_test(context, key, value)
        local player_index = context.player.index

        local current_value = Settings.get(player_index, key)
        Settings.set(player_index, key, value)

        context:add_teardown(function()
            Settings.set(player_index, key, current_value)
        end)
    end

    local function fake_death(player, has_items)
        local surface = player.surface
        local position = player.position

        local entity = surface.create_entity {
            name = 'character-corpse',
            position = position,
            player_index = player.index,
            inventory_size = has_items and 1 or nil
        }

        if not entity or not entity.valid then
            error('no corpse')
        end

        if has_items then
            local inventory = entity.get_inventory(defines.inventory.character_corpse)
            inventory.insert('iron-plate')
        end

        return EventFactory.on_player_died(player.index)
    end

    declare_test('ping player corpse location when died', function(context)
        -- Arrange.
        local player = context.player

        local actual_text

        Helper.modify_lua_object(context, player, 'print', function(text)
            actual_text = text
        end)

        Helper.modify_lua_object(context, game, 'get_player', function()
            return player
        end)

        local event = fake_death(player, true)

        -- Act.
        DeathCorpseTags._player_died(event)

        -- Assert.
        local expected = {'death_corpse_tags.own_corpse_location', '0.0', '0.0', player.surface.name}
        Assert.table_equal(expected, actual_text)
    end)

    declare_test('ping other player corpse location when other player died', function(context)
        -- Arrange.
        local player = context.player
        local force = player.force

        local actual_text

        local second_player = {
            index = 2,
            valid = true,
            name = 'second_player',
            surface = player.surface,
            force = force,
            print = function()
            end,
            position = EventFactory.position({1, 1})
        }

        change_settings_for_test(context, DeathCorpseTags.ping_other_death_name, true)

        Helper.modify_lua_object(context, game, 'get_player', function(index)
            if index == player.index then
                return player
            end

            if index == second_player.index then
                return second_player
            end
        end)

        Helper.modify_lua_object(context, force, 'players', {player, second_player})

        Helper.modify_lua_object(context, player, 'print', function(text)
            actual_text = text
        end)

        local event = fake_death(second_player, true)

        -- Act.
        DeathCorpseTags._player_died(event)

        -- Assert.
        local expected = {'death_corpse_tags.other_corpse_location', second_player.name, '1.0', '1.0', player.surface.name}
        Assert.table_equal(expected, actual_text)
    end)

    declare_test('do not ping player corpse location when died and setting disabled', function(context)
        -- Arrange.
        local player = context.player
        change_settings_for_test(context, DeathCorpseTags.ping_own_death_name, false)

        local actual_text

        Helper.modify_lua_object(context, player, 'print', function(text)
            actual_text = text
        end)

        Helper.modify_lua_object(context, game, 'get_player', function()
            return player
        end)

        local event = fake_death(player, true)

        -- Act.
        DeathCorpseTags._player_died(event)

        -- Assert.
        Assert.is_nil(actual_text)
    end)

    declare_test('do not ping other player corpse location when other player died and settings disabled',
        function(context)
            -- Arrange.
            local player = context.player
            local force = player.force

            local actual_text

            local second_player = {
                index = 2,
                valid = true,
                name = 'second_player',
                surface = player.surface,
                force = force,
                print = function()
                end,
                position = EventFactory.position({1, 1})
            }

            change_settings_for_test(context, DeathCorpseTags.ping_other_death_name, false)

            Helper.modify_lua_object(context, game, 'get_player', function(index)
                if index == player.index then
                    return player
                end

                if index == second_player.index then
                    return second_player
                end
            end)

            Helper.modify_lua_object(context, force, 'players', {player, second_player})

            Helper.modify_lua_object(context, player, 'print', function(text)
                actual_text = text
            end)

            local event = fake_death(second_player, true)

            -- Act.
            DeathCorpseTags._player_died(event)

            -- Assert.
            Assert.is_nil(actual_text)
        end)

    declare_test('do not ping other player corpse location for self', function(context)
        -- Arrange.
        local player = context.player
        local force = player.force

        local actual_text

        change_settings_for_test(context, DeathCorpseTags.ping_own_death_name, false)
        change_settings_for_test(context, DeathCorpseTags.ping_other_death_name, true)

        Helper.modify_lua_object(context, game, 'get_player', function()
            return player
        end)

        Helper.modify_lua_object(context, player, 'force', force)
        Helper.modify_lua_object(context, force, 'players', {player})

        Helper.modify_lua_object(context, player, 'print', function(text)
            actual_text = text
        end)

        local event = fake_death(player, true)

        -- Act.
        DeathCorpseTags._player_died(event)

        -- Assert.
        Assert.is_nil(actual_text)
    end)

    declare_test('corpse removed and empty message when corpse is empty', function(context)
        -- Arrange.
        local player = context.player
        player.teleport({5, 5})

        context:add_teardown(function()
            player.teleport({0, 0})
        end)

        local actual_text

        Helper.modify_lua_object(context, player, 'print', function(text)
            actual_text = text
        end)

        Helper.modify_lua_object(context, game, 'get_player', function()
            return player
        end)

        local event = fake_death(player, false)

        -- Act.
        DeathCorpseTags._player_died(event)

        -- Assert.
        local corpses = player.surface.find_entities_filtered({name = 'character-corpse', position = player.position, radius = 1})
        Assert.equal(0, #corpses)

        local expected = {'death_corpse_tags.empty_corpse'}
        Assert.table_equal(expected, actual_text)
    end)
end)
