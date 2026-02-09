players = {}
goals = {}

level_data = {
    -- 1-player
    {name = "goals (move: d-pad)", top_x=29, top_y=0, bot_x=39, bot_y=8, start="red"}, -- Reach the goals
    {name = "through the door", top_x=40, top_y=0, bot_x=50, bot_y=8, start="red"}, -- What a door is
    
    -- 2-player
    {name = "more of us (cycle: z)", top_x=51, top_y=0, bot_x=61, bot_y=10, start="red"}, -- Cycling between colors
    {name = "seek alignment (swap: x)", top_x=29, top_y=9, bot_x=41, bot_y=21, start="red"}, -- Horizontal Swapping
    {name = "above // below (swap: x)", top_x=0, top_y=54, bot_x=14, bot_y=63, start="red"}, -- Vertical Swapping
    {name = "we got this", top_x=0, top_y=26, bot_x=15, bot_y=31, start="red"}, -- Skill check: swapping/doors/goals
    {name = "pushback", top_x=42, top_y=11, bot_x=57, bot_y=21, start="red"}, -- How to "Pushback" a character through a corridor of doors
    {name = "sidelong", top_x=0, top_y=32, bot_x=12, bot_y=40, start="red"}, -- Move another character to their goal, ignore another
    -- {name = "TODO: drag-along", top_x=42, top_y=11, bot_x=57, bot_y=21, start="red"}, -- Teach "Drag-along"
    {name = "oroboros", top_x=0, top_y=13, bot_x=12, bot_y=25, start="red"}, -- Skill check: horizontal and vertical swapping
    
    -- 3-player
    {name = "they meet a third", top_x=0, top_y=41, bot_x=12, bot_y=53, start="red"}, -- Teach: strength of triad formation (all players aligned)
    {name = "and it gets interesting", top_x=13, top_y=13, bot_x=25, bot_y=21, start="red"}, -- Sidelong + Pushback
    {name = "fortress", top_x=0, top_y=0, bot_x=16, bot_y=12, start="red"}, -- Drag-along and triad
    -- {name = "where's red???...", top_x=16, top_y=55, bot_x=25, bot_y=63, start="blue"}, -- Teach: strength of triad formation (all players aligned)
    -- {name = "INC: a series of tubes", top_x=62, top_y=0, bot_x=74, bot_y=12, start="red"}, -- Teach no-swapping when in door regions
    -- {name = "INC: no clue", top_x=17, top_y=1, bot_x=27, bot_y=11, start="red"}, -- Enforce "nubbins"
    
    -- 4-player
    {name = "down in a hole", top_x=24, top_y=24, bot_x=34, bot_y=34, start="red"}, -- Re-check w/4 
}

function _init()
    current_level = 1
    load_level(current_level)
    local l_data = level_data[current_level]
    player = players[l_data.start]

    -- BUG: proceeds to the next level
    -- menuitem(1, "reset level", function()
    --     printh("reset level current_level: " ..current_level)
    --     current_level = current_level - 1
    --     if current_level < 1 then
    --         current_level = 1
    --     end
    --     goals = {}
    --     players = {}
    --     load_level(current_level)
    --     _, player = next(players)
    -- end)
end

function load_level(level_index)
    -- reset player position and other level-specific variables
	local l_data = level_data[level_index]
    local width = l_data.bot_x - l_data.top_x
    local height = l_data.bot_y - l_data.top_y
    for column = l_data.top_x,l_data.top_x+width do
        local relative_x = column - l_data.top_x
        for row = l_data.top_y,l_data.top_y+height do
            local relative_y = row - l_data.top_y
            local spr_at = mget(column, row)
            
            -- Read-in and add players to state from the map data
            if spr_at == 1 then
                mset(column, row, 0)
                players.red = { x = relative_x, y = relative_y, color = "red", sprite = 1, highlight = 47, perked = 2, target = 56}
            end
            if spr_at == 4 then
                mset(column, row, 0)
                players.blue = { x = relative_x, y = relative_y, color = "blue", sprite = 4, highlight = 46, perked = 5, target = 57}
            end
            if spr_at == 17 then
                mset(column, row, 0)
                players.yellow = { x = relative_x, y = relative_y, color = "yellow", sprite = 17, highlight = 48, perked = 18, target = 58}
            end

            if spr_at == 13 then
                mset(column, row, 0)
                players.green = { x = relative_x, y = relative_y, color = "green", sprite = 13, highlight = 49, perked = 14, target = 59}
            end
            
            -- Read-in and add goals to state from the map data
            if spr_at == 10 then
                goals.red = { x = relative_x, y = relative_y, color = "red", sprite = 10}
            end
            if spr_at == 11 then
                goals.blue = { x = relative_x, y = relative_y, color = "blue", sprite = 11}
            end
            if spr_at == 20 then
                goals.yellow = { x = relative_x, y = relative_y, color = "yellow", sprite = 20}
            end
            if spr_at == 16 then
                goals.green = { x = relative_x, y = relative_y, color = "green", sprite = 20}
            end
        end
    end
end

function _update()
	input()
	move()
    local won = check_win()
    if won then
        current_level += 1
        goals = {}
        players = {}
        load_level(current_level)
        local l_data = level_data[current_level]
        player = players[l_data.start]
    end
end

function check_win()
    local complete = true
    for c, p in pairs(players) do -- Currently forces all players to have a goal.
        if not equals(p, goals[c]) then
            complete = false
        end
    end
    return complete
end

function equals(a, b)
    if a and b then
        return a.color == b.color and a.x == b.x and a.y == b.y
    end
    return false
end

function input()
	nx = 0
	ny = 0
	if (btnp(0)) nx = -1
	if (btnp(1)) nx =  1
	if (btnp(2)) ny = -1
	if (btnp(3)) ny =  1
    if (btnp(4)) then
        -- R -> B -> G -> Y
        if player.color == "red" then
            if players.blue do
                player = players.blue
            elseif players.yellow do
                player = players.yellow
            elseif players.green do
                player = players.green
            else
                player = players.red
            end
        elseif player.color == "blue" then
            if players.green do
                player = players.green
            elseif players.yellow do
                player = players.yellow
            elseif players.red do
                player = players.red
            else
                player = players.blue
            end
        elseif player.color == "green" then
            if players.yellow do
                player = players.yellow
            elseif players.red do
                player = players.red
            elseif players.blue do
                player = players.blue
            else
                player = players.green
            end
        elseif player.color == "yellow" then
            if players.red do
                player = players.red
            elseif players.red do
                player = players.red
            elseif players.blue do
                player = players.blue
            elseif players.green do
                player = players.green
            else
                player = players.yellow
            end
        end
    end
    if (btnp(5)) then
        try_swap()
    end
end

function try_swap()
    local swapped = false
    for col, target in pairs(players) do
        if target.color == player.color then
            goto continue
        end
        -- Prevents players from swapping into a location they aren't allowed (like a wrong-color door)
        local target_okay = is_background(target.x, target.y, player.color)
        local player_okay = is_background(player.x, player.y, target.color)

        if (target.x == player.x) and (not swapped) and target_okay and player_okay then
            local target_y = target.y
            local player_y = player.y
            target.y = player_y
            player.y = target_y
            swapped = true
        elseif (target.y == player.y) and (not swapped)  and target_okay and player_okay then
            local target_x = target.x
            local player_x = player.x
            target.x = player_x
            player.x = target_x
            swapped = true
        end
        ::continue::
    end
end

function move()
	if nx == 0 and ny == 0 then
		return
	end
	npx = player.x + nx
	npy = player.y + ny
	if is_background(npx, npy, player.color) then
		player.x += nx
		player.y += ny
        -- for plyr_name, plyr in pairs(players) do
        --     printh(plyr_name.." ("..plyr.x..", "..plyr.y..")")
        -- end
	end
end

function is_background(x, y, color)
    local l_data = level_data[current_level]
    local check_for = players[color]
    local plyr_flags = fget(check_for.sprite)
    local spr_at = mget(l_data.top_x+x, l_data.top_y+y)
    local flags_at = fget(spr_at)
    return flags_at == 0 or flags_at == plyr_flags
end

function _draw()
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
                    if plyr.x == column or plyr.y == row do
                        if column == player.x and row == player.y do
                            -- No-op
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
    
    -- Players
    for plyr_name, plyr in pairs(players) do
        
        -- Perk up other characters when they can swap
        if plyr.color ~= player.color and (plyr.x == player.x or plyr.y == player.y) do
            spr(player.target, plyr.x*8, plyr.y*8)
            spr(plyr.perked, plyr.x*8, plyr.y*8)
        else
            spr(plyr.sprite, plyr.x*8, plyr.y*8)                    
        end
        
        -- Signify the current player
        if plyr.color == player.color then
            spr(12, plyr.x*8, (plyr.y-1)*8) 
        end
    end
end