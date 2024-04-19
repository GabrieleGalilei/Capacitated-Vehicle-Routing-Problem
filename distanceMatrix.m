function W = distanceMatrix(x,y)

n = length(x);
W = zeros(n,n);

for i = 1:n
    for j = i+1:n
        W(i,j) = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
        W(j,i) = W(i,j);
    end
end

end