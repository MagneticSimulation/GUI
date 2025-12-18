"""
Create the main interface
"""
function create_interface()
    # Create and return Bonito.App instance
    return Bonito.App() do
        # Initialize simulation state inside the App constructor
        state = SimulationState()
        
        # Create main UI
        ui = DOM.div(
            style="""
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                max-width: 1400px;
                margin: 0 auto;
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            """,
            
            # Header
            DOM.div(
                DOM.h1("MicroMagnetic.jl Interface", 
                    style="color: white; margin: 0; font-size: 2.5em;"),
                DOM.p("Interactive micromagnetic simulation control panel",
                    style="color: rgba(255, 255, 255, 0.8); margin: 10px 0 30px 0;"),
                
                style="""
                    text-align: center;
                    margin-bottom: 40px;
                    padding: 20px;
                    background: rgba(0, 0, 0, 0.2);
                    border-radius: 10px;
                """
            ),
            
            # Main content area
            DOM.div(
                style="display: flex; gap: 20px;",
                
                # Left panel: Parameters and controls
                create_parameter_panel(state),
                
                # Right panel: Presets and advanced controls
                create_preset_panel(state)
            ),
            
            # Simulation info
            create_simulation_info(state),
            
            # Footer
            DOM.div(
                style="""
                    margin-top: 40px;
                    padding-top: 20px;
                    border-top: 1px solid rgba(255, 255, 255, 0.2);
                    color: rgba(255, 255, 255, 0.7);
                    font-size: 0.9em;
                    text-align: center;
                """,
                DOM.p("MicroMagnetic.jl Interface v1.0"),
                DOM.p("Based on Standard Problems 4 & 5"),
                DOM.p("Press Ctrl+1 for SP4, Ctrl+2 for SP5, Ctrl+R to relax, Ctrl+D for dynamics")
            )
        )
        
        # Add responsive CSS
        responsive_css = DOM.style("""
            @media (max-width: 768px) {
                .main-content {
                    flex-direction: column !important;
                }
                
                .parameter-section {
                    margin-bottom: 15px !important;
                    padding: 15px !important;
                }
                
                input, select {
                    width: 100% !important;
                    margin-left: 0 !important;
                    margin-top: 5px !important;
                }
                
                button {
                    display: block !important;
                    width: 100% !important;
                    margin-bottom: 10px !important;
                }
            }
            
            /* Hover effects */
            button:hover:not(:disabled) {
                opacity: 0.9 !important;
                transform: translateY(-1px);
                transition: all 0.2s ease;
            }
            
            /* Focus styles */
            input:focus, select:focus, button:focus {
                outline: 2px solid #3498db;
                outline-offset: 2px;
            }
            
            /* Animation for status */
            .status-message {
                transition: color 0.3s ease;
            }
        """)
        
        # Add keyboard shortcuts
        shortcuts_script = DOM.script("""
            document.addEventListener('keydown', function(e) {
                // Ctrl+1 for Standard Problem 4
                if(e.ctrlKey && e.key === '1') {
                    e.preventDefault();
                    const sp4Button = document.querySelector('button:contains("Standard Problem 4")');
                    if(sp4Button) {
                        sp4Button.click();
                    }
                }
                
                // Ctrl+2 for Standard Problem 5
                if(e.ctrlKey && e.key === '2') {
                    e.preventDefault();
                    const sp5Button = document.querySelector('button:contains("Standard Problem 5")');
                    if(sp5Button) {
                        sp5Button.click();
                    }
                }
                
                // Ctrl+R to relax
                if(e.ctrlKey && e.key === 'r') {
                    e.preventDefault();
                    const relaxButton = document.querySelector('button:contains("Relax System")');
                    if(relaxButton && !relaxButton.disabled) {
                        relaxButton.click();
                    }
                }
                
                // Ctrl+D to run dynamics
                if(e.ctrlKey && e.key === 'd') {
                    e.preventDefault();
                    const runButton = document.querySelector('button:contains("Run Dynamics")');
                    if(runButton && !runButton.disabled) {
                        runButton.click();
                    }
                }
            });
        """)
        
        # Wrap UI with CSS and shortcuts
        ui = DOM.div(
            responsive_css,
            ui,
            shortcuts_script
        )
        
        return ui
    end
end