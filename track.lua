Track = {}
Track.__index = Track

local theme = require("theme")

function Track:new(p1, p2)
    local obj = new_common()
    for i = 1, obj.n_points do
        local t = (i - 1) / obj.n_points
        local p = plerp(p1, p2, t)
        obj.points[i] = {x = p.x, y = p.y, r = 20, hovered = false, mouse_distance = math.huge, best_hovered = false}
    end
    return obj
end

function new_common()
    local obj = setmetatable({}, Track)
    obj.n_points = 4
    obj.resolution = 50
    obj.points = {}
    obj.proxyPoints = {}
    obj.called = false
    obj.tieLength = 10
    obj.handleLength = 0.3
    obj.curve = {}
    for i = 1, obj.resolution do
        obj.curve[i] = { x = i, y = i}
    end
    for i = 1, obj.n_points do
        obj.points[i] = {x = 0, y = 0, r = 10, hovered = false, mouse_distance = math.huge, best_hovered = false}
    end
    for i = 1, obj.n_points do
        if i == 1 or i == #obj.points then
            obj.proxyPoints[i] = obj.points[i]
        end
        if i == 2 or i == #obj.points - 1 then
            local proxyPoint = nil
            if i == 2 then
                proxyPoint = plerp(obj.points[1], obj.points[2], obj.handleLength)
            end
            if i == #obj.points - 1 then
                proxyPoint = plerp(obj.points[#obj.points], obj.points[#obj.points - 1], obj.handleLength)
            end
            proxyPoint.r = 10
            proxyPoint.hovered = false
            proxyPoint.mouse_distance = math.huge
            proxyPoint.best_hovered = false
            obj.proxyPoints[i] = proxyPoint
        end
    end
    return obj
end

function Track:getPoints()
    return self.proxyPoints
end

function Track:calc()
    self.points[1] = self.proxyPoints[1]
    local temp = plerp(self.proxyPoints[1], self.proxyPoints[2], 1 / self.handleLength)
    self.points[2].x = temp.x
    self.points[2].y = temp.y
    self.points[2].best_hovered = self.proxyPoints[2].best_hovered
    temp = plerp(self.proxyPoints[#self.proxyPoints], self.proxyPoints[#self.proxyPoints - 1], 1 / self.handleLength)
    self.points[#self.proxyPoints - 1].x = temp.x
    self.points[#self.proxyPoints - 1].y = temp.y
    self.points[#self.proxyPoints - 1].best_hovered = self.proxyPoints[#self.proxyPoints - 1].best_hovered
    self.points[#self.proxyPoints] = self.proxyPoints[#self.proxyPoints]
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
        if i == 1 or i == #self.points then
            local verts = link_verts()
            for _, shape in ipairs(verts) do
                for _, vert in ipairs(shape) do
                    vert.x = vert.x + point.x
                    vert.y = vert.y + point.y
                end
            end

            if point.best_hovered then
                love.graphics.setColor(theme.highlight())
            else
                love.graphics.setColor(theme.spline())
            end
            love.graphics.setLineWidth(6)
            for _, shape in ipairs(verts) do
                for j, v1 in ipairs(shape) do
                    k = math.fmod(j + 1, #shape)
                    if k == 0 then
                        k = #shape
                    end
                    local v2 = shape[k]
                    love.graphics.line(v1.x, v1.y, v2.x, v2.y)
                end
            end

            love.graphics.setColor(theme.outline())
            love.graphics.setLineWidth(2)
            for _, shape in ipairs(verts) do
                for j, v1 in ipairs(shape) do
                    k = math.fmod(j + 1, #shape)
                    if k == 0 then
                        k = #shape
                    end
                    local v2 = shape[k]
                    love.graphics.line(v1.x, v1.y, v2.x, v2.y)
                end
            end
            love.graphics.setLineWidth(1)
        end
    end
    love.graphics.setColor(theme.white())
end

function Track:drawHandles()
    local ps = self.points
    local handle_1 = self.proxyPoints[2]
    local handle_2 = self.proxyPoints[#self.proxyPoints - 1]
    local handles = { { handle_1, ps[1] }, { handle_2, ps[#ps] }}

    -- love.graphics.print('Point 2 ' .. self.points[1].x .. ' ' .. self.points[1].y, 20, 20)
    -- love.graphics.print('pPoint 2 ' .. self.proxyPoints[1].x .. ' ' .. self.proxyPoints[1].y, 130, 20)

    -- love.graphics.print('Point n ' .. self.points[#self.proxyPoints - 1].x .. ' ' .. self.points[#self.proxyPoints - 1].y, 20, 70)
    -- love.graphics.print('pPoint n ' .. self.proxyPoints[#self.proxyPoints - 1].x .. ' ' .. self.proxyPoints[#self.proxyPoints - 1].y, 130, 70)

    for i, handle in ipairs(handles) do
        local splineColor = theme.spline()


        local src = handle[2]
        local sink = handle[1]
        if sink.best_hovered then
            splineColor = theme.highlight()
        end
        love.graphics.setLineWidth(5)
        love.graphics.setColor(theme.outline())
        love.graphics.line(src.x, src.y, sink.x, sink.y)

        love.graphics.setLineWidth(2)
        love.graphics.setColor(splineColor)
        love.graphics.line(src.x, src.y, sink.x, sink.y)

        love.graphics.setColor(splineColor)
        love.graphics.circle("fill", sink.x, sink.y, 7)

        love.graphics.setLineWidth(2)
        love.graphics.setColor(theme.outline())
        love.graphics.circle("line", sink.x, sink.y, 7)
    end
    love.graphics.setLineWidth(1)
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
    love.graphics.setColor(theme.track())
    for i = 1, #self.curve do
        p1 = self.curve[i]
        if i < #self.curve then
            p2 = self.curve[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

function Track:drawTracks()
    love.graphics.setColor(theme.track())
    for i = 1, #self.curve do
        p1 = self.curve[i]
        if i < #self.curve then
            p2 = self.curve[i + 1]
            local r_a = nil
            local r_b = nil
            local m_a = p1
            local m_b = p2
            local l_a = nil
            local l_b = nil
            r_a, l_a = horizontalDisplace(p1, p2, 8, m_a)
            r_b, l_b = horizontalDisplace(p1, p2, 8, m_b)
            love.graphics.line(r_a.x, r_a.y, r_b.x, r_b.y)
            love.graphics.line(l_a.x, l_a.y, l_b.x, l_b.y)
        end
    end
end

function Track:drawTies()
    love.graphics.setColor(theme.track())
    for i = 1, #self.curve do
        p1 = self.curve[i]
        if i < #self.curve then
            p2 = self.curve[i + 1]
            local end_a = nil
            local end_b = nil
            local midpoint = plerp(p1, p2, 0.5)
            end_a, end_b = horizontalDisplace(p1, p2, 10, midpoint)
            love.graphics.line(end_a.x, end_a.y, end_b.x, end_b.y)
        end
    end
end

function horizontalDisplace(p1, p2, len, mid)
    local tangent_a = {x = -(p2.y - p1.y), y = p2.x - p1.x}
    local norm = math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
    tangent_a = {x = tangent_a.x / norm * len, y = tangent_a.y / norm * len}
    local tangent_b = {x = -tangent_a.x, y = -tangent_a.y}
    local end_a = {x = mid.x + tangent_a.x, y = mid.y + tangent_a.y}
    local end_b = {x = mid.x + tangent_b.x, y = mid.y + tangent_b.y}
    return end_a, end_b
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function plerp(a, b, t)
    local x = lerp(a.x, b.x, t)
    local y = lerp(a.y, b.y, t)
    return { x = x, y = y}
end

function flatten(t)
    local flat = {}
    for _, v in pairs(t) do
        if type(v) == "table" then
            for _, sub_v in pairs(flatten(v)) do
                table.insert(flat, sub_v)
            end
        else
            table.insert(flat, v)
        end
    end
    return flat
end

function link_verts()
    local offset_x = 5
    local offset_y = 2
    return {
        { { x = -10 + offset_x, y = 0 + offset_y },
          { x = -7 + offset_x, y = 5 + offset_y },
          { x = 7 + offset_x, y = 5 + offset_y },
          { x = 10 + offset_x, y = 0 + offset_y },
          { x = 7 + offset_x, y = -5 + offset_y },
          { x = -7 + offset_x, y = -5 + offset_y }
        },

        { { x = -10 - offset_x, y = 0 - offset_y },
          { x = -7 - offset_x, y = 5 - offset_y },
          { x = 7 - offset_x, y = 5 - offset_y },
          { x = 10 - offset_x, y = 0 - offset_y },
          { x = 7 - offset_x, y = -5 - offset_y },
          { x = -7 - offset_x, y = -5 - offset_y }
        }
    }

end

return Track
