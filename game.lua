players = {}
goals = {}
hints = {}
reading = false
game_complete = false
level_data = {
    -- 1-player
    {name = "down in a hole", top_x=16, top_y=24, bot_x=26, bot_y=34, start="red"}, -- Re-check w/4 
    {name = "goals (move: d-pad)", top_x=29, top_y=0, bot_x=39, bot_y=8, start="red", hint="head to the goal that matches your color."}, -- Reach the goals
    {name = "through the door", top_x=40, top_y=0, bot_x=50, bot_y=8, start="red", hint="you can walk through a door if you match its color."}, -- What a door is
    
    -- 2-player
    {name = "more of us (cycle: z)", top_x=51, top_y=0, bot_x=61, bot_y=10, start="red", hint="change characters by pressing z, get all characters to their goals."}, -- Cycling between colors
    {name = "seek alignment (swap: x)", top_x=29, top_y=9, bot_x=41, bot_y=21, start="red", hint="if two characters are aligned horizontally, you can swap them with x."}, -- Horizontal Swapping
    {name = "above // below (swap: x)", top_x=0, top_y=54, bot_x=14, bot_y=63, start="red", hint="if two characters are aligned vertically, you can swap them with x."}, -- Vertical Swapping
    {name = "we got this", top_x=0, top_y=26, bot_x=15, bot_y=31, start="red"}, -- Skill check: swapping/doors/goals
    {name = "pushback", top_x=42, top_y=11, bot_x=57, bot_y=21, start="red"}, -- How to "Pushback" a character through a corridor of doors
    {name = "sidelong", top_x=0, top_y=32, bot_x=12, bot_y=40, start="red"}, -- Move another character to their goal, ignore another
    {name = "snakey", top_x=75, top_y=0, bot_x=89, bot_y=4, start="red"}, -- Reinforce: Sidelong
    -- {name = "TODO: drag-along", top_x=42, top_y=11, bot_x=57, bot_y=21, start="red"}, -- Teach "Drag-along"
    {name = "oroboros", top_x=0, top_y=13, bot_x=12, bot_y=25, start="red"}, -- Skill check: horizontal and vertical swapping
    
    -- 3-player
    {name = "they meet a third", top_x=0, top_y=41, bot_x=12, bot_y=53, start="red"}, -- Teach: strength of triad formation (all players aligned)
    {name = "and it gets interesting", top_x=13, top_y=13, bot_x=25, bot_y=21, start="red"}, -- Sidelong + Pushback
    {name = "fortress", top_x=0, top_y=0, bot_x=16, bot_y=12, start="red"}, -- Drag-along and triad
    {name = "origin", top_x=75, top_y=5, bot_x=87, bot_y=16, start="red"}, -- Skill Check
    {name = "a series of tubes", top_x=90, top_y=0, bot_x=104, bot_y=12, start="red"}, -- Teach no swapping when in doors
    {name = "nubbins", top_x=17, top_y=0, bot_x=27, bot_y=12, start="red"}, -- Enforce "nubbins"
    {name = "gridlock", top_x=62, top_y=0, bot_x=74, bot_y=12, start="red"}, -- Enforce no-swapping when in door regions
    -- {name = "INC: where's red???...", top_x=16, top_y=55, bot_x=25, bot_y=63, start="blue"}, -- Teach: strength of triad formation (all players aligned)
    
    -- 4-player
}

dialog = {
  x = 8,
  y = 97,
  color = 7,
  max_chars_per_line = 27,
  max_lines = 4,
  dialog_queue = {},
  blinking_counter = 0,
  init = function(self)
  end,
  queue = function(self, message, autoplay)
    -- default autoplay to false
    autoplay = type(autoplay) == "nil" and false or autoplay
    add(self.dialog_queue, {
      message = message,
      autoplay = autoplay
    })

    if (#self.dialog_queue == 1) then
      self:trigger(self.dialog_queue[1].message, self.dialog_queue[1].autoplay)
    end
  end,
  trigger = function(self, message, autoplay)
    self.autoplay = autoplay
    self.current_message = ''
    self.messages_by_line = nil
    self.animation_loop = nil
    self.current_line_in_table = 1
    self.current_line_count = 1
    self.pause_dialog = false
    self:format_message(message)
    self.animation_loop = cocreate(self.animate_text)
  end,
  format_message = function(self, message)
    local total_msg = {}
    local word = ''
    local letter = ''
    local current_line_msg = ''

    for i = 1, #message do
      -- get the current letter add
      letter = sub(message, i, i)

      -- keep track of the current word
      word ..= letter

      -- if it's a space or the end of the message,
      -- determine whether we need to continue the current message
      -- or start it on a new line
      if letter == ' ' or i == #message then
        -- get the potential line length if this word were to be added
        local line_length = #current_line_msg + #word
        -- if this would overflow the dialog width
        if line_length > self.max_chars_per_line then
          -- add our current line to the total message table
          add(total_msg, current_line_msg)
          -- and start a new line with this word
          current_line_msg = word
        else
          -- otherwise, continue adding to the current line
          current_line_msg ..= word
        end

        -- if this is the last letter and it didn't overflow
        -- the dialog width, then go ahead and add it
        if i == #message then
          add(total_msg, current_line_msg)
        end

        -- reset the word since we've written
        -- a full word to the current message
        word = ''
      end
    end

    self.messages_by_line = total_msg
  end,
  animate_text = function(self)
    -- for each line, write it out letter by letter
    -- if we each the max lines, pause the coroutine
    -- wait for input in update before proceeding
    for k, line in pairs(self.messages_by_line) do
      self.current_line_in_table = k
      for i = 1, #line do
        self.current_message ..= sub(line, i, i)

        -- press btn 5 to skip to the end of the current passage
        -- otherwise, print 1 character per frame
        -- with sfx about every 5 frames
        if (not btnp(5)) then
          if (i % 5 == 0) sfx(0)
          yield()
        end
      end
      self.current_message ..= '\n'
      self.current_line_count += 1
      if ((self.current_line_count > self.max_lines) or (self.current_line_in_table == #self.messages_by_line and not self.autoplay)) then
        self.pause_dialog = true
        yield()
      end
    end

    if (self.autoplay) then
      self.delay(30)
    end
  end,
  shift = function (t)
    local n=#t
    for i = 1, n do
      if i < n then
        t[i] = t[i + 1]
      else
        t[i] = nil
      end
    end
  end,
  -- helper function to add delay in coroutines
  delay = function(frames)
    for i = 1, frames do
      yield()
    end
  end,
  update = function(self)
    if (self.animation_loop and costatus(self.animation_loop) != 'dead') then
      if (not self.pause_dialog) then
        coresume(self.animation_loop, self)
      else
        if btnp(4) then
          self.pause_dialog = false
          self.current_line_count = 1
          self.current_message = ''
        end
      end
    elseif (self.animation_loop and self.current_message) then
      if (self.autoplay) self.current_message = ''
      self.animation_loop = nil
      reading = false
    end

    if (not self.animation_loop and #self.dialog_queue > 0) then
      self.shift(self.dialog_queue, 1)
      if (#self.dialog_queue > 0) then
        self:trigger(self.dialog_queue[1].message, self.dialog_queue[1].autoplay)
        coresume(self.animation_loop, self)
      end
    end

    if (not self.autoplay) then
      self.blinking_counter += 1
      if self.blinking_counter > 30 then self.blinking_counter = 0 end
    end
  end,
  draw = function(self)
    local screen_width = 128

    -- display message
    if (self.current_message) then
      print(self.current_message, self.x, self.y, self.color)
    end

    -- draw blinking cursor at the bottom right
    if (not self.autoplay and self.pause_dialog) then
      if self.blinking_counter > 15 then
        if (self.current_line_in_table == #self.messages_by_line) then
          -- draw square
          rectfill(
            screen_width - 11,
            screen_width - 10,
            screen_width - 11 + 3,
            screen_width - 10 + 3,
            7
          )
        else
          -- draw arrow
          line(screen_width - 12, screen_width - 9, screen_width - 8,screen_width - 9)
          line(screen_width - 11, screen_width - 8, screen_width - 9,screen_width - 8)
          line(screen_width - 10, screen_width - 7, screen_width - 10,screen_width - 7)
        end
      end
    end
  end
}


function _init()
    current_level = 1
    load_level(current_level)
    sfx(2)
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
    -- if level_index > get_table_size(level_data) do
    --     return
    -- end

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
            
            -- Load hints
            if spr_at == 43 then
                if l_data.hint then
                    if not hints.x do
                        hints[relative_x] = {}
                    end
                    hints[relative_x][relative_y] = { x = relative_x, y = relative_y, text = l_data.hint}
                end
            end
        end
    end
end

function _update()
    if not game_complete do
        input()
        dialog:update()
        local won = check_win()
        move()
        if won then
            -- Freeze input and play a jingle
            sfx(2)
            for i=1,60 do
                flip()
            end
            current_level += 1
            if current_level > get_table_size(level_data) do
                current_level = 1
                game_complete = true
            end
            goals = {}
            players = {}
            hints = {}
            load_level(current_level)
            local l_data = level_data[current_level]
            player = players[l_data.start]
        end
    end
end

function check_win()
    local complete = true
    local players_on_goals = 0 -- TODO: rising winning effects
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
    if not reading do        
        if (btnp(0)) nx = -1
        if (btnp(1)) nx =  1
        if (btnp(2)) ny = -1
        if (btnp(3)) ny =  1
        if (btnp(4)) then
            if get_table_size(players) > 1 then
                sfx(4)
            end
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
        sfx(6) -- walking sound
    else
        sfx(1) -- play bump/invalid noise
    end
    for x, xhint in pairs(hints) do
        local xhints = hints[x]
        for y, hint in pairs(xhints) do
            if x == npx and y == npy do
                dialog:queue(hint.text)
                reading = true
            end
        end
    end
end

function get_table_size(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
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
    if not game_complete do
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
    else
        cls(0)
        map(115, 52, 0, 0, 13, 12)
    end
end 