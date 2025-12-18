# interface/utils.jl

"""
Create simulation info display
"""
function create_simulation_info(state::SimulationState)
    return DOM.div(
        style="margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 8px;",
        
        DOM.h3("Simulation Info", style="color: #3498db; margin-bottom: 10px;"),
        
        DOM.div(
            DOM.strong("Status: "),
            DOM.span(
                state.status,
                style="""
                    color: $(state.status[] == "Ready" ? "#7f8c8d" : 
                            occursin("Error", state.status[]) ? "#e74c3c" : "#27ae60");
                """
            ),
            style="margin-bottom: 8px;"
        ),
        
        DOM.div(
            DOM.strong("Mesh: "),
            DOM.span(
                "$(state.mesh_params[]["nx"])×$(state.mesh_params[]["ny"])×$(state.mesh_params[]["nz"]) cells",
                style="color: #666;"
            ),
            style="margin-bottom: 8px;"
        ),
        
        DOM.div(
            DOM.strong("Cell size: "),
            DOM.span(
                "$(state.mesh_params[]["dx"])×$(state.mesh_params[]["dy"])×$(state.mesh_params[]["dz"]) m",
                style="color: #666;"
            ),
            style="margin-bottom: 8px;"
        ),
        
        DOM.div(
            DOM.strong("Material: "),
            DOM.span(
                "Ms=$(state.material_params[]["Ms"]) A/m, A=$(state.material_params[]["A"]) J/m",
                style="color: #666;"
            ),
            style="margin-bottom: 8px;"
        ),
        
        DOM.div(
            DOM.strong("Interactions: "),
            DOM.span(
                state.sim === nothing ? "None" : "At least one",
                style="color: #666;"
            ),
            style="margin-bottom: 8px;"
        ),
        
        DOM.div(
            DOM.strong("Simulation: "),
            DOM.span(
                state.sim === nothing ? "Not created" : "Ready",
                style="color: $(state.sim === nothing ? "#e74c3c" : "#27ae60");"
            ),
            style="margin-bottom: 8px;"
        )
    )
end

"""
Create a progress bar
"""
function create_progress_bar(value::Observable, max::Observable)
    return DOM.div(
        style="width: 100%; background-color: #ecf0f1; border-radius: 4px; overflow: hidden;",
        DOM.div(
            style="""
                width: $(100 * value[] / max[])%;
                height: 20px;
                background-color: #3498db;
                transition: width 0.3s ease;
            """
        )
    )
end

"""
Format scientific notation
"""
function format_scientific(value::Float64)
    if abs(value) >= 1e3 || abs(value) <= 1e-3
        return string(round(value, sigdigits=3))
    else
        return string(round(value, digits=3))
    end
end

"""
Create a tooltip
"""
function create_tooltip(text::String, tooltip_text::String)
    return DOM.div(
        style="position: relative; display: inline-block;",
        
        DOM.span(
            text,
            style="border-bottom: 1px dotted #666; cursor: help;"
        ),
        
        DOM.div(
            tooltip_text,
            style="""
                visibility: hidden;
                width: 200px;
                background-color: #555;
                color: #fff;
                text-align: center;
                border-radius: 6px;
                padding: 5px;
                position: absolute;
                z-index: 1;
                bottom: 125%;
                left: 50%;
                margin-left: -100px;
                opacity: 0;
                transition: opacity 0.3s;
            """,
            onmouseover=js"""function() { this.style.visibility = 'visible'; this.style.opacity = 1; }""",
            onmouseout=js"""function() { this.style.visibility = 'hidden'; this.style.opacity = 0; }"""
        )
    )
end

"""
Create a notification
"""
function create_notification(message::String, type::String="info")
    colors = Dict(
        "info" => "#3498db",
        "success" => "#27ae60",
        "warning" => "#f39c12",
        "error" => "#e74c3c"
    )
    
    return DOM.div(
        message,
        style="""
            padding: 10px 15px;
            background-color: $(colors[type]);
            color: white;
            border-radius: 4px;
            margin: 10px 0;
            animation: fadeIn 0.5s;
        """
    )
end

"""
Create a loading spinner
"""
function create_loading_spinner()
    return DOM.div(
        style="""
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        """
    )
end

"""
Create a modal dialog
"""
function create_modal(title::String, content, on_close::Function)
    return DOM.div(
        style="""
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        """,
        
        DOM.div(
            style="""
                background: white;
                padding: 20px;
                border-radius: 8px;
                min-width: 300px;
                max-width: 600px;
                max-height: 80vh;
                overflow-y: auto;
            """,
            
            DOM.div(
                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
                DOM.h3(title, style="margin: 0; color: #3498db;"),
                DOM.button(
                    "×",
                    onclick=js"""function() { $(on_close)(); }""",
                    style="""
                        background: none;
                        border: none;
                        font-size: 24px;
                        cursor: pointer;
                        color: #999;
                    """
                )
            ),
            
            content,
            
            DOM.div(
                style="margin-top: 20px; text-align: right;",
                DOM.button(
                    "Close",
                    onclick=js"""function() { $(on_close)(); }""",
                    style="""
                        background-color: #3498db;
                        color: white;
                        border: none;
                        padding: 8px 16px;
                        border-radius: 4px;
                        cursor: pointer;
                    """
                )
            )
        )
    )
end

"""
Create a data table
"""
function create_data_table(headers::Vector{String}, data::Vector{Vector{Any}})
    return DOM.table(
        style="width: 100%; border-collapse: collapse;",
        
        DOM.thead(
            DOM.tr(
                [DOM.th(header, style="padding: 10px; border-bottom: 2px solid #ddd; text-align: left;") 
                 for header in headers]...
            )
        ),
        
        DOM.tbody(
            [DOM.tr(
                [DOM.td(cell, style="padding: 10px; border-bottom: 1px solid #eee;") 
                 for cell in row]...
            ) for row in data]...
        )
    )
end

"""
Create a chart container
"""
function create_chart_container(title::String, id::String)
    return DOM.div(
        style="margin: 20px 0;",
        
        DOM.h4(title, style="color: #555; margin-bottom: 10px;"),
        
        DOM.div(
            id=id,
            style="""
                width: 100%;
                height: 300px;
                background: #f8f9fa;
                border: 1px solid #ddd;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #999;
            """,
            "Chart will be displayed here"
        )
    )
end

"""
Create a parameter slider
"""
function create_slider(label::String, obs::Observable, key::String, min::Float64, max::Float64, step::Float64)
    return DOM.div(
        style="margin: 10px 0;",
        
        DOM.div(
            style="display: flex; justify-content: space-between; margin-bottom: 5px;",
            DOM.span(label, style="font-weight: bold;"),
            DOM.span(
                obs[][key],
                style="color: #3498db;"
            )
        ),
        
        DOM.input(
            value=string(obs[][key]),
            oninput=js"""function(e) {
                const value = parseFloat(e.target.value);
                if(!isNaN(value)) {
                    const current = $obs[];
                    current[$key] = value;
                    Bonito.@set($obs = current);
                }
            }""",
            type="range",
            min=string(min),
            max=string(max),
            step=string(step),
            style="width: 100%;"
        )
    )
end

"""
Create a toggle switch
"""
function create_toggle(label::String, obs::Observable, key::String)
    return DOM.div(
        style="display: flex; align-items: center; margin: 10px 0;",
        
        DOM.span(label, style="margin-right: 10px;"),
        
        DOM.label(
            style="position: relative; display: inline-block; width: 50px; height: 24px;",
            
            DOM.input(
                type="checkbox",
                checked=obs[][key],
                onchange=js"""function(e) {
                    const current = $obs[];
                    current[$key] = e.target.checked;
                    Bonito.@set($obs = current);
                }""",
                style="opacity: 0; width: 0; height: 0;"
            ),
            
            DOM.span(
                style="""
                    position: absolute;
                    cursor: pointer;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background-color: #ccc;
                    transition: .4s;
                    border-radius: 24px;
                """,
                
                DOM.span(
                    style="""
                        position: absolute;
                        content: "";
                        height: 16px;
                        width: 16px;
                        left: 4px;
                        bottom: 4px;
                        background-color: white;
                        transition: .4s;
                        border-radius: 50%;
                    """
                )
            )
        )
    )
end
