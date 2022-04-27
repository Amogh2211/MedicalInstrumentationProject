function edges = eqpop(X, nb, varargin)
uniqueX = unique(X(:));

N = length(uniqueX);
if N<nb
    error('Too many bins for the selected data.');
end

ValsxBin = floor(N/nb); % Rounded number of values-per-bin
r = N - (ValsxBin*nb);  % Remainder

indx = 1:ValsxBin:ValsxBin*nb;
indx(1:r) = indx(1:r) + (0:(r-1));
indx(r+1:end) = indx(r+1:end) + r;

edges = zeros(nb+1,1);
edges(1:nb) = uniqueX(indx);
edges(nb+1) = uniqueX(end) + 1;