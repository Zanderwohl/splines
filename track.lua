Track = {}
Track.__index = Track

local theme = require("theme")

function Track:new()
    local obj = setmetatable({}, self)
    obj.n_points = 4
    obj.resolution = 50
    obj.points = {}
    obj.called = false
    obj.tieLength = 10
    for i = 1, obj.n_points do
        obj.points[i] = {x = 20 * i, y = 10, r = 10, hovered = false, mouse_distance = math.huge, best_hovered = false}
    end
    obj.curve = {}
    for i = 1, obj.resolution do
        obj.curve[i] = { x = i, y = i}
    end
    return obj
end

function Track:getPoints()
    return self.points
end

function Track:calc()
    for i = 1, (self.resolution + 1) do
        local points = self.points
        local t = (i - 1) / self.resolution
        while #points > 1 do
            reduced = {}
            for j = 1, (#points - 1) do
                local p1 = points[j]
                local p2 = points[j + 1]
                reduced[j] = plerp(p1, p2, t)
            end
            points = reduced
        end
        self.curve[i] = points[1]
    end
    self.called = true
end

function Track:drawPoints()
    for i, point in pairs(self.points) do
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

function Track:drawLines()
    love.graphics.setColor(theme.highlight())
    for i = 1, #self.points do
        p1 = self.points[i]
        if i < #self.points then
            p2 = self.points[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

function Track:drawCurve()
    love.graphics.setColor(theme.white())
    for i = 1, #self.curve do
        p1 = self.curve[i]
        if i < #self.curve then
            p2 = self.curve[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

function Track:drawTies()
    love.graphics.setColor(theme.white())
    for i = 1, #self.curve do
        p1 = self.curve[i]
        if i < #self.curve then
            p2 = self.curve[i + 1]
            local pm = plerp(p1, p2, 0.5)
            local tangent_a = {x = -(p2.y - p1.y), y = p2.x - p1.x}
            local norm = math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
            local len = 10
            tangent_a = {x = tangent_a.x / norm * len, y = tangent_a.y / norm * len}
            local tangent_b = {x = -tangent_a.x, y = -tangent_a.y}
            local end_a = {x = pm.x + tangent_a.x, y = pm.y + tangent_a.y}
            local end_b = {x = pm.x + tangent_b.x, y = pm.y + tangent_b.y}
            love.graphics.line(end_a.x, end_a.y, end_b.x, end_b.y)
        end
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function plerp(a, b, t)
    local x = lerp(a.x, b.x, t)
    local y = lerp(a.y, b.y, t)
    return { x = x, y = y}
end

return Track
