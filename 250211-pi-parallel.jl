#=
This program demonstrates parallel computing in Julia by calculating π using numerical integration.
It implements both parallel and sequential versions of the calculation to compare performance.

The calculation uses the fact that the integral of 4/(1+x²) from 0 to 1 equals π.
The program uses the rectangle method for numerical integration and compares
the efficiency of parallel vs sequential computation for different numbers of rectangles.

Key features:
- Parallel computation using multiple worker processes
- Performance comparison between parallel and sequential execution
- Error measurement against Julia's built-in π constant
- Timing measurements for both approaches
=#

using Distributed

# Initialize parallel processing
# Add worker processes if only one exists (the main process)
if nprocs() == 1
    addprocs(4)  # Create 4 additional worker processes
end

using Printf
using Dates  # For performance timing

# Display parallel processing setup information
println("Number of processors: ", nprocs())
println("Worker process IDs: ", workers())

# Define the integration function on all worker processes
# @everywhere ensures the function is available to all parallel workers
@everywhere begin
    # Function to integrate: f(x) = 4/(1+x²)
    # This function, when integrated from 0 to 1, equals π
    f(x) = 4/(1+(x*x))
end

# Parallel implementation of π calculation
function calc_pi_parallel(n)
    a, b = 0.0, 1.0  # Integration bounds
    dx = (b-a)/n     # Width of each rectangle
    x_values = range(a, b, length=n+1)  # Create evenly spaced points
    
    # Distribute the computation across workers and sum the results
    # @distributed (+) parallelizes the sum operation
    sumfx = @distributed (+) for x in x_values
        f(x)
    end
    return sumfx * dx  # Multiply by rectangle width to get final approximation
end

# Sequential implementation for comparison
function calc_pi_sequential(n)
    a, b = 0.0, 1.0  # Integration bounds
    dx = (b-a)/n     # Width of each rectangle
    x_values = range(a, b, length=n+1)  # Create evenly spaced points
    
    # Calculate sum using a single process
    sumfx = sum(f.(x_values))  # The dot (.) broadcasts f over all x_values
    return sumfx * dx
end

# Test function that runs both implementations with increasing precision
function test_pi(d)
    println("\nParallel Execution:")
    for e in 1:d
        n = 10^e  # Number of rectangles increases by powers of 10
        start_time = now()
        pi_approx = calc_pi_parallel(n)
        elapsed = Millisecond(now() - start_time).value / 1000.0
        
        # Print results with high precision
        @printf("%12d points: π ≈ %20.15f (error: %20.15f) time: %.4f seconds\n", 
                n, pi_approx, pi_approx - π, elapsed)
    end
    
    println("\nSequential Execution:")
    for e in 1:d
        n = 10^e
        start_time = now()
        pi_approx = calc_pi_sequential(n)
        elapsed = Millisecond(now() - start_time).value / 1000.0
        
        @printf("%12d points: π ≈ %20.15f (error: %20.15f) time: %.4f seconds\n", 
                n, pi_approx, pi_approx - π, elapsed)
    end
end

# Detailed comparison for a specific number of points
function compare_specific_case(n)
    println("\nDetailed comparison for n = ", n)
    
    # Test parallel version
    println("\nParallel version:")
    start_time = now()
    result_parallel = calc_pi_parallel(n)
    parallel_time = Millisecond(now() - start_time).value / 1000.0
    
    # Test sequential version
    println("\nSequential version:")
    start_time = now()
    result_sequential = calc_pi_sequential(n)
    sequential_time = Millisecond(now() - start_time).value / 1000.0
    
    # Print comparison results
    println("\nResults comparison:")
    println("Parallel:   Time = ", parallel_time, " seconds")
    println("Sequential: Time = ", sequential_time, " seconds")
    println("Speedup:    ", sequential_time / parallel_time, "x")
end

# Run performance tests
println("\nRunning performance comparison tests...")
test_pi(8)  # Test with up to 10^6 points

# Run detailed comparison
println("\nRunning detailed comparison for a large case...")
compare_specific_case(10^8)