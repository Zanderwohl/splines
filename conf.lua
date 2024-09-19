function love.conf(t)
  t.modules.physics = false

  t.identity = "zandy_spline"
  t.audio.mixwithsystem = true

  t.window.title = "Splines"
  t.window.icon = "assets/spline.png"
  t.window.resizable = true

  t.window.minwidth = 640
  t.window.minheight = 480
end
