function [new_routes, BestCosts, iters] = TabuSearch(x, y, routes, lengths, W, MaxIt)
%INPUTS:
%x: vettore delle coordinate x dei nodi
%y: vettore delle coordinate y dei nodi
%routes: matrice che contiene una route in ogni riga
%lenghts: vettore delle lunghezze di una singola route
%W: matrice delle distanze
%MaxIt: numero di iterazioni massimo della Tabu Search
%OUTPUTS:
%new_routes: matrice che contiene le route aggiornate su ogni riga
%BestCosts: matrice che salva i costi di ogni route ad ogni iterazione
%iters: vettore che salva le iterazioni necessarie a rggiungere il minimo globale per ogni route

% numero di route
m = size(routes,1);

CostFunction = @(route) RouteLength(route, W); % funzione di costo della route

new_routes = zeros(m,max(lengths)+1); % nuova matrice delle route risultanti
BestCosts = zeros(m,MaxIt); % matrice che ha sulla colonna j i costi di ogni route all'iterazione j
iters = zeros(m,1); % segna il numero di iterazioni necessarie a raggiungere il minimo globale per ogni route

for cont = 1:m % effettua scambi intra route quindi possiamo considerare le route singolarmente
    xx = x(routes(cont,2:lengths(cont))); % esclude l'origine dalla route in quanto non vanno effettuate azioni su questa
    yy = y(routes(cont,2:lengths(cont)));
    route = routes(cont,2:lengths(cont));
    model = CreateModel(xx,yy); % Crea un modello TSP
    
    ActionList = CreatePermActionList(model.n); % Action List
    nAction = numel(ActionList); % Number of Actions
    TL = round(nAction/7); % Tabu Length

    %%      INIZIALIZZAZIONE
    empty_individual.Position = [];
    empty_individual.Cost = [];
    
    % Crea una soluzione iniziale
    sol = empty_individual;
    sol.Position = route;
    sol.Cost = CostFunction([1 sol.Position]); % nel calcolo dei costi si riaggiunge l'origine
    
    % Inizializza il minimo fino ad ora trovato
    BestSol = sol;
    BestCost = zeros(MaxIt,1); % vettore che tiene conto del miglior costo trovato ad ogni iterazione per la route
    TC = zeros(nAction,1); % Tabu Counter per ogni route: timer che per
    % ogni azione ti dicono se si può utilizzare (TC(i)==0) o 
    % bisogna aspettare (TC(i)!=0)
    
    %%      ITERAZIONI DI TABU SEARCH
    
    for it = 1:MaxIt
        
        bestnewsol.Cost = inf;
        
        for i = 1:nAction
            if TC(i) == 0
                % crea una nuova soluzione usando l'azione i
                newsol.Position = DoAction(sol.Position,ActionList{i});
                newsol.Cost = CostFunction([1 newsol.Position]);
                newsol.ActionIndex = i;
                % se la nuova soluzione è migliore aggiorna la miglior
                % soluzione
                if newsol.Cost <= bestnewsol.Cost
                    bestnewsol = newsol;
                end
            end
        end
        
        sol = bestnewsol;
        
        % Aggiornamento Tabu List: se per migliorare la soluzione è stata
        % usata l'azione i su questa viene messo un timer TL che verrà
        % diminuito di un'unità ogni iterazione e che impedirà di riusare
        % la stessa azione per TL iterazioni
        for i = 1:nAction
            if i == bestnewsol.ActionIndex
                TC(i) = TL;               % Add To Tabu List
            else
                TC(i) = max(TC(i)-1,0);   % Reduce Tabu Counter
            end
        end
        
        if sol.Cost <= BestSol.Cost
            BestSol = sol;
        end
        
        BestCost(it) = BestSol.Cost;
        new_routes(cont,1:lengths(cont)) = [1 BestSol.Position(1:end)];
        % se è stasto raggiunto un minimo globale
        if BestCost(it) == 0
            break;
        end
    end

    %%      OUTPUT DEI RISULTATI
    
    for i = 1:size(routes,1)
        new_routes(i, lengths(i)+1) = 0;
    end
    BestCosts(cont,1:it) = BestCost(1:it);
    iters(cont) = it;
end
end
