#=
                | j |
              | h | i |
            | e | f | g |
          | a | b | c | d |

Beginn bei 1, Ende bei 999
mit 0 erlaubt: 555 0 0 555 produziert 18 Fünfen...
=#

using Distributed
#interrupt()
#nprocs()
#addprocs()

@everywhere module NumberWalls

    using Distributed

    function countDigit(x)
        i=0
        a=x%10 #ev/10
        b=(x.-a)%100 #ev b=((x.-a)%100)./10
        c=(x.-a.-b)%1000 #ev c=((x.-a.-b.*10)%100)./100
        d=(x.-a.-b.-c)%10000;
        b=b./10;c=c./100;d=d./1000
            if a==5 i=i.+1 end
            if b==5 i=i.+1 end
            if c==5 i=i.+1 end
            if d==5 i=i.+1 end
        return i
    end

    function checkNumberwall(first_base_stone)
        MIN_NUM_FIVES = 12 # Mindestanzahl Fünfen, die berücksichtigt werden soll.
        A = [0, 0, 0, 0, 0]
        upper_bound = 999 # Obergrenze der eingesetzten Zahlen. Für Testzwecke < 999.
        a = first_base_stone
        for b in 1:upper_bound, c in 1:upper_bound, d in a:upper_bound
                        e=a.+b;f=b.+c;g=c.+d;h=e.+f;i=f.+g;j=h.+i
                        s = countDigit.(a).+countDigit.(b).+countDigit.(c).+countDigit.(d).+countDigit.(e).+countDigit.(f).+countDigit.(g).+countDigit.(h).+countDigit.(i).+countDigit.(j)

                        if s >= MIN_NUM_FIVES
                            B = [s, a, b, c, d]
                            A = vcat(A, B)
                        end
        end
        return(A)
    end
end

function main()
    range_first_basestone = [1:999;] #zu Testzwecken auf 100 setzen, sonst 999
    A = pmap(NumberWalls.checkNumberwall,range_first_basestone)

    C = Int[]
    for i in 1:length(A)
        if length(A[i]) > 5
            for j in 2:(Int(length(A[i])/5))
                B = Int[]
                for k in 1:5
                    B = vcat(B,A[i][5*(j-1)+k])
                end
                C = vcat(C,[B])
            end
        end
    end

    for l in 1:(length(C)-1)
        for m in (l+1):length(C)
            if C[l][1] == C[m][1]
                if C[l][2]==C[m][5] && C[l][3]==C[m][4] && C[l][4]==C[m][3]
                    for n in 1:5
                        C[m][n]= 0
                    end
                end
            end
        end
    end

    D = []
    for o in 1:length(C)
        if C[o][1]> 0
            D = vcat(D,[C[o]])
        end
    end

    outfile = "/Users/andreasrichard/OneDrive/01JupyterandCo/01Julia/01Output/Liste.txt"
    open(outfile, "w") do f
        for p in 1:length(D)
            println(f,"Nr:", p, "\t", D[p])
        end
    end
end

@time main()

#=
15208.097797 seconds (877.20 k allocations: 45.241 MiB, 0.00% gc time)
1:999 iMac über alle 8 Kerne: 4h 15min
Effizienzsteigerung zur ersten Version um 700%

s>15; iMac, 21.09.21; d in min:upper_bound
12.560751 seconds (2.51 M allocations: 134.288 MiB, 0.23% gc time)
Halbierung der Zeit...

s>=19; iMac, 21.09.21; d in min:upper_bound
7249.890675 seconds (3.00 M allocations: 170.508 MiB, 0.00% gc time)
1:999 iMac über alle 8 Kerne: 2h 0min 50s
Halbierung der Zeit... etwas mehr Speicher

s>= 18; macMini, 20.04.24
4742.512309 seconds (875.07 k allocations: 58.063 MiB, 0.00% gc time, 0.01% compilation time)
1:999 4 Kerne: 4742.5: 1h 19 Minuten 2 Sekunden

=#