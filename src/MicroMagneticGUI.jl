#__precompile__()
module MicroMagneticGUI

using Bonito
using Observables
using MicroMagnetic

# Import submodules
include("core.jl")
include("ui_components.jl")
include("presets.jl")
include("utils.jl")
include("interface.jl")

function launch_interface(port::Int=1234)
    println("Starting MicroMagnetic.jl Interface...")
    println("Server will be available at http://localhost:$port")
    println("Press Ctrl+C to stop the server")
    
    # Create the interface
    app = create_interface()
    
    try
        # Start the server - Bonito.Server automatically starts the server
        server = Bonito.Server(app, "127.0.0.1", port)
        
        # Wait indefinitely to keep the server running
        #wait(server)
        
    catch e
        if !(e isa InterruptException)
            rethrow(e)
        end
        println("\nServer stopped by user")
    end
end

export create_interface, launch_interface

end #module
