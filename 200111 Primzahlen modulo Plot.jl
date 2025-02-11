using Primes
using Plots
using Base.Threads

"""
Efficient implementation of prime counting functions for residue classes modulo 4.
This implementation uses:
1. Parallel processing for large ranges
2. Optimized sieve-based approach
3. Efficient memory management
4. Vectorized operations where possible
"""

"""
    create_prime_sieve(n::Integer)

Creates a boolean array where true indicates prime numbers up to n.
Uses the Sieve of Eratosthenes algorithm for efficiency.
"""
function create_prime_sieve(n::Integer)
    if n < 2
        return falses(n)
    end
    
    # Initialize sieve array
    sieve = trues(n)
    sieve[1] = false  # 1 is not prime
    
    # Apply sieve
    @inbounds for i in 2:isqrt(n)
        if sieve[i]
            # Mark multiples as non-prime
            for j in (i*i):i:n
                sieve[j] = false
            end
        end
    end
    
    return sieve
end

"""
    count_primes_mod4(n::Integer)

Counts primes in residue classes 1 and 3 modulo 4 up to n.
Returns a tuple of counts (primes ≡ 1 (mod 4), primes ≡ 3 (mod 4))
Uses parallel processing for large ranges.
"""
function count_primes_mod4(n::Integer)
    if n < 2
        return (0, 0)
    end
    
    # Create sieve for prime detection
    sieve = create_prime_sieve(n)
    
    # Initialize counters
    count_mod1 = Atomic{Int}(0)
    count_mod3 = Atomic{Int}(0)
    
    # Parallel processing for large ranges
    if n > 10000
        # Split work among available threads
        @threads for i in 2:n
            if sieve[i]
                remainder = mod(i, 4)
                if remainder == 1
                    atomic_add!(count_mod1, 1)
                elseif remainder == 3
                    atomic_add!(count_mod3, 1)
                end
            end
        end
    else
        # Sequential processing for small ranges
        for i in 2:n
            if sieve[i]
                remainder = mod(i, 4)
                if remainder == 1
                    atomic_add!(count_mod1, 1)
                elseif remainder == 3
                    atomic_add!(count_mod3, 1)
                end
            end
        end
    end
    
    return (count_mod1[], count_mod3[])
end

"""
    analyze_prime_distribution(range::AbstractRange)

Analyzes and plots the distribution of primes in residue classes 1 and 3 modulo 4
over the given range. Returns the plot and timing information.
"""
function analyze_prime_distribution(range::AbstractRange)
    # Preallocate arrays for results
    counts_mod1 = zeros(Int, length(range))
    counts_mod3 = zeros(Int, length(range))
    
    # Calculate counts for each point in range
    @time for (idx, n) in enumerate(range)
        counts_mod1[idx], counts_mod3[idx] = count_primes_mod4(n)
    end
    
    # Create plot
    p = plot(range, [counts_mod1 counts_mod3],
            label=["Primes ≡ 1 (mod 4)" "Primes ≡ 3 (mod 4)"],
            title="Distribution of Primes in Residue Classes Modulo 4",
            xlabel="n",
            ylabel="Count",
            linewidth=2,
            legend=:topleft)
    
    return p
end

# Example usage and testing


# Additional analysis features
"""
    print_distribution_stats(n::Integer)

Prints statistical analysis of prime distribution up to n.
"""
function print_distribution_stats(n::Integer)
    counts = count_primes_mod4(n)
    total = sum(counts)
    
    println("Analysis up to n = $n:")
    println("Primes ≡ 1 (mod 4): $(counts[1]) ($(round(100*counts[1]/total, digits=2))%)")
    println("Primes ≡ 3 (mod 4): $(counts[2]) ($(round(100*counts[2]/total, digits=2))%)")
    println("Total primes considered: $total")
    println("Theoretical expectation: Approximately equal distribution")
end

# Run statistics for a sample size
n = 10000
print_distribution_stats(n)
x = 1:n
@time p = analyze_prime_distribution(x)
display(p)