# interface/ui_components.jl

function param_input(label::String, obs::Observable, key::String, options=Dict())
    default_options = Dict(
        :type => "number",
        :step => "any",
        :style => "width: 120px; margin-left: 10px;"
    )
    merged_options = merge(default_options, options)
    
    # 构建所有属性的字典
    input_attrs = Dict(
        :value => string(obs[][key]),
        :oninput => js"""function(e) {
            const value = parseFloat(e.target.value);
            if(!isNaN(value)) {
                const current = $obs[];
                current[$key] = value;
                Bonito.@set($obs = current);
            }
        }"""
    )
    
    # 合并选项
    all_attrs = merge(input_attrs, merged_options)
    
    return DOM.div(
        style="margin: 8px 0;",
        DOM.span(label, style="display: inline-block; width: 150px;"),
        DOM.input(; all_attrs...)
    )
end

"""
Button component
"""
function button(label::String, onclick::Function, color="#3498db", disabled=Observable(false))
    # Create a simple button without passing Julia function to JavaScript
    return DOM.button(
        label,
        disabled=disabled,
        style="""
            background-color: $color;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
            font-size: 14px;
        """
    )
end

"""
Create parameter panel
"""
function create_parameter_panel(state::SimulationState)
    return DOM.div(
        style="flex: 1;",
        
        # Mesh parameters
        DOM.div(
            DOM.h3("Mesh Parameters", style="color: #3498db; margin-bottom: 10px;"),
            
            param_input("nx:", state.mesh_params, "nx", Dict(:min => "1", :step => "1")),
            param_input("ny:", state.mesh_params, "ny", Dict(:min => "1", :step => "1")),
            param_input("nz:", state.mesh_params, "nz", Dict(:min => "1", :step => "1")),
            param_input("dx (m):", state.mesh_params, "dx", Dict(:step => "1e-10")),
            param_input("dy (m):", state.mesh_params, "dy", Dict(:step => "1e-10")),
            param_input("dz (m):", state.mesh_params, "dz", Dict(:step => "1e-10")),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            """
        ),
        
        # Material parameters
        DOM.div(
            DOM.h3("Material Parameters", style="color: #e74c3c; margin-bottom: 10px;"),
            
            param_input("Ms (A/m):", state.material_params, "Ms", Dict(:step => "1e3")),
            param_input("A (J/m):", state.material_params, "A", Dict(:step => "1e-12")),
            param_input("Ku (J/m³):", state.material_params, "Ku", Dict(:step => "1e3")),
            param_input("α:", state.material_params, "alpha", Dict(:step => "0.001", :min => "0", :max => "1")),
            param_input("γ (rad/s·T):", state.material_params, "gamma", Dict(:step => "1e3")),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            """
        ),
        
        # Control buttons
        DOM.div(
            DOM.h3("Simulation Control", style="color: #2ecc71; margin-bottom: 10px;"),
            
            DOM.div(
                button("Create Simulation", () -> create_sim(state), "#3498db"),
                button("Add Demag", () -> add_interaction(state, "demag"), "#9b59b6"),
                button("Add Zeeman", () -> add_interaction(state, "zeeman", Dict("field" => [0.1, 0, 0])), "#f39c12"),
                style="margin-bottom: 10px;"
            ),
            
            DOM.div(
                button("Set Initial M", () -> set_initial_magnetization(state, [1, 0.25, 0.1]), "#34495e"),
                button("Relax System", () -> relax_system(state), "#27ae60", state.is_running),
                button("Run Dynamics", () -> run_dynamics(state), "#e74c3c", state.is_running),
                style="margin-bottom: 10px;"
            ),
            
            # Status display
            DOM.div(
                DOM.div(
                    "Status:",
                    style="display: inline-block; margin-right: 10px; font-weight: bold;"
                ),
                DOM.span(
                    state.status,
                    style="""
                        color: $(state.status[] == "Ready" ? "#7f8c8d" : 
                                occursin("Error", state.status[]) ? "#e74c3c" : "#27ae60");
                    """
                ),
                style="margin-top: 10px; padding: 8px; background: #ecf0f1; border-radius: 4px;"
            ),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            """
        )
    )
end

"""
Create preset panel
"""
function create_preset_panel(state::SimulationState)
    return DOM.div(
        style="flex: 1;",
        
        # Preset configurations
        DOM.div(
            DOM.h3("Standard Problem Presets", style="color: #9b59b6; margin-bottom: 10px;"),
            
            DOM.div(
                button("Standard Problem 4", () -> configure_standard_problem_4(state), "#9b59b6"),
                DOM.p("Thin film switching with external field",
                    style="color: #666; font-size: 0.9em; margin: 5px 0 10px 0;"),
                
                button("Standard Problem 5", () -> configure_standard_problem_5(state), "#9b59b6"),
                DOM.p("Vortex dynamics with spin-transfer torque",
                    style="color: #666; font-size: 0.9em; margin: 5px 0 10px 0;"),
                
                style="margin-bottom: 10px;"
            ),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            """
        ),
        
        # Advanced controls
        DOM.div(
            DOM.h3("Advanced Controls", style="color: #e67e22; margin-bottom: 10px;"),
            
            DOM.div(
                DOM.span("Time Step (s):", style="display: inline-block; width: 120px;"),
                DOM.input(
                    value="1e-11",
                    oninput=js"""function(e) {
                        const dt = parseFloat(e.target.value);
                        if(!isNaN(dt) && dt > 0) {
                            $(state.material_params)['dt'] = dt;
                        }
                    }""",
                    type="number",
                    step="1e-12",
                    min="1e-15",
                    style="width: 120px; margin-left: 10px;"
                ),
                style="margin-bottom: 8px;"
            ),
            
            DOM.div(
                DOM.span("Number of Steps:", style="display: inline-block; width: 120px;"),
                DOM.input(
                    value="100",
                    oninput=js"""function(e) {
                        const steps = parseInt(e.target.value);
                        if(!isNaN(steps) && steps > 0) {
                            $(state.material_params)['steps'] = steps;
                        }
                    }""",
                    type="number",
                    step="10",
                    min="1",
                    style="width: 120px; margin-left: 10px;"
                ),
                style="margin-bottom: 8px;"
            ),
            
            DOM.div(
                DOM.span("Save Every:", style="display: inline-block; width: 120px;"),
                DOM.input(
                    value="10",
                    oninput=js"""function(e) {
                        const save_every = parseInt(e.target.value);
                        if(!isNaN(save_every) && save_every > 0) {
                            $(state.material_params)['save_every'] = save_every;
                        }
                    }""",
                    type="number",
                    step="1",
                    min="1",
                    style="width: 120px; margin-left: 10px;"
                ),
                style="margin-bottom: 10px;"
            ),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
            """
        )
    )
end

"""
Create visualization panel
"""
function create_visualization_panel(state::SimulationState)
    return DOM.div(
        style="flex: 1;",
        
        DOM.div(
            DOM.h3("Visualization", style="color: #2980b9; margin-bottom: 10px;"),
            
            # Visualization controls
            DOM.div(
                DOM.div(
                    DOM.span("Component:", style="display: inline-block; width: 100px;"),
                    DOM.select(
                        DOM.option("Mx", value="mx"),
                        DOM.option("My", value="my"),
                        DOM.option("Mz", value="mz"),
                        DOM.option("Magnitude", value="mag"),
                        onchange=js"""function(e) {
                            $(state.material_params)['viz_component'] = e.target.value;
                        }""",
                        style="padding: 5px; border-radius: 4px; border: 1px solid #ddd;"
                    ),
                    style="margin-bottom: 10px;"
                ),
                
                button("Update Visualization", () -> update_visualization(state), "#2980b9"),
                
                style="margin-bottom: 15px; padding: 15px; background: #fff; border-radius: 6px;"
            ),
            
            # Visualization canvas
            DOM.div(
                DOM.div(
                    id="viz-canvas",
                    style="""
                        width: 100%;
                        height: 200px;
                        background: #f0f0f0;
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #999;
                        font-style: italic;
                    """,
                    "Visualization will appear here"
                ),
                
                style="margin-bottom: 15px; padding: 15px; background: #fff; border-radius: 6px;"
            ),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
            """
        )
    )
end

"""
Create help panel
"""
function create_help_panel()
    return DOM.div(
        style="flex: 1;",
        
        DOM.div(
            DOM.h3("Help & Documentation", style="color: #8e44ad; margin-bottom: 10px;"),
            
            # Quick start guide
            DOM.div(
                DOM.h4("Quick Start Guide", style="color: #555; margin-bottom: 5px;"),
                
                DOM.ol(
                    DOM.li("Set mesh and material parameters"),
                    DOM.li("Click 'Create Simulation' to initialize"),
                    DOM.li("Add interactions (Demag, Zeeman, etc.)"),
                    DOM.li("Set initial magnetization"),
                    DOM.li("Click 'Relax System' to find equilibrium"),
                    DOM.li("Click 'Run Dynamics' for time evolution"),
                    style="margin-left: 20px; line-height: 1.6; font-size: 0.9em;"
                ),
                
                style="margin-bottom: 15px; padding: 10px; background: #fff; border-radius: 6px;"
            ),
            
            style="""
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
            """
        )
    )
end

"""
Create main interface
"""
function create_main_interface(state::SimulationState)
    # Create tabs
    tabs = [
        ("Parameters", create_parameter_panel(state)),
        ("Presets", create_preset_panel(state)),
        ("Visualization", create_visualization_panel(state)),
        ("Help", create_help_panel())
    ]
    
    # Create tab headers
    tab_headers = DOM.div(
        style="""
            display: flex;
            border-bottom: 2px solid #ddd;
            margin-bottom: 15px;
        """,
        [DOM.button(
            tab_name,
            onclick=js"""function() {
                // Hide all tab contents
                const contents = document.querySelectorAll('.tab-content');
                contents.forEach(c => c.style.display = 'none');
                
                // Show selected tab content
                const selected = document.getElementById('tab-$(i)');
                if(selected) selected.style.display = 'block';
                
                // Update active tab
                const buttons = document.querySelectorAll('.tab-button');
                buttons.forEach(b => b.style.backgroundColor = '#f8f9fa');
                buttons.forEach(b => b.style.borderBottom = '2px solid transparent');
                this.style.backgroundColor = 'white';
                this.style.borderBottom = '2px solid #3498db';
            }""",
            style="""
                padding: 8px 16px;
                background-color: #f8f9fa;
                border: none;
                border-bottom: 2px solid transparent;
                cursor: pointer;
                font-size: 14px;
                color: #555;
            """,
            class="tab-button"
        ) for (i, (tab_name, _)) in enumerate(tabs)]...
    )
    
    # Create tab contents
    tab_contents = [DOM.div(
        tab_content,
        id="tab-$i",
        style="display: $(i == 1 ? "block" : "none");",
        class="tab-content"
    ) for (i, (_, tab_content)) in enumerate(tabs)]
    
    return DOM.div(
        style="padding: 20px;",
        
        # Header
        DOM.div(
            DOM.h1("MicroMagnetic.jl", 
                style="color: #3498db; margin: 0 0 10px 0;"),
            DOM.p("Micromagnetic Simulation Interface", 
                style="color: #666; margin: 0 0 20px 0;"),
            
            style="margin-bottom: 20px;"
        ),
        
        # Tabbed interface
        tab_headers,
        tab_contents...
    )
end

"""
Update visualization (stub function)
"""
function update_visualization(state::SimulationState)
    if state.sim === nothing
        state.status[] = "No simulation data to visualize"
        return
    end
    
    try
        state.status[] = "Updating visualization..."
        
        # Simple visualization update
        js_code = """
        const canvas = document.getElementById('viz-canvas');
        canvas.innerHTML = '<div style="padding: 20px; text-align: center;">' +
                          '<h4>Visualization Updated</h4>' +
                          '<p>Simulation data loaded</p>' +
                          '<p><em>Full visualization would be rendered here</em></p>' +
                          '</div>';
        """
        
        state.status[] = "Visualization updated"
        
    catch e
        state.status[] = "Error updating visualization: $e"
        @error "Failed to update visualization" exception=e
    end
end
