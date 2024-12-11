clear ; clc ; close all

fp = "cycle_analysis_results.mat";

% altitudes =  [0, 5000, 10000, 25000, 50000, 80000];
% alt_idx       1    2     3      4      5      6

% Ms = [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 4, 5];
% M_idx 1    2    3    4    5   6   7  8, 9

compare_graphs(fp, 3, 7, 5, 9)


function compare_graphs(results_fp, alt_idx1, M_idx1, alt_idx2, M_idx2)
    % Uses the function plot_turbo_ram() twice on two side-by-side plots,
    % with the same axes
    
    f = figure;
    
    subplot(1, 2, 1)
    hold on
    plot_turbo_ram(results_fp, alt_idx1, M_idx1);
    ax = gca;
    x_limits1 = ax.XLim;
    y_limits1 = ax.YLim;
    
    subplot(1, 2, 2)
    hold on
    plot_turbo_ram(results_fp, alt_idx2, M_idx2);
    ax = gca;
    x_limits2 = ax.XLim;
    y_limits2 = ax.YLim;
    
    % Set common limits on the two subplots
    x_limits = [min(x_limits1(1), x_limits2(1))-100, max(x_limits1(2), x_limits2(2))+100];
    y_limits = [min(y_limits1(1), y_limits2(1))-0.02, max(y_limits1(2), y_limits2(2))+0.02];
    
    xlim(x_limits)
    ylim(y_limits)
    
    subplot(1, 2, 1)
    xlim(x_limits)
    ylim(y_limits)
end


function plot_turbo_ram(filepath, alt_idx, M_idx)
    % With the results stored at the given filepath, plots the SFC/SFT maps
    % of both a turbojet and ramjet, at the altitude given by alt_idx, and 
    % the Mach number given by M_idx

    load(filepath, "altitudes", "Ms", "T_04s", "T_07s", "pi_cs", "SFT_turbo", "SFC_turbo", "SFT_ram", "SFC_ram")

    plot(SFT_turbo(:, :, alt_idx, M_idx), SFC_turbo(:, :, alt_idx, M_idx), "Color","black", marker="*");
    plot(transpose(SFT_turbo(:, :, alt_idx, M_idx)), transpose(SFC_turbo(:, :, alt_idx, M_idx)), "Color","black");
    
    
    for i=1:length(T_04s)
        if SFT_turbo(i, 1, alt_idx, M_idx) ~= 0
            h = text(SFT_turbo(i, 1, alt_idx, M_idx)-25, SFC_turbo(i, 1, alt_idx, M_idx)+0.1e-5, sprintf("%i", T_04s(i)), "Interpreter","latex");
            set(h,'Rotation',30);
        end
    end
    
    for j=1:length(pi_cs)
        if SFT_turbo(end, j, alt_idx, M_idx) ~= 0
            text(SFT_turbo(end, j, alt_idx, M_idx)+15, SFC_turbo(end, j, alt_idx, M_idx)+0.1e-5, sprintf("%i", pi_cs(j)), "Interpreter","latex");
        end
    end
    
    text(mean(SFT_turbo(end, :, alt_idx, M_idx))+100, mean(SFC_turbo(end, :, alt_idx, M_idx)), "$\pi_c$ (-)", "Interpreter","latex");
    text(mean(SFT_turbo(:, 1, alt_idx, M_idx)), mean(SFC_turbo(:, 1, alt_idx, M_idx))+0.02, "$T_{04} (K)$", "Interpreter","latex");
    
    plot(SFT_ram(:, alt_idx, M_idx), SFC_ram(:, alt_idx, M_idx), "Color","red", marker="*");
    text(mean(SFT_ram(:, alt_idx, M_idx)), mean(SFC_ram(:, alt_idx, M_idx))+0.02, "$T_{07} (K)$", "Interpreter","latex");

    xlabel("Specific thrust $(\frac{N \cdot s}{kg})$", "Interpreter","latex")
    ylabel("Specific fuel consumption $(    \frac{kg}{N \cdot h})$", "Interpreter","latex")
    title(sprintf("SFC vs SFT, M = %.1f, altitude: %ift", Ms(M_idx), altitudes(alt_idx)))
    
    lgd = legend(["Turbojet", "", "", "", "", "", "", "", "", "", "Ramjet"]);
    lgd.Location = "Southeast";
    
    for i=1:length(T_07s)
        if SFT_ram(i, alt_idx, M_idx) ~= 0
            h = text(SFT_ram(i, alt_idx, M_idx)-25, SFC_ram(i, alt_idx, M_idx)+0.1e-5, sprintf("%i", T_07s(i)), "Interpreter","latex");
            set(h,'Rotation',30);
        end
    end
end
