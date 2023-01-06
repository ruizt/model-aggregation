function nu_entry = fix_nu(p, pctNz)

if p == 10
    if pctNz == 0.01
        nu_entry = 0.5;
    end
    if pctNz == 0.02
        nu_entry = 0.5;
    end
    if pctNz == 0.05
        nu_entry = 0.1;
    end
    if pctNz == 0.1
        nu_entry = 0.1;
    end
end

if p == 15
    if pctNz == 0.01
        nu_entry = 0.4;
    end
    if pctNz == 0.02
        nu_entry = 0.4;
    end
    if pctNz == 0.05
        nu_entry = 0.1;
    end
    if pctNz == 0.1
        nu_entry = -0.1;
    end
end

if p == 20
            if pctNz == 0.01
                nu_entry = 0.3;
            end
            if pctNz == 0.02
                nu_entry = 0.3;
            end
            if pctNz == 0.05
                nu_entry = 0.1;
            end
            if pctNz == 0.1
                nu_entry = -0.1;
            end
end
        
if p == 30
            if pctNz == 0.01
                nu_entry = 0.3;
            end
            if pctNz == 0.02
                nu_entry = 0.1;
            end
            if pctNz == 0.05
                nu_entry = -0.1;
            end
            if pctNz == 0.1
                nu_entry = -0.3;
            end
end
        
if p == 40
            if pctNz == 0.01
                nu_entry = 0.3;
            end
            if pctNz == 0.02
                nu_entry = 0.1;
            end
            if pctNz == 0.05
                nu_entry = -0.3;
            end
            if pctNz == 0.1
                nu_entry = -0.5;
            end
end
        
if p == 50
            if pctNz == 0.01
                nu_entry = 0.3;
            end
            if pctNz == 0.02
                nu_entry = -0.1;
            end
            if pctNz == 0.05
                nu_entry = -0.3;
            end
            if pctNz == 0.1
                nu_entry = -0.5;
            end
end
        
if p == 60
            if pctNz == 0.01
                nu_entry = 0.1;
            end
            if pctNz == 0.02
                nu_entry = -0.3;
            end
            if pctNz == 0.05
                nu_entry = -0.3;
            end
            if pctNz == 0.1
                nu_entry = -0.5;
            end
end
        