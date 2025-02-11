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
        a=x%10 
        b=(x.-a)%100 
        c=(x.-a.-b)%1000 
        d=(x.-a.-b.-c)%10000;
        b=b./10;c=c./100;d=d./1000
            if a==5 i=i.+1 end
            if b==5 i=i.+1 end
            if c==5 i=i.+1 end
            if d==5 i=i.+1 end
        return i
    end

    function checkNumberwall(first_base_stone)
        MIN_NUM_FIVES = 18 # Mindestanzahl Fünfen, die berücksichtigt werden soll.
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
    for i in eachindex(A)
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

    for l in eachindex(C)[1:end-1]
        for m in (l+1):lastindex(C)
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
    for o in eachindex(C)
        if C[o][1]> 0
            D = vcat(D,[C[o]])
        end
    end

    outfile = "./01Julia/01Output/Liste.txt"
    open(outfile, "w") do f
        for p in eachindex(D)
            println(f,"Nr:", p, "\t", D[p])
        end
    end
end

@time main()