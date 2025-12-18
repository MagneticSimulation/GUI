#__precompile__()
module MicroMagneticGUI

using Bonito
# Create a reactive counter app
app = App() do session
    count = Observable(0)
    button = Button("Click me!")
    on(click-> (count[] += 1), button)
    return DOM.div(button, DOM.h1("Count: ", count))
end


function run()

    #display(app) # display it in browser or plotpane

    # Or serve it on a server
    server = Server(app, "127.0.0.1", 8888)

end

export run

function __init__() end

end #module
