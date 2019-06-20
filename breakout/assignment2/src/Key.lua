--[[
    GD50
    Breakout Remake

    -- Key Class --

]]

Key = Class{}

function Key:init()
    -- intial positions
    self.x = math.random(math.floor(VIRTUAL_WIDTH-2))
    self.y = math.random(math.floor(VIRTUAL_HEIGHT / 3))

    self.width = 16
    self.height = 16

    -- drop speed
    self.dy = 50
    self.dx = 0
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Key:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end


function Key:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Key:render()
    if self.y <= VIRTUAL_HEIGHT then
        love.graphics.draw(gTextures['main'], gFrames['key'],
            self.x, self.y)
    end
end
