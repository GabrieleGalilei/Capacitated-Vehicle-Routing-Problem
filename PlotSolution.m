function PlotSolution(x,y,routes)
n = length(x);
m = size(routes,1);

colors = ["#0072BD";"#D95319";"#EDB120";"#7E2F8E";"#77AC30";"#4DBEEE";"#A2142F";"#0082BD";"#D75319";"#EDB320";"#5E2F8E";"#27AC30";"#3DBEEE";"#A2342F"];
%colors = ["red","green","blue","cyan","yellow","magenta","black"]';
hold on
scatter(x,y,30,'MarkerEdgeColor','y','MarkerFaceColor','black')
a = num2str([1:n]');
b = cellstr(a);
hold on
text(x+0.1,y+0.1,b)

for j=1:m  % vai veicolo per veicolo
    k = 0; % indice del nodo da prendere in esame
    while routes(j,k+1) %finchè la route non finisce
        k = k+1; %passa al nodo successivo
        if routes(j,k+1)~=0
            xx = [x(routes(j,k)) x(routes(j,k+1))];
            yy = [y(routes(j,k)) y(routes(j,k+1))];
            hold on
            line(xx,yy,'Color',colors(j),'LineWidth',2)
        end
    end
    % plotta il ritorno al deposito
    xx = [x(routes(j,k)) x(routes(j,1))];
    yy = [y(routes(j,k)) y(routes(j,1))];
    hold on
    line(xx,yy,'Color',colors(j),'LineWidth',2)
end
end
