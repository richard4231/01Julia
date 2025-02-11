## pil.jl (c) 2015 David A. van Leeuwen and others
## This file is licensed under the MIT software license.

## Various algorithms to compute π in many (hexa)decimal digits.

## We count digits after the period, e.g., for ndigits=2, π ≈ 3.14
## https://github.com/davidavdav/Pi.jl/blob/master/src/pi.jl

nbits(ndigits::Int) = ceil(Int, log(2,10) * (ndigits+1))

function gaussLegendre_pi(ndigits::Integer)
    setprecision(nbits(ndigits)) do
        n = ceil(Int, log2(ndigits))
        a = BigFloat(1)
        b = a / √ BigFloat(2)
        t = a / BigFloat(4)
        x = a
        while n > 0
            y = a
            a = (a + b) / 2
            b = √(b * y)
            t -= x * (y - a)^2
            x *= 2
            n -= 1
        end
        (a + b)^2 / (4 * t)
    end
end

function chudnovsky2_1989_pi(ndigits::Int)
    setprecision(nbits(ndigits)) do
        ɛ = BigFloat(10) ^ -ndigits
        threek = sixk = k = s = BigFloat(0)
        sign = k!3 = threek! = sixk! = BigFloat(1)
        denfact = BigFloat(640320) ^ 3
        den = √denfact
        while true
            lasts = s
            s += sign * sixk! * (13591409 + 545140134k) / (threek! * k!3 * den)
            if abs(lasts - s) < ɛ break end
            k += 1
            for i=1:3
                threek += 1
                threek! *= threek
            end
            for i=1:6
                sixk += 1
                sixk! *= sixk
            end
            k!3 *= k*k*k
            den *= denfact
            sign = -sign
        end
        1 / 12s
    end
end

# Bailey, Borwein and Plouffe
function bbp_pi_digit(n::Int)
    if n == 0
        return 3
    else
        n -= 1
    end
    const o = [1, 4, 5, 6]
    const w = [4, -2, -1, -1]
    frac = 0.
    for k=0:n
        for i=1:4
            den = 8k+o[i]
            frac += (w[i] * modpow(16, n-k, den)) / den
        end
    end
    floor(Int, mod(frac, 1) * 16)::Int
end

function modpow(b, n::Integer, c)
    ## wikipedia
    r = 1 % c
    b %= c
    while n > 0
        if isodd(n)
            r = (r*b) % c
        end
        n >>= 1
        b = (b*b) % c
    end
    return r
    ## Bailey, Borwein, Borwein, Plouffe (incorrect?)
    t = nextpow2(n+1) >> 1
    r = 1
    while true
        if n ≥ t
            r = (b*r) % c
            n -= t
        end
        t = t ÷ 2
        if t < 1
            break
        end
        r = (r*r) % c
    end
    return r
    ## Straightforward (slow)
    r = 1
    while n > 0
        r = (r*b) % c
        n -= 1
    end
    r
end

# https://www.juliabloggers.com/computing-the-hexadecimal-value-of-pi/
function pi_string_threaded(N)
    digits = Vector{Int}(N)
    Threads.@threads for n in eachindex(digits)
        digits[n] = bbp_pi_digit(n)
    end
    return "3." * join(digits)
end

#println(Dates.Time(now()))
#a=Dates.Time(now())

# @time println(chudnovsky2_1989_pi(10^4))
# @time writedlm("Pi.txt", gaussLegendre_pi(10^5))
@time println(gaussLegendre_pi(10^4))

# @time println(bbp_pi_digit(10^7))

# Threads.nthreads()
# bbp_pi_digit(10^5) == pi_string_threaded(10^4)
# @time println(pi_string_threaded(10^4))
# println("Fertig!")

#println(Dates.Time(now()))
#b=Dates.Time(now())
#println(b-a)
