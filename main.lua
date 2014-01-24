function love.load(arg)
    love.window.setTitle("Bugfree Happiness")
    love.window.setMode(1024, 768, {
        fullscreen = false,
        fsaa = 4,
    })
end

function love.update(dt)
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
end

function love.draw()

end
