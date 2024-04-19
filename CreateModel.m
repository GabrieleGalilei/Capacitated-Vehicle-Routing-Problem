function model=CreateModel(x,y)
    n = length(x);
    d = distanceMatrix(x,y);

    xmin = min(x);
    xmax = max(x);
    
    ymin = min(y);
    ymax = max(y);
    
    model.n=n;
    model.x=x;
    model.y=y;
    model.d=d;
    model.xmin=xmin;
    model.xmax=xmax;
    model.ymin=ymin;
    model.ymax=ymax;
    
end