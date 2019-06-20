--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]

-- powerup variables
local powerupTime = 0
local keyTime = 0
local powerupTimeInterval = 1
local keyTimeInterval = 1
hasKey = false

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    hasKey = false

    self.recoverPoints = 5000

    self.exPaddlePoints = 1000


    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end
--------------------------------------------------------------------------------

    -- Power up or not depend on the time
    if powerupTime >= powerupTimeInterval and (not self.powerup) and #ballList < 2 then
        self.powerup = Powerup()
    end

    if hasLockedBrick and not hasKey and (not self.key) then
        if keyTime >= keyTimeInterval then
            self.key = Key()
        end
    end

    if self.key then
        self.key:update(dt)
        if self.key:collides(self.paddle) then
            self.key = nil
            hasKey = true
        end
    end
    keyTime = keyTime + dt
    powerupTime = powerupTime + dt
    if self.powerup then
        self.powerup:update(dt)
        if self.powerup:collides(self.paddle) then
            self.powerup = nil

            if self.ball then
                print("selfball")
                extraBall1 = Ball(4)
                extraBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
                extraBall1.y = self.paddle.y - 8
                extraBall1.dx = math.random(-200, 200)
                extraBall1.dy = math.random(-50, -60)

                extraBall2 = Ball(4)
                extraBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
                extraBall2.y = self.paddle.y - 8
                extraBall2.dx = math.random(-200, 200)
                extraBall2.dy = math.random(-50, -60)
            elseif extraBall1 then
                print("eB1")
                self.ball = Ball(4)
                self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
                self.ball.y = self.paddle.y - 8
                self.ball.dx = math.random(-200, 200)
                self.ball.dy = math.random(-50, -60)

                extraBall2 = Ball(4)
                extraBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
                extraBall2.y = self.paddle.y - 8
                extraBall2.dx = math.random(-200, 200)
                extraBall2.dy = math.random(-50, -60)
            elseif extraBall2 then
                print("eB2")
                extraBall1 = Ball(4)
                extraBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
                extraBall1.y = self.paddle.y - 8
                extraBall1.dx = math.random(-200, 200)
                extraBall1.dy = math.random(-50, -60)

                self.ball = Ball(4)
                self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
                self.ball.y = self.paddle.y - 8
                self.ball.dx = math.random(-200, 200)
                self.ball.dy = math.random(-50, -60)
            end
        end
    end

    ballList = {}
    if extraBall1 then
        if extraBall1.y < VIRTUAL_HEIGHT then
            extraBall1:update(dt)
            table.insert(ballList, extraBall1)
        elseif extraBall1.y > VIRTUAL_HEIGHT then
            extraBall1 = nil
        end
    end

    if extraBall2 then
        if extraBall2.y < VIRTUAL_HEIGHT then
            extraBall2:update(dt)
            table.insert(ballList, extraBall2)
        elseif extraBall2.y > VIRTUAL_HEIGHT then
            extraBall2 = nil
        end
    end


--------------------------------------------------------------------------------
    -- update positions based on velocity
    self.paddle:update(dt)


    if self.ball then
        if self.ball.y < VIRTUAL_HEIGHT then
            self.ball:update(dt)
            table.insert(ballList, self.ball)
        elseif self.ball.y > VIRTUAL_HEIGHT then
            self.ball = nil
        end
    end



    -- if ball goes below bounds, revert to serve state and decrease health
    if #ballList == 0 then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health > 0 then
            self.paddle.size = math.max(self.paddle.size-1, 1)

        end
        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    for k, bb in pairs(ballList) do

        if bb:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            bb.y = self.paddle.y - 8
            bb.dy = -bb.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if bb.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                bb.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - bb.x))

            -- else if we hit the paddle on its right side while moving right...
            elseif bb.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                bb.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - bb.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and bb:collides(brick) then
                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- if we have enough points, extend paddle
                if self.score > self.exPaddlePoints then
                    -- can't go above size 4
                    self.paddle.size = math.min(4, self.paddle.size + 1)

                    -- multiply recover points by 2
                    self.exPaddlePoints = math.min(100000, self.exPaddlePoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    extraBall1 = nil
                    extraBall2 = nil
                    self.ball = nil

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = Ball(math.random(7)),
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if bb.x + 2 < brick.x and bb.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    bb.dx = -bb.dx
                    bb.x = brick.x - 8

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif bb.x + 6 > brick.x + brick.width and bb.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    bb.dx = -bb.dx
                    bb.x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif bb.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    bb.dy = -bb.dy
                    bb.y = brick.y - 8

                -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    bb.dy = -bb.dy
                    bb.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(bb.dy) < 150 then
                    bb.dy = bb.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    if self.ball then
        self.ball:render()
    end
--------------------------------------------------------------------------------
    if self.powerup then
        if self.powerup.y <= VIRTUAL_WIDTH then
            self.powerup:render()
        else
            self.powerup = nil
            powerupTime = 0
        end
    end

--------------------------------------------------------------------------------
    if self.key then
        if self.key.y <= VIRTUAL_WIDTH then
            self.key:render()
        else
            self.key = nil
            keyTime = 0
        end
    end

    if extraBall1 then
        extraBall1:render()
    end

    if extraBall2 then
        extraBall2:render()
    end
--------------------------------------------------------------------------------
    renderScore(self.score)
    renderHealth(self.health)

    if hasKey then
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Has Key! You can break the locked brick!", 0, VIRTUAL_HEIGHT - 16, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("You can't break the locked brick!", 0, VIRTUAL_HEIGHT - 16, VIRTUAL_WIDTH, 'center') 
    end
    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
