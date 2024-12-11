clear ; clc ; close all

% Flight conditions
gamma1 = 7/5;
gamma2 = 4/3;

altitudes =  [0, 5000, 10000, 25000, 50000, 80000];
Ms = [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 4, 5];

% Engine design conditions
T_04s = [1200, 1400, 1600, 1800, 2000];
T_07s = [1600, 1800, 2000, 2200, 2400];
pi_cs = [5, 10, 15, 25, 50];
delta_Hb = 43*1e6;

SFC_turbo = zeros(length(T_04s), length(pi_cs), length(altitudes), length(Ms));
SFT_turbo = zeros(length(T_04s), length(pi_cs), length(altitudes), length(Ms));

SFC_ram = zeros(length(T_07s), length(altitudes), length(Ms));
SFT_ram = zeros(length(T_07s), length(altitudes), length(Ms));

for k = 1:length(altitudes)
    for l = 1:length(Ms)

        [R_pure, cp_pure, T, p] = get_conditions(altitudes(k), gamma1);
        [~, cp_burn, ~, ~] = get_conditions(altitudes(k), gamma2);
        M = Ms(l);

        % Turbojet
        for i = 1:length(T_04s)
            for j = 1:length(pi_cs)
            
                % Diffuser
                p_02 = p*(1 + (gamma1-1)/2*M^2)^(gamma1/(gamma1-1));
                T_02 = T*(1 + (gamma1-1)/2*M^2);
                
                % Compressor
                p_03 = pi_cs(j)*p_02;
                T_03 = T_02*( 1 + (pi_cs(j)^((gamma1-1)/gamma1) - 1) );
                
                % Main combustor
                % If the temperature is already higher than T_04, then generate no value, the engine is melting 
                if T_03 < T_04s(i)   
                    p_04 = p_03; % relatively low Mach number => constant stagnation pressure combustion 
                    T_04 = T_04s(i);
            
                    f = (T_04/T_03 - 1) / ( (delta_Hb)/(cp_pure*T_03) - T_04/T_03 );
                
                    % Turbine
                    p_05 = p_04 * (1 - (pi_cs(j)^((gamma1-1)/gamma1) - 1)/((1+f)*cp_burn/cp_pure*T_04/T_02) )^(gamma2/(gamma2-1));
                    T_05 = T_04 * ( 1 - (1 - (p_05/p_04)^((gamma2-1)/gamma2) ));
            
                    % Nozzle (no afterburner)
                    u_9 = sqrt(2*cp_burn*T_05*( 1 - (p/p_05)^((gamma2-1)/gamma2) ));
            
                   SFT_turbo(i, j, k, l) = (1 + f)*u_9 - M*sqrt(gamma1*R_pure*T);
                   SFC_turbo(i, j, k, l) = f / SFT_turbo(i, j) * 3600;
                end
            end
        end
        
        % Ramjet
        for i = 1:length(T_07s)
        
            % Diffuser
            p_02 = p*(1 + (gamma1-1)/2*M^2)^(gamma1/(gamma1-1));
            T_02 = T*(1 + (gamma1-1)/2*M^2);
            
            % Main combustor / afterburner
            if T_02 < T_07s(i)
                p_07 = p_02; % relatively low Mach number => constant stagnation pressure combustion 
                T_07 = T_07s(i);

                f = (T_07/T_02 - 1) / ( (delta_Hb)/(cp_pure*T_02) - T_07/T_02 );
        
                % Nozzle
                u_9 = sqrt(2*cp_burn*T_07*( 1 - (p/p_07)^((gamma2-1)/gamma2) ));
            
               SFT_ram(i, k, l) = (1 + f)*u_9 - M*sqrt(gamma1*R_pure*T);
               SFC_ram(i, k, l) = f / SFT_turbo(i) * 3600;
            end
        end
    end
end
        

save("cycle_analysis_results.mat", "altitudes", "Ms", "T_04s", "T_07s", "pi_cs", "SFT_turbo", "SFC_turbo", "SFT_ram", "SFC_ram")


%% Functions

for i=1:length(T_07s)
    if SFT_ram(i) ~= 0
        h = text(SFT_ram(i, 1, 1)-25, SFC_ram(i, 1, 1)+0.1e-5, sprintf("%i", T_07s(i)), "Interpreter","latex");
        set(h,'Rotation',30);
    end
end


function [R, cp, T, p] = get_conditions(altitude, gamma)
    [T,a,p, ~,~,~] = atmosisa(altitude*0.3048);

    R = a^2 / (gamma*T);
    cp = gamma*R/(gamma-1);
end
