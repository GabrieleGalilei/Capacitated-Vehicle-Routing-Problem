function [route, cost] = NNheuristic(x,y)
%INPUTS: 
%x: vettore delle coordinate x dei nodi del cluster
%y: vettore delle coordinate y dei nodi del cluster
%OUTPUTS:
%route: vettore ordinato dei nodi da visitare in sequenza
%cost: scalare che rappresenta il costo totale

%%      INIZIALIZZAIONE
% Il deposito sia in posizione 1 sia nelle x che nelle y
n = length(x);
distances = distanceMatrix(x,y);
w = distances(:,1); % salviamo perchè in seguito verrà modificata
route = zeros(n+1,1); 
route(1) = 1;

%%      RICERCA DEL NEAREST NEIGHBOUR
cost = 0;
for i = 1:n
    distances(i,i) = NaN;
end

for i = 2:n
    % ricerca del nodo più vicino all'ultimo inserito in route
    [add_cost,ind] = min(distances(route(i-1),:),[],'omitnan');
    route(i) = ind;
    % si deve far sì che il nodo inserito non sia più considerato
    distances(route(i-1),:) = NaN(1,n);
    distances(:,route(i-1)) = NaN(n,1); 
    cost = cost + add_cost; % aggiornamento dei costi
end
cost = cost + w(route(n)); % aggiunge ai costi il ritorno all'origine

end