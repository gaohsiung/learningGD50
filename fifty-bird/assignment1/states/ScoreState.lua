--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    if self.score >= 2 then
        self.trophy = 'gold'
    elseif self.score >=1 then
        self.trophy = 'sliver'
    else
        self.trophy = 'bronze'
    end
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 60, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('You won ' .. tostring(self.trophy) .. ' trophy!', 0, 80, VIRTUAL_WIDTH, 'center')
    love.graphics.draw(trophy[self.trophy], VIRTUAL_WIDTH/2, 100)
    love.graphics.printf('Press Enter to Play Again!', 0, 120, VIRTUAL_WIDTH, 'center')
end
