function bias = gaussian_bias(Nt,L)

Nt = Nt-1;

NtMat = Nt(:, ones(L,1));

pvec = 0:L-1;

NtMat = NtMat - pvec(ones(length(Nt),1), :);

bias = sum(psi(NtMat./2), 2) - L.*log(Nt(:,1)./2);
bias = bias ./ (2*log(2));