local theme = require("theme")
local Track = require("track")

function love.load()
    StartTime = love.timer.getTime()
    Time = StartTime
    DeltaTime = 0
    MouseX = 0
    MouseY = 0

    Hovered = nil
    Selected = nil

    Points = {}
    Tracks = {}
    for i = 1, 1 do
        local t = Track:new({ x = 10, y = 10 * i}, {x = 200, y = 10 * i})
        RegisterPoints(t)
        table.insert(Tracks, t)
    end

    WorldCanvas = null
    width, height = love.graphics.getDimensions()
    ResizeHelper(width, height)
end

function RegisterPoints(track)
    for _, v in ipairs(track:getPoints()) do
        table.insert(Points, v)
    end
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

function lerp(a, b, t)
    return a + (b - a) * t
end

function plerp(a, b, t)
    local x = lerp(a.x, b.x, t)
    local y = lerp(a.y, b.y, t)
    return { x = x, y = y}
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

    for i, t in ipairs(Tracks) do
        t:calc()
    end
end

function love.draw()
    love.graphics.setCanvas(WorldCanvas)
    love.graphics.clear(theme.grass())

    for i, t in ipairs(Tracks) do
        -- t:drawLines()
        -- t:drawCurve()
        t:drawTies()
        t:drawTracks()
        t:drawHandles()
        t:drawPoints()
    end

    love.graphics.setColor(theme.white())
    love.graphics.setCanvas()
    love.graphics.draw(WorldCanvas, 0, 0)
end

function love.resize(w, h)
    ResizeHelper(w, h)
end

function ResizeHelper(w, h)
    WorldCanvas = love.graphics.newCanvas(w, h)
end
