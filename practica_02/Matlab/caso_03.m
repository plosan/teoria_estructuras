clear; close all; clc;

%% 1. DATOS
L = 0.245;          % Longitud probeta  [m]
t = 4e-3;           % Espesor probeta   [m]
b = 4e-2;           % Ancho probeta     [m]
Iz = (1/12)*b*t^3;  % Inercia z         [m^4]

K = 2.1;                    % Factor sensibilidad galga [adim]
Rg = 120;                   % Resistencia galga         [Ohm]
Rc = 29880;                 % Resistencia calibración   [Ohm]
ec = (1/K)*Rg/(Rg + Rc);    % Deformación calibración   [adim]

% Carga las siguientes variables:
%   - m     Masas utilizadas        [kg]    1x3
%   - Vs    Voltaje medido          [V]     1x3
%   - Vc    Voltaje de calibración  [V]     1x1
load("data/caso_03.mat");

%% 2. CÁLCULOS
P = 9.81*m;                 % Carga                     [N]
sigma = 6*P*L/(b*t^2);      % Tensión normal            [Pa]
e = 0.5*ec*Vs/Vc;           % Deformación calculada     [adim]

%% 3. REGRESIÓN LINEAL
p = polyfit(e, sigma, 1);

A = [e' ones(3,1)];         % Matriz sistema sobredeterminado
b = sigma';                 % Vector términos independientes
coef = inv(A'*A)*(A'*b);    % Sistema de ecuaciones normales
a = coef(1);                % Modulo de Young [Pa]
b = coef(2);                % Intercept

f = @(x) a*x + b;   % Recta tensión-deformación
sigma_pred = f(e);  % Valores predichos de tensión
R2 = (norm(sigma_pred - mean(sigma))/norm(sigma - mean(sigma)))^2;  % Coeficiente determinación

%% 4. IMPRIMIR DATOS

fprintf("%10s = %.4e\n", "Vc", Vc);
fprintf("%10s = %.4e\n", "ec", ec);
fprintf("%10s = %.4f\n", "2*Vc/ec", 2e3*Vc/ec);
fprintf("%10s = %.2f MPa\n", "E", 1e-6*a);
fprintf("%10s = %.2e MPa\n", "Intercept", 1e-6*b);
fprintf("%10s = %.3e MPa\n", "1-R2", 1-R2);



for i = 1:length(m)
    fprintf("$%1d$ %3s $%7.2f$ %3s $%7.3f$ %3s $%5d$ %3s $%8.3e$ \\\\ \n", m(i), "&", P(i), "&", 1e-6*sigma(i), "&", 1e3*Vs(i), "&", e(i));
end

%% 5. PLOT
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');


figure(1);
hold on;
title("\textbf{Recta Voltaje -- Deformaci\'on $(\Delta V_s \mbox{-} \varepsilon)$}");
scatter(e, Vs, 30, 'b', 'filled');
plot(e, Vs, 'b');
xlabel("Deformaci\'on $\Delta \varepsilon$");
ylabel("Voltaje $\Delta V_s \ [\mathrm{V}]$");
% xlim([0 1e-3]);
% ylim([0 1]);
grid on;
box on;
set(gcf, 'units', 'centimeters', 'position', [0,5,15,15]);
hold off;


h = figure(2);
hold on;
title("\textbf{Tensi\'on -- Deformaci\'on longitudinal}");
fplot(@(x) 1e-6*f(x), [e(1) e(end)], 'r');
scatter(e, 1e-6*sigma, 20, 'b', 'filled');
xlabel("Deformaci\'on longitudinal $\varepsilon_\ell$");
ylabel("Tensi\'on $\sigma \ [\mathrm{MPa}]$");
xlim([0 1e-3]);
yticks([20:5:70]);
grid on;
box on;
set(gcf, 'units', 'centimeters', 'position', [15,5,15,8]);
legend("Regresi\'on lineal", "$(\varepsilon_\ell, \sigma)$", "Location", "northwest");
hold off;
save2pdf(h, "plots/tension_deformacion_03.pdf");


