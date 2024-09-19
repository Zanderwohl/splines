local theme = require("theme")

function love.load()
    StartTime = love.timer.getTime()
    Time = StartTime
    DeltaTime = 0
    MouseX = 0
    MouseY = 0

    Hovered = nil
    Selected = nil

    Points = {
        {x = 20, y = 10, r = 15, hovered = false, mouse_distance = math.huge, best_hovered = false},
        {x = 40, y = 10, r = 15, hovered = false, mouse_distance = math.huge, best_hovered = false},
        {x = 60, y = 10, r = 15, hovered = false, mouse_distance = math.huge, best_hovered = false}
    }

    WorldCanvas = null
    width, height = love.graphics.getDimensions()
    ResizeHelper(width, height)
end

function UpdateMouse()
    local x, y = love.mouse.getPosition()
    MouseX = x
    MouseY = y

    for _, point in pairs(Points) do
        point.mouse_distance = Distance(MouseX, MouseY, point.x, point.y)
        point.hovered = point.mouse_distance <= point.r
        point.best_hovered = false
    end

    local min_value = math.huge
    local min_point = nil

    for _, point in pairs(Points) do
        if point.hovered and point.mouse_distance < min_value then
            if min_point ~= nil then
                min_point.best_hovered = false
            end
            min_point = point
            min_value = point.mouse_distance
            point.best_hovered = true
        end
    end
    Hovered = min_point
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if Hovered ~= nil then
            Selected = {
                x = Hovered.x - x,
                y = Hovered.y - y,
                node = Hovered
            }
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        Selected = nil
    end
end

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function love.update(dt)
    Time = love.timer.getTime()

    UpdateMouse()

    if Selected ~= nil then
        local x = MouseX + Selected.x
        local y = MouseY + Selected.y
        Selected.node.x = x
        Selected.node.y = y
    end
end

function DrawPoints(points)
    for _, point in pairs(points) do
        if point.best_hovered then
            love.graphics.setColor(theme.highlight())
        else
            love.graphics.setColor(theme.spline())
        end
        love.graphics.circle("fill", point.x, point.y, point.r)

        love.graphics.setColor(theme.outline())
        love.graphics.circle("line", point.x, point.y, point.r)
    end
    love.graphics.setColor(theme.white())
end

function love.draw()
    love.graphics.setCanvas(WorldCanvas)
    -- love.graphics.setColor(theme.grass())
    love.graphics.clear(theme.grass())

    DrawPoints(Points)

    love.graphics.setCanvas()
    love.graphics.draw(WorldCanvas, 0, 0)
end

function love.resize(w, h)
    ResizeHelper(w, h)
end

function ResizeHelper(w, h)
    WorldCanvas = love.graphics.newCanvas(w, h)
end
