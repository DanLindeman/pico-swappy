players = {}
goals = {}
hints = {}
reading = false
game_complete = false
players_on_goals = 0
tones = {7, 8, 9, 10}
just_swapped = false

hud = {
    draw = function(self)
        local l_data = level_data[current_level]
        print("- "..l_data.name.." - "..current_level.."/"..#level_data, 0, 120, 7)
    end
}

function _init()
    current_level = 1
    load_level(current_level)
    -- sfx(2)
    local l_data = level_data[current_level]
    player = players[l_data.start]
    focus:init()

    -- BUG: proceeds to the next level
    menuitem(1, "reset level", function()
        goals = {}
        players = {}
        hints = {}
        reload()
        load_level(current_level)
        local l_data = level_data[current_level]
        player = players[l_data.start]
        focus:init()
    end)
end

function _update()
    if not game_complete then
        local won = check_win()
        controller:input()
        dialog:update()
        focus:update()
        if won then
            -- Freeze input and play a jingle
            sfx(2)
            for i=1,60 do
                flip()
            end
            current_level += 1
            if current_level > get_table_size(level_data) then
                current_level = 1
                game_complete = true
            end
            goals = {}
            players = {}
            hints = {}
            load_level(current_level)
            local l_data = level_data[current_level]
            player = players[l_data.start]
            focus:init()
        end
    end
end

function check_win()
    local complete = true
    local l_data = level_data[current_level]
    local plyr_count = l_data.player_count
    local pogs = 0 -- local players_on_goals
    for c, p in pairs(players) do -- Currently forces all players to have a goal.
        if not on_goal(p, goals[c]) then
            complete = false
        else
            pogs+=1
        end
    end
    
    -- TODO: Fix
    -- if pogs > players_on_goals then -- someone stepped on since last check
    --     sfx(tones[pogs])
    --     -- players_on_goals = pogs
    -- end

    return complete
end

function on_goal(a, b)
    if a and b then
        return a.color == b.color and a.x == b.x and a.y == b.y
    end
    return false
end

function get_table_size(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function _draw()
    if not game_complete then
        cls(0)
        local l_data = level_data[current_level]
        local width = l_data.bot_x - l_data.top_x
        local height = l_data.bot_y - l_data.top_y
        print("- "..l_data.name.." -", 0, 120, 7)

        -- Background
        for plyr_name, plyr in pairs(players) do
            -- Cast out "highlights" from the active player
            if plyr.color == player.color then            
                -- BUG: Not under other players
                for column = 0,width do
                    for row = 0,height do
                        if plyr.x == column or plyr.y == row then
                            if column == player.x and row == player.y then
                                -- Don't draw a highlight under the current player
                            else
                                spr(plyr.highlight,column*8, row*8)
                            end
                        end
                    end
                end
            end
        end
        
        -- Map
        map(l_data.top_x, l_data.top_y, 0, 0, width+1, height+1)
        
        -- Draw the dialog on top of the map
        dialog:draw()
        
        -- Players
        for plyr_name, plyr in pairs(players) do
            
            -- Perk up other characters when they can swap
            if plyr.color ~= player.color and (plyr.x == player.x or plyr.y == player.y) then
                spr(player.target, plyr.x*8, plyr.y*8)
                spr(plyr.perked, plyr.x*8, plyr.y*8)
            elseif plyr.color == player.color then
                spr(plyr.sprite, plyr.x*8, plyr.y*8)
            else
                spr(plyr.inactive, plyr.x*8, plyr.y*8)
            end
        end
        focus:draw()
    else
        -- Show THE END screen
        cls(0)
        map(115, 52, 0, 0, 13, 12)
    end
    hud:draw()
end