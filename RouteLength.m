function L = RouteLength(route, W)
%INPUTS:
%route: vettore di nodi
%W: matrice delle distanze
%OUTPUTS:
%L: costo della route

    sz = length(route);
    route=[route 1]; % aggiungi il ritorno al deposito

    L=0;
    for k=1:sz
        i = route(k);
        j = route(k+1);
        L = L + W(i,j);
    end
end