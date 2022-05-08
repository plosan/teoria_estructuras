clear; close all; clc;

%% 1. DATOS
L = 0.245;
t = 4e-3;
b = 4e-2;
Iz = (1/12)*b*t^3;


Vc = 1819e-3;   
m = [1 2 3];    
P = 9.81*m;
Vs = [280 560 840]*1e-3;
sigma = 6*P*L/(b*t^2);

K = 2.1;        % Coeficiente galga         [adim]
Rg = 120;       % Resistencia galga         [Ohm]
Rc = 29880;     % Resistencia calibraci√≥n   [Ohm]
ec = (1/K)*Rg/(Rg + Rc);

fprintf("%10s = %.5e\n", "Vc", Vc);
fprintf("%10s = %.5e\n", "epsilon_c", ec);


e = ec*Vs/Vc;

%% 2. REGRESI”N LINEAL
p = polyfit(e, sigma, 1);

A = [e' ones(3,1)];
b = sigma';

coef = inv(A'*A)*(A'*b);
a = coef(1);
b = coef(2);


f = @(x) a*x + b;
sigma_pred = f(e);

R2 = (norm(sigma_pred - mean(sigma))/norm(sigma - mean(sigma)))^2;


set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

E = 1e-9*(sigma(end) - sigma(1))/(e(end) - e(1));
fprintf("%10s = %.5f GPa\n", "E", E);

figure(1);
hold on;
title("\textbf{Recta Voltaje -- Deformaci\'on $(\Delta V_s \mbox{-} \varepsilon)$}");
scatter(e, Vs, 30, 'b', 'filled');
plot(e, Vs, 'b');
xlabel("Deformaci\'on $\Delta \varepsilon$");
ylabel("Voltaje $\Delta V_s \ [\mathrm{V}]$");
xlim([0 1e-3]);
ylim([0 1]);
grid on;
box on;
set(gcf, 'units', 'centimeters', 'position', [0,5,15,15]);
hold off;


figure(2);
hold on;
scatter(e, 1e-6*sigma, 30, 'b', 'filled');
plot(e, 1e-6*polyval(p, e), '--r');
fplot(@(x) 1e-6*f(x), [e(1) e(end)], '--m');
xlabel("Deformaci\'on $\Delta \varepsilon$");
ylabel("Tensi\'on $\sigma \ [\mathrm{MPa}]$");
xlim([0 1e-3]);
grid on;
box on;
set(gcf, 'units', 'centimeters', 'position', [15,5,15,15]);
hold off;



