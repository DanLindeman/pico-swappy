controller = {
    input = function(self)
        nx = 0
        ny = 0
        if not reading then
            if (btnp(0)) nx = -1
            if (btnp(1)) nx =  1
            if (btnp(2)) ny = -1
            if (btnp(3)) ny =  1
            self:move()

            if (btnp(4)) then
                self:next_player()
            end
            if (btnp(5)) then
                self:swap()
            end
        end
    end,
    next_player = function(self)
        if get_table_size(players) > 1 then
            sfx(4)
        end
        local control_passing_lookup_table = {
            red = {"blue", "green", "yellow"},
            blue = {"green", "yellow", "red"},
            green = {"yellow", "red", "blue"},
            yellow = {"red", "blue", "yellow"}
        }
        local others = control_passing_lookup_table[player.color]
        for i, other in ipairs(others) do
            if players[other] ~= nil do
                player = players[other]
                return
            end
        end
    end,
    swap = function(self)
        local swapped = false
        for col, target in pairs(players) do
            if target.color == player.color then
                goto continue
            end
            -- Prevents players from swapping into a location they aren't allowed (like a wrong-color door)
            local target_okay = self:is_background(target.x, target.y, player.color)
            local player_okay = self:is_background(player.x, player.y, target.color)

            if (target.x == player.x) and (not swapped) and target_okay and player_okay then
                sfx(3)
                local target_y = target.y
                local player_y = player.y
                target.y = player_y
                player.y = target_y
                swapped = true
            elseif (target.y == player.y) and (not swapped)  and target_okay and player_okay then
                sfx(3)
                local target_x = target.x
                local player_x = player.x
                target.x = player_x
                player.x = target_x
                swapped = true
            else
                sfx(5) -- nobody to swap with
            end
            ::continue::
        end
    end,
    move = function(self)
        if nx == 0 and ny == 0 then
            return
        end
        npx = player.x + nx
        npy = player.y + ny
        if self:is_background(npx, npy, player.color) then
            player.x += nx
            player.y += ny
            sfx(6) -- walking sound
        else
            sfx(1) -- play bump/invalid noise
        end
        for x, xhint in pairs(hints) do
            local xhints = hints[x]
            for y, hint in pairs(xhints) do
                if x == npx and y == npy then
                    dialog:queue(hint.text)
                    reading = true
                end
            end
        end
    end,
    is_background = function(self, x, y, color)
        local l_data = level_data[current_level]
        local check_for = players[color]
        local plyr_flags = fget(check_for.sprite)
        local spr_at = mget(l_data.top_x+x, l_data.top_y+y)
        local flags_at = fget(spr_at)

        -- TODO: Add hugging when characters touch
        -- -- Other players are not background, this breaks swapping
        -- for color, plyr in pairs(players) do
        --     if player.color ~= plyr.color do
        --         if plyr.x == x and plyr.y ==y do
        --             return false
        --         end
        --     end
        -- end

        return flags_at == 0 or flags_at == plyr_flags
    end
}







