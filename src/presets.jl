"""
Configure Standard Problem 4: Thin film switching
"""
function configure_standard_problem_4(state::SimulationState)
    try
        state.status[] = "Configuring Standard Problem 4..."
        
        # Set mesh parameters
        state.mesh_params[] = Dict(
            "nx" => 100,
            "ny" => 100,
            "nz" => 10,
            "dx" => 5e-9,
            "dy" => 5e-9,
            "dz" => 5e-9
        )
        
        # Set material parameters
        state.material_params[] = Dict(
            "Ms" => 8e5,
            "A" => 1.3e-11,
            "Ku" => 5e4,
            "alpha" => 0.02,
            "gamma" => 2.211e5
        )
        
        # Create simulation
        create_sim(state)
        
        # Add interactions
        add_interaction(state, "demag")
        add_interaction(state, "anisotropy", Dict("axis" => [0, 0, 1]))
        add_interaction(state, "zeeman", Dict("field" => [0.1, 0, 0]))
        
        # Set initial magnetization
        set_initial_magnetization(state, [1, 0.25, 0.1])
        
        state.status[] = "Standard Problem 4 configured: Thin film switching"
        
    catch e
        state.status[] = "Error configuring Standard Problem 4: $e"
        @error "Failed to configure Standard Problem 4" exception=e
    end
end

"""
Configure Standard Problem 5: Vortex dynamics
"""
function configure_standard_problem_5(state::SimulationState)
    try
        state.status[] = "Configuring Standard Problem 5..."
        
        # Set mesh parameters
        state.mesh_params[] = Dict(
            "nx" => 100,
            "ny" => 100,
            "nz" => 1,
            "dx" => 5e-9,
            "dy" => 5e-9,
            "dz" => 5e-9
        )
        
        # Set material parameters
        state.material_params[] = Dict(
            "Ms" => 8e5,
            "A" => 1.3e-11,
            "Ku" => 0.0,
            "alpha" => 0.02,
            "gamma" => 2.211e5
        )
        
        # Create simulation
        create_sim(state)
        
        # Add interactions
        add_interaction(state, "demag")
        
        # Set vortex initial state
        set_vortex_initial_state(state)
        
        state.status[] = "Standard Problem 5 configured: Vortex dynamics"
        
    catch e
        state.status[] = "Error configuring Standard Problem 5: $e"
        @error "Failed to configure Standard Problem 5" exception=e
    end
end

"""
Set vortex initial state
"""
function set_vortex_initial_state(state::SimulationState)
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        # Create vortex magnetization pattern
        mesh = state.sim.mesh
        nx, ny, nz = mesh.nx, mesh.ny, mesh.nz
        dx, dy, dz = mesh.dx, mesh.dy, mesh.dz
        
        # Calculate center of the sample
        center_x = (nx * dx) / 2
        center_y = (ny * dy) / 2
        
        # Create vortex magnetization
        m = zeros(Float64, 3, nx, ny, nz)
        
        for i in 1:nx, j in 1:ny, k in 1:nz
            x = (i - 0.5) * dx - center_x
            y = (j - 0.5) * dy - center_y
            
            # Calculate distance from center
            r = sqrt(x^2 + y^2)
            
            if r > 0
                # Vortex configuration
                phi = atan(y, x)
                m[1, i, j, k] = -sin(phi)
                m[2, i, j, k] = cos(phi)
                m[3, i, j, k] = 0.0
            else
                # Center point
                m[1, i, j, k] = 0.0
                m[2, i, j, k] = 0.0
                m[3, i, j, k] = 1.0
            end
        end
        
        # Set magnetization
        state.sim.spin .= m
        
        state.status[] = "Vortex initial state set"
        
    catch e
        state.status[] = "Error setting vortex state: $e"
        @error "Failed to set vortex state" exception=e
    end
end

"""
Configure custom simulation
"""
function configure_custom_simulation(state::SimulationState, 
                                     mesh_params::Dict, 
                                     material_params::Dict,
                                     interactions::Vector{Tuple{String, Dict}})
    try
        state.status[] = "Configuring custom simulation..."
        
        # Set parameters
        state.mesh_params[] = mesh_params
        state.material_params[] = material_params
        
        # Create simulation
        create_sim(state)
        
        # Add interactions
        for (interaction_type, params) in interactions
            add_interaction(state, interaction_type, params)
        end
        
        state.status[] = "Custom simulation configured"
        
    catch e
        state.status[] = "Error configuring custom simulation: $e"
        @error "Failed to configure custom simulation" exception=e
    end
end