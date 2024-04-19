function ActionList = CreatePermActionList(n)
%INPUTS:
%n: numero di nodi della route
%OUTPUTS
%ActionList: lista di azioni possibili

    nSwap = n*(n-1)/2; % combinazioni
    nReversion = n*(n-1)/2; % combinazioni
    nInsertion = n^2; % permutazioni
    nAction = nSwap+nReversion+nInsertion; % numero massimo possibile di azioni
    
    ActionList = cell(nAction,1); % creiamo un cell array di nAction matrici
    c=0;
    
    % SWAP: scambia due nodi i e j di una route
    for i=1:n-1
        for j=i+1:n
            c=c+1;
            ActionList{c}=[1 i j];
            %il primo elemento dell'array è il codice dell'operazione mentre secondo e terzo i nodi al quale si applica
        end
    end

    % REVERSION: prende la sequenza di nodi tra i e j e la inverte
    for i=1:n-1
        for j=i+1:n
            if abs(i-j)>2
                c=c+1;
                ActionList{c}=[2 i j];
            end
        end
    end
    
    % INSERTION: inserisce il nodo i successivamente al nodo j o viceversa
    for i=1:n
        for j=1:n
            if abs(i-j)>1
                c=c+1;
                ActionList{c}=[3 i j];
            end
        end
    end
    
    ActionList=ActionList(1:c);
    % c conta quante azioni sono state effettuate sul totale

end
