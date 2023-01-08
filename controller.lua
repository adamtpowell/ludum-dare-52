local baton = require "libraries.baton"

return baton.new {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    accept = {'key:z', 'button:a'},
    reject = {'key:x', 'button:b'},
    start = {'key:return', 'button:start'},
    escape = {'key:escape', 'button:back'},
  },
  joystick = love.joystick.getJoysticks()[1],
}
