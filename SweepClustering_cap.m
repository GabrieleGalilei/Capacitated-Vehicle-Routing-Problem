function [clusters, lengths] = SweepClustering_cap(x, y, capacity, collections, center)
%INPUTS:
%x: vettore che contiene le coordinate x dei punti di ritiro
%y: vettore che contiene le coordinate y dei punti di ritiro
%capacity: scalare per la capacità dei veicoli
%collections: vettore che contiene la domanda per ogni veicolo
%center: coordinate del deposito

%OUTPUTS:
%clusters: matrice di tante righe quanti sono i cluster, ogni riga contiene i nodi di un cluster
%lengths: vettore che riporta le lunghezze di ogni cluster

%%      INIZIALIZZAZIONE
n = length(x);
clusters = zeros(n,n); % matriche che ha per ogni riga i clusters
lengths = zeros(n,1); % vettore che ha per ogni entry i la lunghezza del cluster i
occ_cap = zeros(n,1); % vettore cha ha per ogni entry i la capacità occupata per il veicolo che serve il cluster i

x = x(:);
y = y(:);
center = center(:);

%%      CALCOLO DEGLI ANGOLI IN [-pi,pi]
angles = atan((y(:)-ones(n,1).*center(2))./(x(:)-ones(n,1).*center(1)));

for i = 1:n
    if x(i) < 0 && y(i) < 0
        angles(i) = angles(i) - pi;
    elseif x(i) < 0 && y(i) > 0
        angles(i) = angles(i) +pi;
    end
end

% ordinamento degli angoli (crescente)
[~,ind] = sort(angles);


%%      DIVISIONE IN CLUSTER

i = 1; % contatore dei cluster
j = 1; % contatore dei nodi ordinati per angolo
while i<=n && j<=n
    cont = 0; % contatore del numero di nodi inseriti nel cluster i
    while occ_cap(i) + collections(ind(j)) <= capacity && j<=n
        % controllo sulla capacità
        cont = cont+1;
        clusters(i,cont) = ind(j); % inserimento nel cluster
        occ_cap(i) = occ_cap(i) + collections(ind(j)); % aggiornamento della capacità occupata
        j = j+1;
        if j == n+1
            break;
        end
    end
    lengths(i) = cont; % lunghezza del cluster i
    i=i+1;
end

%%      OUTPUT

clusters = clusters(1:i,1:max(lengths)+1);
for j = 1:i
    clusters(j,lengths(j)+1)=0;
end

lengths = lengths+ones(size(lengths,1),1); % aggiungiamo 1 alla lunghezza per tener conto dell'origine
end