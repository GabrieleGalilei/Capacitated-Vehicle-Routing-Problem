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

costs = zeros(n,1); % vettore dei costi per ogni route
occ_cap = zeros(n,1); % vettore della capacità occupata per ogni route
routes = zeros(n,n); % matrice che ha sulle righe le route

%%      SWEEP METHOD PER CLUSTERIZZARE
tic
[clusters, lengths] = SweepClustering_cap(x(2:end), y(2:end), capacity, collections(2:end), [x(1); y(1)]);

m = size(clusters,1)-1; % numero di clusters
% segue un passaggio utile a riscalare gli indici dei nodi clusterizzati,
% in quanto non si considera l'origine, che ora va riinclusa
for i = 1:m
    clusters(i,1:lengths(i)) = clusters(i,1:lengths(i)) + ones(1,lengths(i));
end

%%      MYOPIC TSP PER CLUSTER (NN heuristic)

for j = 1:m
    [route, cost] = NNheuristic([0; x(clusters(j,1:lengths(j)))], [0; y(clusters(j,1:lengths(j)))]);
    routes(j,1:(lengths(j)+2)) = route';
    costs(j) = cost;
    k = 2;
    % segue un passaggio che traduce gli indici ordinati del cluster in 
    % indici ordinati dell'intero grafo
    while k <= find(routes(j,2:end)==0)
        routes(j,k) = clusters(j,routes(j,k)-1);
        k = k+1;
    end
end
% tronchiamo le matrici e i vettori per quanto utilizzati
costs = costs(1:m);
routes = routes(1:m,1:max(lengths)+2);
timesweep = toc;
routes(:,2) = [];

%%      TABU SEARCH
W = distanceMatrix(x,y);

tic
% applichiamo la TS alla soluzione trovata tramite sweep + NN heuristic
[new_routes, BestCosts, iters] = TabuSearch(x,y,routes,lengths,W,MaxIt);
timetabu = toc;

%%      DATA VISUALIZATION

figure;
subplot(1,2,1);
PlotSolution(x,y,routes);
title('Sweep + NN heuristic');
subplot(1,2,2);
PlotSolution(x,y,new_routes);
title('Sweep + NN heuristic + Tabu Search');

figure;
TotCost = zeros(MaxIt,1);
for i = 1:MaxIt
    TotCost(i) = sum(BestCosts(:,i));
end

plot([sum(costs) TotCost'],'LineWidth',2,'Color','blue');
title('Total Cost - Sweep + NN + TS')
xlabel('Iteration');
ylabel('Best Cost');
xlim([0 MaxIt]);
grid on;

colors = ["#0072BD";"#D95319";"#EDB120";"#7E2F8E";"#77AC30";"#4DBEEE";...
    "#A2142F";"#0082BD";"#D75319";"#EDB320";"#5E2F8E";"#27AC30";"#3DBEEE";"#A2342F"];

figure;
for i = 1:size(routes,1)
    subplot(fix(size(routes,1)/4)+1, 4, i);
    plot([costs(i) BestCosts(i,1:iters(i))],'LineWidth',2,'Color',colors(i));
    title('Route n. ',num2str(i))
    xlabel('Iteration');
    xlim([0 MaxIt]);
    ylabel('Best Cost');
    grid on;
end

% Controllo sui costi delle singole route
disp('Costi di Sweep e TS - percentuale di diminuzione')
disp([costs BestCosts(:,end) ((ones(length(costs),1)-BestCosts(:,end)./costs).*(100.*ones(length(costs),1)))])

% Controllo sulle capacità occupata per route
for cont = 1:m
    for j = 2: lengths(cont)
    occ_cap(cont) = occ_cap(cont) + collections(routes(cont,j));
    end
end

disp ('Livello di capacità %')
for i = 1:size(routes,1)
    disp((occ_cap(i)/capacity)*100)
end

% Controllo sui tempi computazionali
mex1 = ['Algoritmo sweep + NN ha impiegato ' num2str(timesweep) ' s'];
disp(mex1)

mex2 = ['Algoritmo sweep + NN + TS ha impiegato ' num2str(timesweep+timetabu) ' s'];
disp(mex2)
