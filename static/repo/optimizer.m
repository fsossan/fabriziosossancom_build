% Code to optimize the charge discharge of a battery considering a variable
% price of the electricity.

clc;
clear all;
close all;

% price signal
T = 24;
DeltaT = 1;
Enom = 10;
Bmax = 5 * ones(T, 1);
Bmin = -5 * ones(T, 1);
SOC0 = 0.1;
SOCMAX = ones(T, 1)
SOCMIN = 0 * ones(T, 1);

Pmax = 5;


L = 2 * ones(T, 1);
L(17:20) = 3;




SOCMAX(11:12) = 0.9;

SOCMIN(20:23)=0.3;



c = ones(T, 1);
time = 0:DeltaT:T-1;

c(1:7) = 0.05;
c(8:10) = 0.08;
c(11:17) = 0.15;
c(18:21) = 0.35;
c(22:T) = 0.05;


plot(time, c)
ylim([0, max(c)*1.1])
xticks([0:23])
xlim([0, 23])
grid on
xlabel('Time [hours]')
ylabel('Price signal (CHF/kWh)')



f = c;

sigma = tril(ones(T, T));


A0 = sigma * DeltaT / Enom;
b0 = SOCMAX - SOC0;

A1 = -sigma * DeltaT / Enom;
b1 = -(SOCMIN - SOC0);

A2 = eye(T);
b2 = Pmax * ones(T);

A = vertcat(A0, A1);
b = vertcat(b0, b1);


x_lin = linprog(f, A, b, [], [], Bmin, Bmax);
x_qua = quadprog(eye(T)*0.01, f, A, b, [], [], Bmin, Bmax);


x = x_qua;

SOC = SOC0 + sigma * DeltaT / Enom * x;
SOC = vertcat(SOC0, SOC(1:end-1));


close all;


subplot(3, 1, 1)
plot(time, c)
ylim([0, max(c)*1.1])
xticks([0:23])
xlim([0, 23])
title('Price');


subplot(3, 1, 2)
plot(time, x)
xticks([0:23])
xlim([0, 23])
title('Battery power');

subplot(3, 1, 3)
plot(time, SOC)
xticks([0:23])
xlim([0, 23])
title('SOC');


%nop


% Electricity bill

fprintf('Price of electricity: %.1f CHF. \n', f' * x * DeltaT);


% Example where demand is meaningful: peak shaving


close all;

D = ones(T, 1)*3;
D(18:21) = 15;
PMAX = 12;

stairs(time, D)
hold on
stairs(time, time * 0 + PMAX, 'r--')
hold off
xticks([0:23])
xlim([0, 23])
grid on
xlabel('Time [hours]')
ylabel('Active power (kW)')
legend('Power demand', 'Contractual power');

% We have a contractual limitation of 12 kW.

A = vertcat(A0, A1, eye(T));
b = vertcat(b0, b1, PMAX - D);

x = quadprog(eye(T)*0.1, f, A, b, [], [], Bmin, Bmax);


P = D + x;

hold on
stairs(time, P)
legend('Power demand', 'Contractual power', 'Corrected power');
hold on


figure
subplot(3, 1, 1)
plot(time, c)
ylim([0, max(c)*1.1])
xticks([0:23])
xlim([0, 23])
title('Price');


subplot(3, 1, 2)
plot(time, x)
xticks([0:23])
xlim([0, 23])
title('Battery power');

subplot(3, 1, 3)
plot(time, SOC)
xticks([0:23])
xlim([0, 23])
title('SOC');












