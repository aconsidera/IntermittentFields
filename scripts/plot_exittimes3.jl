using DrWatson
@quickactivate("IntermittentFields");
using JLD2
using Statistics
using StatsPlots;plotly()
using StatsBase
using LinearAlgebra

cm = Array{PlotUtils.ColorGradient}(undef, 2)
cm[1] = cgrad(:heat, 4, categorical = true);
cm[2] = cgrad(:blues, 4, categorical = true);

# zeromode =========================================================================
begin  
    α = 0.6
    Nref = 2^13
    plt = plot(title= "relaxation of shapes α=$α, Np=4e5",ylims=(-3,3),xlims=(0,1));
    plot!(yaxis = "(PDF_N-PDF_$Nref)*(N/$Nref)^(0.7)")
    for (j, α) in enumerate([α])
        #reference values
        allf = filter(x->occursin("ET3l2normR12R13", x), readdir(datadir("sims","zeromodes","piecewisekernel"), join = true))
        allf = filter(x->occursin("N=$Nref", x), allf)
        allf = filter(x->occursin("α=$α", x), allf)
        
        f1 = jldopen(allf[1], "r")
        T = f1["t"]
        p = f1["p"]
        #choosing observable
        R1 = vec(abs.(p[:,1,:]-p[:,2,:]))
        R2 = vec(abs.(p[:,2,:]-p[:,3,:]))
        R3 = vec(abs.(p[:,1,:]-p[:,3,:]))
        s = length(R1)
        close(f1)
        if length(allf)>1    
            for i in 2:length(allf)
                f = jldopen(datadir("sims", allf[i]),"r")
                #T = [T f["ET"]]
                p = f["p"]
                #choosing observables
                R1 = [R1; vec(abs.(p[:,1,:]-p[:,2,:]))]
                R2 = [R2; vec(abs.(p[:,2,:]-p[:,3,:]))]
                R3 = [R3; vec(abs.(p[:,1,:]-p[:,3,:]))] 
            end
        end
        pdf_ref = normalize(fit(Histogram, R1, 0:0.001:1), mode=:pdf)
        
        #other values
        for (k, i) in enumerate(7:Int(log2(Nref))-1)
            N = 2^i
            allf = filter(x->occursin("ET3l2normR12R13", x), readdir(datadir("sims","zeromodes","piecewisekernel"), join = true))
            allf = filter(x->occursin("N=$N", x), allf)
            allf = filter(x->occursin("α=$α", x), allf)
            
            f1 = jldopen(datadir("sims", "zeromodes", "piecewisekernel", allf[1]), "r")
            #T = f1["t"]
            p = f1["p"]
            #choosing observable
            r1 = vec(abs.(p[:,1,:]-p[:,2,:]))
            r2 = vec(abs.(p[:,2,:]-p[:,3,:]))
            r3 = vec(abs.(p[:,1,:]-p[:,3,:]))
            close(f1)
            if length(allf)>1 
                for i in 2:length(allf)
                    f = jldopen(datadir("sims", "zeromodes", allf[i]),"r")
                    #T = [T f["t"]]
                    p = f["p"]
                    #choosing observables
                    r1 = [r1; vec(abs.(p[:,1,:]-p[:,2,:]))]
                    r2 = [r2; vec(abs.(p[:,2,:]-p[:,3,:]))]
                    r3 = [r3; vec(abs.(p[:,1,:]-p[:,3,:]))] 
                end
            end
            
            pdf = normalize(fit(Histogram,r1, 0:0.001:1.0), mode=:pdf)
            plot!(Array(range(0,stop=1,length=1000),),  (N/Nref)^0.7 * (pdf.weights - pdf_ref.weights),label="N=$N")#, c=cm[j][k+1])
        end
        
    end
    plt = @show plt
end


# PDF of shape  =========================================================================
#path = "rescaled_kernel"
path = "old"
path  = "piecewisekernel"
prefix = "ET3l2normR12R13"
prefix = "ET3"

begin
    α = 0.6
    plt = plot(title= "pdf of shapes α=$α, Np=4e5",ylims=(0,14),xlims=(0.0,1));
    plot!(yaxis = "PDF_N")
    #plot!(yscale = :log, ylims = (1e-1,20))
    for (j, α) in enumerate([α])
        for (k, i) in enumerate(7:13)
            N = 2^i
            allf = filter(x->occursin(prefix, x), readdir(datadir("sims","zeromodes",path), join = true))
            allf = filter(x->occursin("N=$N", x), allf)
            allf = filter(x->occursin("α=$α", x), allf)
            
            f1 = jldopen(datadir("sims", "zeromodes", path, allf[1]), "r")
            #T = f1["t"]
            p = f1["p"]
            #choosing observable
            r1 = vec(abs.(p[:,1,:]-p[:,2,:]))
            r2 = vec(abs.(p[:,2,:]-p[:,3,:]))
            r3 = vec(abs.(p[:,1,:]-p[:,3,:]))
            close(f1)
            if length(allf)>1 
                for i in 2:length(allf)
                    f = jldopen(datadir("sims", "zeromodes", allf[i]),"r")
                    #T = [T f["t"]]
                    p = f["p"]
                    #choosing observables
                    r1 = [r1; vec(abs.(p[:,1,:]-p[:,2,:]))]
                    r2 = [r2; vec(abs.(p[:,2,:]-p[:,3,:]))]
                    r3 = [r3; vec(abs.(p[:,1,:]-p[:,3,:]))] 
                end
            end
            
            pdf = normalize(fit(Histogram,r1, 0:0.001:1.0), mode=:pdf)
            plot!(Array(range(0,stop=1,length=1000),),  pdf.weights, label="N=$N") #, c=cm[j][k+1])
        end
        
    end
    plt = @show plt
end


# pdf of τ^(3)  =========================================================================
begin
    α = 0.0
    plt = plot(title= "pdf of τ_3 α=$α, Np=4e5", ylabel = "PDF", xlabel = "τ^(3)")
    plot!(ylims=(1e-3,10),xlims=(0,10), xscale = :linear, yscale = :log);
    #plot!(ylims=(0,4),xlims=(0,10),  yscale = :linear);
    for (j, α) in enumerate([α])
        for (k, i) in enumerate(7:11)
            N = 2^i
            allf = filter(x->occursin("ET3l2normR12R13", x), readdir(datadir("sims","zeromodes","piecewisekernel"), join = true))
            allf = filter(x->occursin("N=$N", x), allf)
            allf = filter(x->occursin("α=$α", x), allf)
            
            f1 = jldopen(datadir("sims", "zeromodes", "piecewisekernel", allf[1]), "r")
            t = f1["t"]
            p = f1["p"]
            #choosing observable
            r1 = vec(abs.(p[:,1,:]-p[:,2,:]))
            r2 = vec(abs.(p[:,2,:]-p[:,3,:]))
            r3 = vec(abs.(p[:,1,:]-p[:,3,:]))
            t =  vec(t)
            close(f1)
            if length(allf)>1 
                for i in 2:length(allf)
                    f = jldopen(datadir("sims", "zeromodes", allf[i]),"r")
                    t = [t; vec(f["t"])]
                    p = f["p"]
                    #choosing observables
                    r1 = [r1; vec(abs.(p[:,1,:]-p[:,2,:]))]
                    r2 = [r2; vec(abs.(p[:,2,:]-p[:,3,:]))]
                    r3 = [r3; vec(abs.(p[:,1,:]-p[:,3,:]))] 
                end
            end
            
            pdf = normalize(fit(Histogram, t, 0:0.01:10), mode=:pdf)
            plot!(Array(range(0,stop=10,length=1000),),  pdf.weights, label="N=$N") #, c=cm[j][k+1])
        end
    end
    plt = @show plt
end


# pdf of τ^(3)_λ =========================================================================
begin
    α = 0.6
    N = 2^11
    plt = plot(title= "pdf of τ_3 α=$α, Np=4e5", ylabel = "PDF", xlabel = "τ^(3)")
    #plot!(ylims=(1e-3,10),xlims=(0,10), xscale = :linear, yscale = :log);
    plot!(ylims=(0,4),xlims=(0,10),  yscale = :linear);
    for (j, α) in enumerate([α])
        allf = filter(x->occursin("ET3l2normR12R13", x), readdir(datadir("sims","zeromodes","piecewisekernel"), join = true))
        allf = filter(x->occursin("N=$N", x), allf)
        allf = filter(x->occursin("α=$α", x), allf)
        
        f1 = jldopen(datadir("sims", "zeromodes", "piecewisekernel", allf[1]), "r")
        t = f1["t"]
        t2 = f1["t2"]
        t4 = f1["t4"]
        t8 = f1["t8"]
        t16 = f1["t16"]
        t32 = f1["t32"]
        t64 = f1["t64"]
        
        #choosing observable
        t = vec(t)
        t2 = vec(t2)
        t4 = vec(t4)
        t4 = vec(t4)
        t8 = vec(t8)
        t16 = vec(t16)
        t32 = vec(t32)
        t64 = vec(t64)
        close(f1)
        if length(allf)>1 
            for i in 2:length(allf)
                f = jldopen(datadir("sims", "zeromodes", allf[i]),"r")
                t = [t; vec(f["t"])]
                t2 = [t2; vec(f["t2"])]
                t4 = [t4; vec(f["t4"])]
                t8 = [t8; vec(f["t8"])]
                t16 = [t16; vec(f["t16"])]
                t32 = [t32; vec(f["t32"])]
                t64 = [t64; vec(f["t64"])]
            end
        end
        
        pdf = normalize(fit(Histogram, t, 0:0.01:10), mode=:pdf)
        pdf2 = normalize(fit(Histogram, t2, 0:0.01:10), mode=:pdf)
        pdf4 = normalize(fit(Histogram, t4, 0:0.01:10), mode=:pdf)
        pdf8 = normalize(fit(Histogram, t8, 0:0.01:10), mode=:pdf)
        pdf16 = normalize(fit(Histogram, t16, 0:0.01:10), mode=:pdf)
        pdf32 = normalize(fit(Histogram, t32, 0:0.01:10), mode=:pdf)
        pdf64 = normalize(fit(Histogram, t64, 0:0.01:10), mode=:pdf)
        

        plot!(Array(range(0,stop=10,length=1000),),  pdf.weights, label="λ=1") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf2.weights, label="λ=1/2") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf4.weights, label="λ=1/4") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf8.weights, label="λ=1/8") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf16.weights, label="λ=1/16") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf32.weights, label="λ=1/32") #, c=cm[j][k+1])
        plot!(Array(range(0,stop=10,length=1000),),  pdf64.weights, label="λ=1/64") #, c=cm[j][k+1])
    end
    plt = @show plt
end

#  <τ^(3)> x λ =========================================================================
begin
    N = 2^11
    plt = plot(title= " <τ_3> x λ, Np=4e5", ylabel = "<τ^(3)>", xlabel = "λ")
    plot!(ylims=(1e-4,10),xlims=(1e-2,2), xscale = :log, yscale = :log, legend = :topleft);
    #plot!(ylims=(0,4),xlims=(0,10),  yscale = :linear);
    
    λ = [1/2^i for i in 0:6]
    plot!(λ, λ.^2, label = "λ^2", c = :black, ls = :dash)
    ms = [:circle, :xcross]
    c = [:blue, :red]
    lb = ["α = 0", "α = 0.6"]
    α = [0.0, 0.6 ]
    for (j, α) in enumerate(α)
        allf = filter(x->occursin("ET3l2normR12R13", x), readdir(datadir("sims","zeromodes","piecewisekernel"), join = true))
        allf = filter(x->occursin("N=$N", x), allf)
        allf = filter(x->occursin("α=$α", x), allf)
        
        f1 = jldopen(datadir("sims", "zeromodes", "piecewisekernel", allf[1]), "r")
        t = f1["t"]
        t2 = f1["t2"]
        t4 = f1["t4"]
        t8 = f1["t8"]
        t16 = f1["t16"]
        t32 = f1["t32"]
        t64 = f1["t64"]
        
        #choosing observable
        t =  vec(t)
        t2 =  vec(t2)
        t4 =  vec(t4)
        t4 =  vec(t4)
        t8 =  vec(t8)
        t16 =  vec(t16)
        t32 =  vec(t32)
        t64 =  vec(t64)
        close(f1)
        if length(allf)>1 
            for i in 2:length(allf)
                f = jldopen(datadir("sims", "zeromodes", allf[i]),"r")
                t = [t; vec(f["t"])]
                t2 = [t2; vec(f["t2"])]
                t4 = [t4; vec(f["t4"])]
                t8 = [t8; vec(f["t8"])]
                t16 = [t16; vec(f["t16"])]
                t32 = [t32; vec(f["t32"])]
                t64 = [t64; vec(f["t64"])]
            end
        end
        
        scatter!([λ[1]], [mean(t)], label = lb[j], ms=8, markershape = ms[j], c = c[j]) 
        scatter!([λ[2]], [mean(t2)], label = "", ms=8, markershape = ms[j], c = c[j])
        scatter!([λ[3]], [mean(t4)], label = "", ms=8,markershape = ms[j], c = c[j]) 
        scatter!([λ[4]], [mean(t8)], label = "", ms=8, markershape = ms[j], c = c[j])
        scatter!([λ[5]], [mean(t16)], label = "", ms=8, markershape = ms[j], c = c[j]) 
        scatter!([λ[6]], [mean(t32)], label = "", ms=8, markershape = ms[j],c = c[j]) 
        scatter!([λ[7]], [mean(t64)], label = "", ms=8, markershape = ms[j], c = c[j])
    end
    plt = @show plt
end



