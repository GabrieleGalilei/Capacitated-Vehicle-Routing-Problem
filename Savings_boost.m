function [routes, lengths, Costs, occ_cap] = Savings_boost(x,y,capacity,collections)
%INPUTS: 
%x: vettore contenente coordinate x dei nodi
%y: vettore contenente coordinate y dei nodi
%capacity: scalare per la capacità di ogni veicolo
%collections: vettore con la domanda dei vari punti di ritiro

%OUTPUTS:
%routes: matrice che salva su ogni riga una route
%lengths: vettore con il numero di nodi per ogni route
%Costs: vettore con il costo di ogni route
%occ_cap: vettore con la capacità occupata su ogni route

%%      INIZIALIZZAZIONE
n = length(x);
routes = zeros(n-1,n);
routes(:,1) = ones(n-1,1);
routes(:,2) = [2:n]'; % inseriamo le route del tipo 1-i-1 con i = 2:n
occ_cap = collections(routes(:,2)); % inseriamo la domanda per i nodi appena inseriti
lengths = 2.*ones(n-1,1); % vettore che nell'entry i ha il numero di nodi nella route i
W = distanceMatrix(x,y);

%%      CALCOLO E ORDINAMENTO DEI SAVINGS
savs = NaN(n,n);
for i = 1:n
    for j = 1:n
        savs(i,j) = W(i,1)+W(1,j)-W(i,j); % risparmio dato dall'unione di 
        % due route data dalla connessione di i e j
    end
    savs(i,1:i) = zeros(1,i);
end
savs(1,:) = zeros(1,n);
% alcuni elementi sono stati resi nulli per evitare il ripetimento dovuto
% alla simmetria del problema

[R,C] = ndgrid(1:size(savs,1),1:size(savs,2));

% ordinamento dei savings
[sort_savs,idx] = sort(savs(:),'descend');

R = R(idx);
C = C(idx);

sort_savs = sort_savs(1:find(sort_savs(:)==0)-1);
R = R(1:length(sort_savs));
C = C(1:length(sort_savs));

% [R, C] è una lista di coppie di indici che dà la classifica dei nodi da
% mergiare per ottenere savings maggiore

%%      MERGING DELLE ROUTE IN ORDINE DI SAVINGS DECRESCENTE
% quelli che seguono sono semplici passaggi di taglia e cuci di route:
% - scorriamo la classifica dei savings e abbiamo la coppia (i,j)
% - cerchiamo due route che abbiano come capo o coda i nodi i o j
% - se non le troviamo andiamo avanti nella classifica, altrimenti le mergiamo
% - ci si ferma quando si finisce di scorrere la classifica
k = 1;
while k <= length(sort_savs)
    first = [];
    head1 = true; % flag che ci dice se la route va attaccata dalla head o dalla tail;
    head2 = true;
    j = 1;
    while isempty(first) && j<size(routes,1)
        if routes(j,2) == R(k)
            first = j;
        end
        j = j+1;
    end

    % se non ci sono route che iniziano così cerchiamo alla fine
    if isempty(first)
        found = 0;
        j = 0;
        while ~found && j<size(routes,1)
            j = j+1;
            if routes(j,lengths(j)) == R(k)
                found = 1;
            end
        end
        first = j;
        head1 = false;
    end

    second = [];
    j = 1;
    while isempty(second) && j<size(routes,1)
        if routes(j,2) == C(k)
            second = j;
        end
        j = j+1;
    end

    % se non ci sono route che iniziano così cerchiamo alla fine
    if isempty(second)
        found = 0;
        j = 0;
        while ~found && j<size(routes,1)
            j = j+1;
            if routes(j,lengths(j)) == C(k)
                found = 1;
            end
        end
        second = j;
        head2 = false;
    end

    if isempty(first) || isempty(second) || first == second
        disp('Salto la coppia di savings perchè non trovo i corrispettivi nodi o sono nella stessa route');
    elseif head1 && head2
        if occ_cap(first) + occ_cap(second) <= capacity
            merge_1 = routes(first,2:lengths(first));
            merge_2 = routes(second,2:lengths(second));
            merge_1 = fliplr(merge_1);
            routes(first,1:(lengths(first)+lengths(second)-1)) = [1 merge_1 merge_2];
            routes(second, :) = zeros(1,n);

            occ_cap(first) = occ_cap(first) + occ_cap(second);
            occ_cap(second) = 0;

            lengths(first) = lengths(first) + lengths(second) - 1; %il deposito è ripetuto due volte
            lengths(second) = 0;
        end
    elseif head1 && ~head2
        if occ_cap(first) + occ_cap(second) <= capacity
            merge_1 = routes(first,2:lengths(first));
            merge_2 = routes(second,1:lengths(second));
            routes(second,1:(lengths(first)+lengths(second)-1)) = [merge_2 merge_1];
            routes(first, :) = zeros(1,n);

            occ_cap(second) = occ_cap(first) + occ_cap(second);
            occ_cap(first) = 0;

            lengths(second) = lengths(first) + lengths(second) - 1; %il deposito è ripetuto due volte
            lengths(first) = 0;
        end
    elseif ~head1 && head2
        if occ_cap(first) + occ_cap(second) <= capacity
            merge_1 = routes(first,1:lengths(first));
            merge_2 = routes(second,2:lengths(second));
            routes(first,1:(lengths(first)+lengths(second)-1)) = [merge_1 merge_2];
            routes(second, :) = zeros(1,n);

            occ_cap(first) = occ_cap(first) + occ_cap(second);
            occ_cap(second) = 0;

            lengths(first) = lengths(first) + lengths(second) - 1; %il deposito è ripetuto due volte
            lengths(second) = 0;
        end
    elseif ~head1 && ~head2
        if occ_cap(first) + occ_cap(second) <= capacity
            merge_1 = routes(first,1:lengths(first));
            merge_2 = routes(second,2:lengths(second));
            merge_2 = fliplr(merge_2);
            routes(first,1:(lengths(first)+lengths(second)-1)) = [merge_1 merge_2];
            routes(second, 1:n) = zeros(1,n);

            occ_cap(first) = occ_cap(first) + occ_cap(second);
            occ_cap(second) = 0;

            lengths(first) = lengths(first) + lengths(second) - 1; %il deposito è ripetuto due volte
            lengths(second) = 0;
        end
    end
    k=k+1;

    routes = routes(find(routes(:,1)~=0),:);
    occ_cap = occ_cap(find(occ_cap~=0));
    lengths = lengths(find(lengths~=0));
end

%%      OUTPUT

routes = routes(:,1:max(lengths)+1);
Costs = zeros(size(routes,1),1);

CostFunction = @(route) RouteLength(route, W);    % Cost Function
for i = 1:length(Costs)
    tmp = routes(i,1:lengths(i));
    Costs(i) = CostFunction(tmp);
end
end