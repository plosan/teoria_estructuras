clear; close all; clc;

%% 1. DATOS
L = 0.245;          % Longitud probeta  [m]
t = 4e-3;           % Espesor probeta   [m]
b = 4e-2;           % Ancho probeta     [m]
Iz = (1/12)*b*t^3;  % Inercia z         [m^4]

K = 2.1;                    % Factor sensibilidad galga [adim]
Rg = 120;                   % Resistencia galga         [Ohm]
Rc = 29880;                 % Resistencia calibraci�n   [Ohm]
ec = (1/K)*Rg/(Rg + Rc);    % Deformaci�n calibraci�n   [adim]

% Carga las siguientes variables:
%   - m     Masas utilizadas        [kg]    1x3
%   - Vs    Voltaje medido          [V]     1x3
%   - Vc    Voltaje de calibraci�n  [V]     1x1
load("data/caso_01.mat");

%% 2. C�LCULOS
P = 9.81*m;                 % Carga                     [N]
sigma = 6*P*L/(b*t^2);      % Tensi�n normal            [Pa]
e = ec*Vs/Vc;               % Deformaci�n calculada     [adim]

%% 3. REGRESI�N LINEAL
p = polyfit(e, sigma, 1);

A = [e' ones(3,1)];         % Matriz sistema sobredeterminado
b = sigma';                 % Vector t�rminos independientes
coef = inv(A'*A)*(A'*b);    % Sistema de ecuaciones normales
a = coef(1);                % Modulo de Young [Pa]
b = coef(2);                % Intercept

f = @(x) a*x + b;   % Recta tensi�n-deformaci�n
sigma_pred = f(e);  % Valores predichos de tensi�n
R2 = (norm(sigma_pred - mean(sigma))/norm(sigma - mean(sigma)))^2;  % Coeficiente determinaci�n

%% 4. IMPRIMIR DATOS

fprintf("%10s = %.4e\n", "Vc", Vc);
fprintf("%10s = %.4e\n", "ec", ec);
fprintf("%10s = %.4f\n", "Vc/ec", 1e3*Vc/ec);
fprintf("%10s = %.2f MPa\n", "E", 1e-6*a);
fprintf("%10s = %.2e MPa\n", "Intercept", 1e-6*b);
fprintf("%10s = %.3e MPa\n", "1-R2", 1-R2);


fprintf("\n\nTabla:\n");
for i = 1:length(m)
    fprintf("$%1d$ %3s $%7.2f$ %3s $%7.3f$ %3s $%5d$ %3s $%8.3e$ \\\\ \n", m(i), "&", P(i), "&", 1e-6*sigma(i), "&", 1e3*Vs(i), "&", e(i));
end

save("data/e1", 'e');

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
xlim([0 1e-3]);
ylim([0 1]);
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
yticks(20:5:70);
grid on;
box on;
set(gcf, 'units', 'centimeters', 'position', [15,5,15,8]);
legend("Regresi\'on lineal", "$(\varepsilon_\ell, \sigma)$", "Location", "northwest");
hold off;
save2pdf(h, "plots/tension_deformacion_01.pdf");


