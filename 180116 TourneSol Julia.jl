# First install required packages if not already installed:
# using Pkg
# Pkg.add("Plots")

using Plots

#=
This program generates a sunflower-like pattern (Tournesol) using the golden ratio.
The pattern is based on the mathematical principle found in nature where florets
in sunflowers are arranged in spiral patterns following the golden angle.

Key mathematical concepts:
- Golden ratio (φ ≈ 1.618033988749895)
- Golden angle (≈ 137.5°)
- Fibonacci spiral

The algorithm:
1. Creates points in a spiral pattern using the golden ratio
2. Each point's position is determined by:
   - Radius: Decreases exponentially with q^j
   - Angle: Increases by golden angle * j
3. Colors and sizes vary based on point position to create visual depth
=#

function tournesol()
    # --- Parameters ---
    q = 0.996  # Decay factor: controls how tightly the spiral winds
               # Values closer to 1 create looser spirals
               # Values closer to 0 create tighter spirals
    
    phi = (sqrt(5)-1)/2  # Golden ratio conjugate (≈ 0.618034)
                         # Used to calculate the golden angle (2π * phi)
    
    n = 200  # Number of points in the pattern
             # More points create denser patterns
             # Fewer points create sparser patterns

    # Generate sequence of indices
    j_values = 1:n  # Linear sequence from 1 to n
    
    # --- Calculate Coordinates ---
    # Generate x and y coordinates using polar to cartesian conversion:
    # x = r * cos(θ), y = r * sin(θ)
    # where r = q^j (exponential decay)
    # and θ = 2π * phi * j (golden angle rotation)
    x1 = [q^j * cos(2.0*pi*phi*j) for j in j_values]
    y1 = [q^j * sin(2.0*pi*phi*j) for j in j_values]
    
    # Scale and center the pattern
    # Multiply by 295 to scale the pattern
    # Add 295 to center it in the 590x590 plotting area
    x2 = 295.0 .+ x1.*295.0
    y2 = 295.0 .+ y1.*295.0
    
    # --- Visual Properties ---
    # Calculate marker sizes: decrease linearly from center
    # 300 is the base size, scaled down by position (1-j/n)
    sizes = [300*(1-j/n) for j in j_values]
    
    # Generate colors using RGB values that vary with position:
    # Red: decreases from 1 to 0
    # Green: increases from 0 to 1
    # Blue: increases from 0.5 to 1.0
    colors = [RGB(1.0-j/n, 0+j/n, 0.5+j/(2n)) for j in j_values]
    
    # --- Create Plot ---
    plot(
        x2, y2,
        seriestype=:scatter,      # Create scatter plot
        markersize=sizes ./ 30,   # Scale down marker sizes for better visibility
        markerstrokewidth=0,      # Remove marker borders
        markercolor=colors,       # Apply calculated colors
        markeralpha=0.5,         # Set transparency
        aspect_ratio=:equal,      # Maintain circular shape
        title="Tournesol",        # Plot title
        xlabel="X",               # X-axis label
        ylabel="Y",               # Y-axis label
        grid=true,               # Show grid
        legend=false,            # Hide legend
        size=(600,600)           # Set figure size in pixels
    )
    
    # Set plot boundaries
    # The 590x590 boundary ensures the pattern fits with some margin
    plot!(xlim=(0, 590), ylim=(0, 590))
end

# Create and display the plot
plt = tournesol()

# Optional: Save the figure
# savefig(plt, "tournesol.png")  # Uncomment to save the plot as PNG