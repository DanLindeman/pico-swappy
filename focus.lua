focus = {
    x=0,
    y=0,
    angle=0,
    speed=1,
    prox=0.7,
    spr=51,
    init=function(self)
        self.x = player.x
        self.y = player.y-1
    end,
    draw=function(self)
        if self.spr< 54.6 then
            self.spr+=.4
        else
            self.spr=51
        end
        spr(self.spr, self.x*8, (self.y)*8)
    end,
    update=function(self)
        if distance(player.x, (player.y-1), self.x, self.y) < 0.7 do
            self.x = player.x
            self.y = player.y-1
        else
            local newangle = atan2(player.x-self.x, (player.y-1)-self.y)
            self.angle = angle_lerp(self.angle, newangle, self.prox)
            self.x += self.speed * cos(self.angle)
            self.y += self.speed * sin(self.angle)
        end
    end,
}

function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return sqrt(dx * dx + dy * dy)
end

function angle_lerp(angle1, angle2, t)
    angle1=angle1%1
    angle2=angle2%1
    if abs(angle1-angle2)>0.5 then
        if angle1>angle2 then
            angle2+=1
        else
            angle1+=1
        end
    end
    return ((1-t)*angle1+t*angle2)%1
end
