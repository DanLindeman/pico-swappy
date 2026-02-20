level_data = {
    -- 1-player
    {name = "nubbins", top_x=17, top_y=0, bot_x=27, bot_y=12, start="red", player_count=3}, -- Enforce "nubbins"
    {name = "tower's top", top_x=29, top_y=0, bot_x=39, bot_y=8, start="red", hint="head to the stairway that matches your color.", player_count=1}, -- Reach the goals
    {name = "through the door", top_x=40, top_y=0, bot_x=50, bot_y=8, start="red", hint="you can walk through a door if you match its color.", player_count=1}, -- What a door is
    
    -- 2-player
    {name = "more of us", top_x=51, top_y=0, bot_x=61, bot_y=10, start="red", hint="change characters by pressing z, get all characters to their stairway.", player_count=2}, -- Cycling between colors
    {name = "seek alignment", top_x=29, top_y=9, bot_x=41, bot_y=21, start="red", hint="if two characters are aligned horizontally, you can swap them with x.", player_count=2}, -- Horizontal Swapping
    {name = "above // below", top_x=0, top_y=54, bot_x=14, bot_y=63, start="red", hint="if two characters are aligned vertically, you can swap them with x.", player_count=2}, -- Vertical Swapping
    {name = "we got this", top_x=0, top_y=26, bot_x=15, bot_y=31, start="red", player_count=2}, -- Skill check: swapping/doors/goals
    {name = "pushback", top_x=42, top_y=11, bot_x=57, bot_y=21, start="red", player_count=2}, -- Teach: How to "Pushback" a character through a corridor of doors
    {name = "sidelong", top_x=0, top_y=32, bot_x=12, bot_y=40, start="red", player_count=2}, -- Teach: stranding. Move another character to their goal, ignore another
    {name = "oroboros", top_x=0, top_y=13, bot_x=12, bot_y=25, start="red", player_count=2}, -- Skill check: horizontal and vertical swapping
    {name = "snakey", top_x=75, top_y=0, bot_x=89, bot_y=4, start="red", player_count=2}, -- Reinforce: Sidelong
    {name = "seek open spaces", top_x=103, top_y=0, bot_x=117, bot_y=12, start="red", player_count=2}, -- Reinforce: Sidelong
    
    -- 3-player
    {name = "they meet a third", top_x=0, top_y=41, bot_x=12, bot_y=53, start="red", player_count=3}, -- Teach: strength of triad formation (all players aligned)
    {name = "and it gets interesting", top_x=13, top_y=13, bot_x=25, bot_y=22, start="red", player_count=3}, -- Corner-manuevering
    {name = "a series of tubes", top_x=90, top_y=0, bot_x=102, bot_y=12, start="red", player_count=3}, -- Teach no swapping when in doors
    {name = "gridlock", top_x=62, top_y=0, bot_x=74, bot_y=12, start="red", player_count=3}, -- Enforce no-swapping when in door regions
    {name = "nubbins", top_x=17, top_y=0, bot_x=27, bot_y=12, start="red", player_count=3}, -- Enforce "nubbins"
    {name = "fortress", top_x=0, top_y=0, bot_x=16, bot_y=12, start="red", player_count=3}, -- Drag-along and triad
    {name = "origin", top_x=75, top_y=5, bot_x=87, bot_y=16, start="red", player_count=3}, -- Skill Check
    
    -- 4-player
    {name = "down in a hole", top_x=16, top_y=24, bot_x=26, bot_y=34, start="red", player_count=4}, -- Re-check w/4 
}

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
                players.red = {
                    x = relative_x,
                    y = relative_y,
                    color = "red",
                    sprite = 1,
                    highlight = 47,
                    perked = 2,
                    target = 56,
                    inactive=3
                }
            end
            if spr_at == 4 then
                mset(column, row, 0)
                players.blue = {
                    x = relative_x, 
                    y = relative_y,
                    color = "blue",
                    sprite = 4,
                    highlight = 46,
                    perked = 5,
                    target = 57,
                    inactive=6
                }
            end
            if spr_at == 17 then
                mset(column, row, 0)
                players.yellow = {
                    x = relative_x,
                    y = relative_y,
                    color = "yellow",
                    sprite = 17,
                    highlight = 48,
                    perked = 18,
                    target = 58,
                    inactive=19
                }
            end

            if spr_at == 13 then
                mset(column, row, 0)
                players.green = {
                    x = relative_x,
                    y = relative_y,
                    color = "green",
                    sprite = 13,
                    highlight = 49,
                    perked = 14,
                    target = 59,
                    inactive = 15
                }
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
            
            -- Load hints
            if spr_at == 43 then
                if l_data.hint then
                    if not hints.x then
                        hints[relative_x] = {}
                    end
                    hints[relative_x][relative_y] = { x = relative_x, y = relative_y, text = l_data.hint}
                end
            end
        end
    end
end
