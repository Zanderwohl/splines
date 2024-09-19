local theme = {}

-- https://encycolorpedia.com/35654d
GRASS = { 107, 194, 83, 1 }

WHITE = {255, 255, 255}
BLACK = {0, 0, 0}
RED = {255, 200, 200}

function theme.white()
    return Div(WHITE)
end

function theme.grass()
    return Div(GRASS)
end

function theme.spline()
    return Div(WHITE)
end

function theme.highlight()
    return Div(RED)
end

function theme.outline()
    return Div(BLACK)
end

function Select(colors, variation)
    local var = (variation - 1) % #colors + 1
    return Div(colors[var])
end

function Div(color)
    return {
        color[1] / 255,
        color[2] / 255,
        color[3] / 255,
        color[4]
    }
end

return theme
