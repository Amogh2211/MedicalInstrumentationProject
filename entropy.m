function varargout = entropy(R, opts, varargin)

% COMPUTING ENTROPIES =====================================================
Ns    = pars.Ns;
btsp  = pars.btsp;
totNt = sum(pars.Nt);

HRS   = zeros(Ns, btsp+1);
HlRS  = zeros(Ns, btsp+1);
HshRS = zeros(Ns, btsp+1);
ChiR  = zeros(1, btsp+1);
HiR   = zeros(1, btsp+1);

if pars.biasCorrNum==1
    [HR(1), HRS(:,1), HlR(1), HlRS(:,1), HiR(1), HiRS(:,1), ChiR(1), HshR(1), HshRS(:,1)] = quadratic_extrapolation_v2(R, pars);
else
    [HR(1), HRS(:,1), HlR(1), HlRS(:,1), HiR(1), HiRS(:,1), ChiR(1), HshR(1), HshRS(:,1)] = pars.methodFunc(R, pars);
end

% Bootstrap
if any(pars.btsp)
    maxNt = max(pars.Nt);
    
    % Linear indexing of the elements of R filled with trials as specified
    % by NT (not considering the first dimension):
    one2maxNt = (1:maxNt).';
    filledTrialsIndxes    = zeros(maxNt, Ns);
    filledTrialsIndxes(:) = 1:maxNt*Ns;
    filledTrialsIndxes    = filledTrialsIndxes(one2maxNt(:, ones(Ns,1))<=pars.Nt(:, ones(maxNt,1)).');
    
    % No bootstrap is computed for HR, HlR, HshR:
    pars.doHR   = false;
    pars.doHlR  = false;
    pars.doHshR = false;
    
    for k=2:btsp+1
        
        % Randperm (inlining for speed):
        [ignore, randIndxes] = sort(rand(totNt,1));

        % Randomly assigning trials to stimuli as defined by NT:
        R(:, filledTrialsIndxes(randIndxes)) = R(:, filledTrialsIndxes);

        if pars.biasCorrNum==1
            [ignore, HRS(:,k), ignore, HlRS(:,k), HiR(:,k), ignore, ChiR(:,k), ignore, HshRS(:,k)] = ...
                quadratic_extrapolation_v2(R, pars);
        else
            [ignore, HRS(:,k), ignore, HlRS(:,k), HiR(:,k), ignore, ChiR(:,k), ignore, HshRS(:,k)] = ...
                pars.methodFunc(R, pars);
        end
    end
end % ---------------------------------------------------------------------




% ASSIGNING OUTPUTS =======================================================
Ps = pars.Nt ./ totNt;
varargout = cell(pars.Noutput,1);

varargout(pars.HR)    = {HR};
varargout(pars.HRS)   = {sum(  HRS .* Ps(:, ones(btsp+1,1)), 1)};
varargout(pars.HlR)   = {HlR};
varargout(pars.HlRS)  = {sum( HlRS .* Ps(:, ones(btsp+1,1)), 1)};
varargout(pars.HiR)   = {HiR};
varargout(pars.HiRS)  = {sum( HiRS .* Ps, 1)};
varargout(pars.ChiR)  = {ChiR};
varargout(pars.HshR)  = {HshR};
varargout(pars.HshRS) = {sum(HshRS .* Ps(:, ones(btsp+1,1)), 1)};