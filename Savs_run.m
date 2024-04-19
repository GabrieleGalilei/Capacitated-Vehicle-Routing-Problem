clear all
close all
clc
format short

%%      INIZIALIZZAZIONE
n = 100; % numero di nodi
MaxIt = 50; % numero massimo di iterazioni della Tabu Search (TS)
col_min = 1; % domanda minima dei nodi
col_max = 35; % domanda massima dei nodi
capacity = 300; % capacità dei furgoncini
range = 40; % ampiezza dello spazio dei nodi

%%      GENERAZIONE DELLE VARIABILI RANDOMICHE
rng(12)
collections = (col_max-col_min).*rand(n,1)+col_min.*ones(n,1); % vettore delle domande
x = range.*rand(n,1) - (range/3).*ones(n,1); % coordinate dei nodi
y = range.*rand(n,1) - (range/3).*ones(n,1);
x(1) = 0; %  inseriamo come primo nodo l'origine, che funge da deposito
y(1) = 0;

%% CREAZIONE DELLA SOLUZIONE COSTRUTTIVA TRAMITE SAVINGS CRITERION
tic
[routes, lengths, costs, occ_cap] = Savings_boost(x,y,capacity,collections);
timesavs = toc;

%% CREAZIONE DELLA SOLUZIONE ITERATIVA TRAMITE TABU SEARCH
tic
W = distanceMatrix(x,y);
[new_routes, BestCosts, iters] = TabuSearch(x,y,routes,lengths,W,MaxIt);
timetabu = toc;

%%      DATA VISUALIZATION
figure;
subplot(1,2,1);
PlotSolution(x,y,routes);
title('Savings');
subplot(1,2,2);
PlotSolution(x,y,new_routes);
title('Savings + Tabu Search');

figure;
TotCost = sum(BestCosts);
plot([sum(costs) TotCost],'LineWidth',2,'Color','blue');
title('Total Cost')
xlim([0 MaxIt]);
xlabel('Iteration');
ylabel('Best Cost');
grid on;

colors = ["#0072BD";"#D95319";"#EDB120";"#7E2F8E";"#77AC30";"#4DBEEE";...
    "#A2142F";"#0082BD";"#D75319";"#EDB320";"#5E2F8E";"#27AC30";"#3DBEEE";"#A2342F"];
figure;
for i = 1:size(routes,1)
    subplot(fix(size(routes,1)/4)+1, 4, i);
    plot([costs(i) BestCosts(i,:)],'LineWidth',2,'Color',colors(i));
    title('Route n. ',num2str(i))
    xlim([0 MaxIt]);
    xlabel('Iteration');
    ylabel('Best Cost');
    grid on;
end

% Controllo sui costi delle singole route
disp('Costi di Savings e TS - percentuale di diminuzione')
disp([costs BestCosts(:,end) ((ones(length(costs),1)-BestCosts(:,end)./costs).*(100.*ones(length(costs),1)))])

disp ('Livello di capacità %')
for i = 1:size(routes,1)
    disp((occ_cap(i)/capacity)*100)
end

% Controllo sui tempi computazionali
mex1 = ['Algoritmo savings ha impiegato ' num2str(timesavs) ' s'];
disp(mex1)

mex2 = ['Algoritmo savings + TS ha impiegato ' num2str(timesavs+timetabu) ' s'];
disp(mex2)
