"""
Simulation state management
"""
mutable struct SimulationState
    sim::Union{Nothing, MicroMagnetic.AbstractSim}
    is_running::Observable{Bool}
    status::Observable{String}
    mesh_params::Observable{Dict}
    material_params::Observable{Dict}
end

function SimulationState()
    return SimulationState(
        nothing,
        Observable(false),
        Observable("Ready"),
        Observable(Dict(
            "nx" => 100,
            "ny" => 100,
            "nz" => 10,
            "dx" => 5e-9,
            "dy" => 5e-9,
            "dz" => 5e-9
        )),
        Observable(Dict(
            "Ms" => 8e5,
            "A" => 1.3e-11,
            "Ku" => 5e4,
            "alpha" => 0.02,
            "gamma" => 2.211e5
        ))
    )
end

"""
Create simulation object
"""
function create_sim(state::SimulationState)
    try
        state.status[] = "Creating simulation..."
        println(state.status[])
        notify(state.status)
        
        # Create mesh
        mp = state.mesh_params[]
        mesh = FDMesh(
            nx=mp["nx"],
            ny=mp["ny"],
            nz=mp["nz"],
            dx=mp["dx"],
            dy=mp["dy"],
            dz=mp["dz"]
        )
        
        # Create simulation object
        state.sim = Sim(mesh; name="micromagnetic_sim")
        
        # Set material properties
        mat = state.material_params[]
        set_Ms(state.sim, mat["Ms"])
        add_exch(state.sim, mat["A"])
        
        state.status[] = "Simulation created successfully"
        return state.sim
        
    catch e
        state.status[] = "Error creating simulation: $e"
        @error "Failed to create simulation" exception=e
        return nothing
    end
end

"""
Add interaction to simulation
"""
function add_interaction(state::SimulationState, interaction_type::String, params=Dict())
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        if interaction_type == "demag"
            add_demag(state.sim)
            state.status[] = "Added demagnetization"
            
        elseif interaction_type == "zeeman"
            H = get(params, "field", [0.0, 0.0, 0.0])
            add_zeeman(state.sim, tuple(H...))
            state.status[] = "Added Zeeman field: $H T"
            
        elseif interaction_type == "anisotropy"
            Ku = get(params, "Ku", state.material_params["Ku"])
            axis = get(params, "axis", [0, 0, 1])
            add_anis(state.sim, Ku, tuple(axis...))
            state.status[] = "Added anisotropy: Ku=$Ku J/m³"
            
        elseif interaction_type == "stt"
            P = get(params, "P", 1.0)
            xi = get(params, "xi", 0.05)
            J = get(params, "J", [1e12, 0, 0])
            add_stt(state.sim, model=:zhang_li, P=P, Ms=state.material_params["Ms"], xi=xi, J=tuple(J...))
            state.status[] = "Added STT: P=$P, J=$J A/m²"
        end
        
    catch e
        state.status[] = "Error adding interaction: $e"
        @error "Failed to add interaction" exception=e
    end
end

"""
Set initial magnetization
"""
function set_initial_magnetization(state::SimulationState, m0::Vector{Float64})
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        init_m0(state.sim, tuple(m0...))
        state.status[] = "Set initial magnetization: $m0"
    catch e
        state.status[] = "Error setting magnetization: $e"
        @error "Failed to set magnetization" exception=e
    end
end

"""
Set driver parameters
"""
function set_driver_params(state::SimulationState, driver_type::String, alpha::Float64, gamma::Float64)
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        set_driver(state.sim; driver=driver_type, alpha=alpha, gamma=gamma)
        state.status[] = "Set driver: $driver_type, α=$alpha"
    catch e
        state.status[] = "Error setting driver: $e"
        @error "Failed to set driver" exception=e
    end
end

"""
Relax the system
"""
function relax_system(state::SimulationState; stopping_dmdt=0.01, max_steps=10000)
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        state.is_running[] = true
        state.status[] = "Relaxing system..."
        
        # Set to SD driver for relaxation
        set_driver(state.sim; driver="SD")
        
        # Run relaxation
        relax(state.sim; stopping_dmdt=stopping_dmdt, max_steps=max_steps)
        
        state.is_running[] = false
        state.status[] = "System relaxed successfully"
        
    catch e
        state.is_running[] = false
        state.status[] = "Error during relaxation: $e"
        @error "Relaxation failed" exception=e
    end
end

"""
Run dynamics simulation
"""
function run_dynamics(state::SimulationState; steps=100, dt=1e-11, save_m_every=10)
    if state.sim === nothing
        create_sim(state)
    end
    
    try
        state.is_running[] = true
        state.status[] = "Running dynamics..."
        
        # Set to LLG driver for dynamics
        mat = state.material_params[]
        set_driver(state.sim; driver="LLG", alpha=mat["alpha"], gamma=mat["gamma"])
        
        # Run simulation
        run_sim(state.sim; steps=steps, dt=dt, save_m_every=save_m_every)
        
        state.is_running[] = false
        state.status[] = "Dynamics completed: $steps steps"
        
    catch e
        state.is_running[] = false
        state.status[] = "Error during dynamics: $e"
        @error "Dynamics failed" exception=e
    end
end

"""
Save simulation results
"""
function save_results(state::SimulationState, filename="simulation_results.ovf")
    if state.sim === nothing
        state.status[] = "No simulation to save"
        return
    end
    
    try
        save(filename, state.sim)
        state.status[] = "Results saved to $filename"
    catch e
        state.status[] = "Error saving results: $e"
        @error "Failed to save results" exception=e
    end
end