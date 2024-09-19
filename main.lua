local theme = require("theme")

function love.load()
    StartTime = love.timer.getTime()
    Time = StartTime
    DeltaTime = 0
    MouseX = 0
    MouseY = 0

    Hovered = nil
    Selected = nil

    Resolution = 50
    local n_points = 5
    Points = {}
    for i = 1, n_points do
        Points[i] = {x = 20 * i, y = 10, r = 10, hovered = false, mouse_distance = math.huge, best_hovered = false}
    end
    Intermediate = {}
    Curve = {}
    for i = 1, Resolution do
        Curve[i] = { x = i, y = i }
    end

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

    for i = 1, (Resolution + 1) do
        points = Points
        local t = (i - 1) / Resolution
        while #points > 1 do
            reduced = {}
            for j = 1, (#points - 1) do
                local p1 = points[j]
                local p2 = points[j + 1]
                reduced[j] = plerp(p1, p2, t)
            end
            points = reduced
        end
        Curve[i] = points[1]
    end
end

function DrawPoints(points)
    for i, point in pairs(points) do
        if point.best_hovered then
            love.graphics.setColor(theme.highlight())
        else
            love.graphics.setColor(theme.spline())
        end
        love.graphics.circle("fill", point.x, point.y, point.r)

        love.graphics.setColor(theme.outline())
        love.graphics.circle("line", point.x, point.y, point.r)

        local x = point.x - love.graphics.getFont():getWidth(tostring(i)) / 2
        local y = point.y - love.graphics.getFont():getHeight() / 2
        love.graphics.setColor(theme.outline())
        love.graphics.print(tostring(i), x, y)
    end
    love.graphics.setColor(theme.white())
end

function love.draw()
    love.graphics.setCanvas(WorldCanvas)
    -- love.graphics.setColor(theme.grass())
    love.graphics.clear(theme.grass())

    DrawPoints(Points)
    love.graphics.setColor(theme.highlight())
    for i = 1, #Points do
        p1 = Points[i]
        if i < #Points then
            p2 = Points[i + 1]
            -- love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
    end

    love.graphics.setColor(theme.white())
    for i = 1, #Curve do
        p1 = Curve[i]
        if i < #Curve then
            p2 = Curve[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
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
