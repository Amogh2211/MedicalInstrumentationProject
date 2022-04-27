function [R, nt] = buildr(S, varargin)

if ~isvector(S)
    error('Stimulus array must be a 1-D array');
end

totNt = length(S);

L = length(varargin);

R1toL = zeros(L, totNt);
for k=1:L
    if ~isvector(varargin{k})
        msg = 'Response arrays must be 1-D.';
        error('buildr:respNot1D', msg);
    end
    
    if length(varargin{k}) ~= totNt
        msg = 'Each response-array must have the same length as the stimulus array';
        error('buildr:differentTotNt', msg);
    end
    
    R1toL(k,:) = varargin{k};
end

uniqueS = unique(S);
Ns = length(uniqueS);

% Dispalying informations:
disp('Building R and nt:');
disp(['- number of stimuli = ' num2str(Ns)]);
disp(['- number of responses = ' num2str(L)]);


nt = zeros(Ns,1);
tFlag = false(totNt, Ns);
for s=1:Ns
    tFlag(:,s) = S==uniqueS(s);
	nt(s) = sum(tFlag(:,s));
end

maxNt = max(nt);
disp(['- maximum numer of trials = ' num2str(maxNt)]);
disp(['- minimum numer of trials = ' num2str(min(nt))]);
R = zeros(L, maxNt, Ns);
for s=1:Ns
    if nt(s)>0
        R(:,1:nt(s), s) = R1toL(:, tFlag(:,s));
    else
        msg = 'One or more stimuli with no corresponding response.';
        error('buildr:noResponseStimulus', msg);
    end
end