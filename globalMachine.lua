local stateMachine = require "libraries.batteries.state_machine"
local machine = stateMachine()

machine:new({ -- bizarre syntax but ok sure.
    splash = require "splashState",
    main = require "mainState",
}, "splash")

return machine
