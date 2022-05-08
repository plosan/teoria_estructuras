clear; close all; clc;

%% 1. DATOS
m = [1 2 3];            % Masas utilizadas  [kg]
P = 9.81*m;             % Cargas aplicadas  [N]
load("data/e1.mat");    % Deformaciones ensayo deformación longitudinal 1/4 puente
e1 = e;                 % Deformación longitudinal
load("data/e2.mat");    % Deformaciones ensayo deformación transversal 1/4 puente
e2 = -e;                % Deformación transversal
load("data/e3.mat");    % Deformaciones ensayo deformación longitudinal 1/2 puente
e3 = e;                 % Deformación longitudinal

%% 2. REGRESIÓN 1
A1 = [e1' ones(3,1)];
b1 = e2';

coef = inv(A1'*A1)*(A1'*b1);    % Sistema de ecuaciones normales
a1 = coef(1);                   % Coeficiente de Poisson [Pa]
b1 = coef(2);                   % Intercept

f1 = @(x) a1*x + b1;    % Recta deformación transversal-deformación longitudinal (1)
et_pred1 = f1(e1);      % Valores predichos de deformación transversal (1)
R2_1 = (norm(et_pred1 - mean(e2))/norm(e2 - mean(e2)))^2;    % Coeficiente determinación 1

fprintf("Regresión 1\n");
fprintf("%10s = %.4f\n", "Poisson", a1);
fprintf("%10s = %.4e\n", "Intercept", b1);
fprintf("%10s = %.3e\n", "1-R2", 1-R2_1);

%% 3. REGRESIÓN 2
A2 = [e3' ones(3,1)];
b2 = e2';

coef = inv(A2'*A2)*(A2'*b2);    % Sistema de ecuaciones normales
a2 = coef(1);                   % Coeficiente de Poisson [Pa]
b2 = coef(2);                   % Intercept

f2 = @(x) a2*x + b2;    % Recta deformación transversal-deformación longitudinal
et_pred2 = f2(e3);      % Valores predichos de deformación transversal
R2_2 = (norm(et_pred2 - mean(e2))/norm(e2 - mean(e2)))^2;   % Coeficiente determinación

fprintf("\n\nRegresión 2\n");
fprintf("%10s = %.4f\n", "Poisson", a2);
fprintf("%10s = %.4e\n", "Intercept", b2);
fprintf("%10s = %.3e\n", "1-R2", 1-R2_2);

%% 4. IMPRIMIR DATOS
for i = 1:length(m)
    fprintf("$%1d$ %3s $%7.2f$ %3s $%8.3e$ %3s $%8.3e$ %3s $%8.3e$ \\\\ \n", m(i), "&", P(i), "&", e1(i), "&", -e2(i), "&", e3(i));
end

%% 4. PLOT

h = figure(1);
hold on;
title("\textbf{Def. transversal -- Def. longitudinal}");
fplot(f1, [e1(1) e1(end)], 'b');
scatter(e1, e2, 20, 'b', 'filled');
fplot(f2, [e3(1) e3(end)], 'r');
scatter(e3, e2, 20, 'r', 'filled');
xlabel("Deformaci\'on longitudinal $\varepsilon_t$");
ylabel("Deformaci\'on transversal $-\varepsilon_t$");
% axis equal;
xlim([2e-4 1e-3]);
ylim([0 3e-4]);
grid on;
box on;
legend("Regresi\'on lineal -- Ensayos 1 y 2", "$(\varepsilon_1, -\varepsilon_2)$ -- Ensayos 1 y 2", ...
    "Regresi\'on lineal -- Ensayos 3 y 2", "$(\varepsilon_3, -\varepsilon_2)$ -- Ensayos 3 y 2", ...
    "Location", "southeast");
set(gcf, 'units', 'centimeters', 'position', [0,5,15,9]);
hold off;
save2pdf(h, "plots/poisson.pdf");




% figure(2);
% hold on;
% title("\textbf{Def. transversal -- Def. longitudinal}");
% fplot(f2, [e3(1) e3(end)], 'r');
% scatter(e3, e2, 20, 'b', 'filled');
% xlabel("Deformaci\'on longitudinal $\varepsilon_t$");
% ylabel("Deformaci\'on transversal $\varepsilon_t$");
% axis equal;
% xlim([2e-4 1e-3]);
% ylim([-5e-4 0]);
% grid on;
% box on;
% legend("Regresi\'on lineal", "$(\varepsilon_\ell, \varepsilon_t)$");
% set(gcf, 'units', 'centimeters', 'position', [20,5,15,9]);
% hold off;
