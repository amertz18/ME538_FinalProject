clc
clear all 
close all

%% Constants and Atmospheric Properties
gamma = 1.4;             % Specific heat ratio
cp = 1004;               % Specific heat of air [J/(kg*K)]
R = 287;                 % Gas constant [J/(kg*K)]
H_b = 19600 * 2326;      % Jet A LHV in J/kg
Mach_number=0;

% ATM
 % Get ambient conditions
altitude=0; %55000 feet in meters 16764

    [T_a, P_a] = atmosphere(altitude); % Temperature [K] and pressure [Pa]
    V_in = Mach_number * sqrt(gamma * R * T_a); % Freestream velocity [m/s]
    T0_in = T_a * (1 + 0.2 * Mach_number^2);    % Stagnation temperature [K]
    P0_in = P_a * (1 + 0.2 * Mach_number^2)^(gamma / (gamma - 1)); % Stagnation pressure

%To2 would be from The diffuser/Inlet analysis but assume To_in=T02 for now
T02=T0_in
P02=P0_in

%Define Variables
g=1.4;
R=287;




%Design Choices 
T04=2000; %k   %Fixed max allowable temp
StLd=.5; %assumed stage loading is 50% ideally delta H/n*U^2
etac=.85; %assumed compressure efficiency from literature


Pi_C= [15 20 25 30 35 50] %Compare stage number vs compress ratio varying
Pi_F= [1.2 1.4 2 3]
U=350; %m/s
cp=1000;
Tauc=1.2; %T03/T02;  %Required To3 for combustor inlet or P03/P02 ratio
%to3/to2 ratio is known from atm conditions and pic



for j=1:length(Pi_F)
 % Fan exit temperature
 T_f3(j)=T02 * Pi_F(j).^((gamma-1)/gamma);
 %T_f3(j)=T_f3(j).* Pi_F(j).^((gamma-1)/gamma);  %2nd fan stage optional



for i=1:length(Pi_C)

n(i,j)=N_CompStages(T04,Pi_C(i),U,Tauc,StLd,gamma,T_f3(j),etac,cp);

% Fan exit temperature
 % T_f3=T02 * Pi_Fan^((gamma-1)/gamma);

 % Compressor exit temperature
  T_t3(i,j) = T02 * Pi_C(i)^((gamma - 1) / gamma);

end

end

figure(1)

hold on;
for s=1:length(Pi_F)
plot(n(:,s), Pi_C, '--o', 'DisplayName', ['Pi_F = ', num2str(Pi_F(s)), ]);

end

xlabel('Number of stages');
ylabel('Compressor Pressure Ratio');
title('Pressure ratio vs Number of stages M0=0 U=350 m/s Stage Loading = .5');
legend;
grid on;
hold off;


%% Vary Stage loading Keep Fan pressure constant

T_f3=T02 * Pi_F(3).^((gamma-1)/gamma);
StLd=[.3 .4 .5 .6]



for j=1:length(StLd)

for i=1:length(Pi_C)
n1(i,j)=N_CompStages(T04,Pi_C(i),U,Tauc,StLd(j),gamma,T02,etac,cp);
n(i,j)=N_CompStages(T04,Pi_C(i),U,Tauc,StLd(j),gamma,T_f3,etac,cp);

% Fan exit temperature
 % T_f3=T02 * Pi_Fan^((gamma-1)/gamma);

 % Compressor exit temperature
  T_t3(i,j) = T02 * Pi_C(i)^((gamma - 1) / gamma);

end

end




figure(2)

hold on;
for s=1:length(Pi_F)
plot(n(:,s), Pi_C, '--o', 'DisplayName', ['StLd = ', num2str(StLd(s)),'Pi_F = ', num2str(Pi_F(3)), ]);
%plot(n1(:,s), Pi_C, '--o', 'DisplayName', ['StLd = ', num2str(StLd(s)), 'T02=T03in' ]);

end

xlabel('Number of stages');
ylabel('Compressor Pressure Ratio');
title('Pressure ratio vs Number of stages M0=0 U=350 m/s');
legend;
grid on;
hold off;





































function [n]=N_CompStages(T04, Pi_C, U, Tauc,StLd,gamma,T02, etac, cp )

n=(cp*((Pi_C)^((gamma-1)/gamma)-1))/(etac*(StLd)*(U/sqrt(T02))^2)

end

%Vary the mean loading ratio and the pressure ratio. Graph in a way so that
%pressure ratio is always 15-50 and acceptable to our ideal analysis. 

% We affix To4 at 200k and we U we vary from 340-380m/s 

%We will input a Po2


%% ATM Properties at altitude (meters) 
function [T, P] = atmosphere(h)
    % ISA model for atmospheric temperature and pressure
    if h < 11000
        T = 288.15 - 6.5e-3 * h; % Troposphere temperature lapse rate
        P = 101325 * (T / 288.15)^(-5.256);
    else
        T = 216.65; % Temperature constant above 11 km
        P = 101325 * 0.223 * exp(-0.000157 * (h - 11000));
    end
end