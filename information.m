function varargout = information(R, opts, varargin)

whereI     = strcmpi(varargin, 'i');
whereIsh   = strcmpi(varargin, 'ish');
whereIX    = strcmpi(varargin, 'ix');
whereIXS   = strcmpi(varargin, 'ixs');
whereIXSsh = strcmpi(varargin, 'ixssh');
whereILIN  = strcmpi(varargin, 'ilin');
whereSYN   = strcmpi(varargin, 'syn');
whereSYNsh = strcmpi(varargin, 'synsh');
whereISS   = strcmpi(varargin, 'iss');
whereIC    = strcmpi(varargin, 'ic');
whereICsh  = strcmpi(varargin, 'icsh');
whereICI   = strcmpi(varargin, 'ici');
whereICD   = strcmpi(varargin, 'icd');
whereICDsh = strcmpi(varargin, 'icdsh');
whereILB1  = strcmpi(varargin, 'ilb1');
whereILB2  = strcmpi(varargin, 'ilb2');
    
doI     = any(whereI);
doIsh   = any(whereIsh);
doIX    = any(whereIX);
doIXS   = any(whereIXS);
doIXSsh = any(whereIXSsh);
doILIN  = any(whereILIN);
doSYN   = any(whereSYN);
doSYNsh = any(whereSYNsh);
doISS   = any(whereISS);
doIC    = any(whereIC);
doICsh  = any(whereICsh);
doICI   = any(whereICI);
doICD   = any(whereICD);
doICDsh = any(whereICDsh);
doILB1 = any(whereILB1);
doILB2 = any(whereILB2);

% Checks ------------------------------------------------------------------
if isempty(varargin)
    msg = 'No output option specified';
    error('information:noOutputOptSpecified', msg);
end

specifiedOutputOptsVec = ...
    [doI doIsh doIX doIXS doIXSsh doILIN doSYN doSYNsh doISS doIC doICsh doICI doICD doICDsh doILB1 doILB2];
NspecifiedOutputOpts = sum(specifiedOutputOptsVec);
lengthVarargin = length(varargin);
if NspecifiedOutputOpts~=lengthVarargin
    msg = 'Unknown selection or repeated option in output list.';
    error('information:unknownOutputOpt', msg);
end

% Restrictions on possible combinantions ----------------------------------
if strcmpi(opts.method, 'dr')
    % Can't apply bias-correction gsb with method dr:
    if strcmpi(opts.bias, 'gsb')
        msg = 'Bias correction ''gsb'' can only be used in conjunction with method ''gs''.';
        error('Information:drMethodAndGsbBias', msg);
    end

    % Can't compute ISS, IC, ICsh, ICI, ICD, ICDsh or ILB2 for
    % bias-correction pt
    if strcmpi(opts.bias, 'pt') && (doISS || soIC || doICsh || doICI || doICD || doICDsh || doILB2)
        msg = 'One or more of the selected output options are not available for bias correction ''pt''.';
        error('information:ptBiasAndNonAvailableOutputOpt', msg);
    end
end

if strcmpi(opts.method, 'gs')
    % Gaussian and QE is not recommended:
    if opts.verbose && strcmpi(opts.bias, 'qe')
        msg = 'Usage of bias correction ''qe'' in conjunction with gaussian method is not recommended.';
        warning('Information:gsMethodAndQeBias', msg);
    end
    
    % Gaussian and PT is not allowed:
    if strcmpi(opts.bias, 'pt')
        msg = 'Bias correction ''pt'' can only be used in conjunction with method ''dr''.';
        error('Information:gsMethodAndPtBias', msg);
    end
    
    % Can't compute ISS, IC, ICsh, ICI, ICD, ICDsh or ILB2 for gaussian
    % case:
    if doISS || soIC || doICsh || doICI || doICD || doICDsh || doILB2
        msg = 'One or more of the selected output options are not available for method ''gs''.';
        error('information:gsMethodAndNonAvailableOutputOpt', msg);
    end
end

% For 1-D responses only I can be computed:
if size(R,1)==1 && (doIsh||doIX||doIXS||doIXSsh||doILIN||doSYN||doSYNsh||doISS||doIC||doICsh||doICI||doICD||doICDsh||doILB1||doILB2)
    msg = 'Only output option ''I'' can be invoked for L=1.';
    error('information:singetlonLAndNonIOutputOpt', msg)
end

allOutputOpts = {'HR' 'HRS' 'HlR' 'HiR' 'HiRS' 'ChiR' 'HshRS'};
positionInOuputOptsList = 0;

% What needs to be computed by ENTTROPY -----------------------------------
% Need to compute H(R)? 
doHR = false;
if doI || doIsh || doIX || doSYN || doSYNsh || doIC || doICsh || doICD || doICDsh || doILB1
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHR = positionInOuputOptsList;
    doHR = true;
end

% Need to compute H(R|S)?
doHRS = false;
if doI || doIsh || doIXS || doIXSsh || doSYN || doSYNsh || doIC || doICsh || doICD || doICDsh
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHRS = positionInOuputOptsList;
    doHRS = true;
end

% Need to compute H_lin(R)?
doHlR = false;
if doIX || doSYN || doILIN || doSYNsh || doISS
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHlR = positionInOuputOptsList;
    doHlR = true;
end

% Need to compute H_ind(R)?
doHiR = false;
if doISS || doIC || doICsh || doICI
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHiR = positionInOuputOptsList;
    doHiR = true;
end

% Need to compute H_ind(R|S)?
doHiRS = false;
if doIsh || doIXS || doILIN || doSYN || doIC || doICD || doILB1 || doILB2
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHiRS = positionInOuputOptsList;
    doHiRS = true;
end

% Need to compute Chi(R)?
doChiR = false;
if doICI || doICD || doICDsh || doILB2
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereChiR = positionInOuputOptsList;
    doChiR = true;
end

% Need to compute H_sh(R|S)?
doHshRS = false;
if doIsh || doIXSsh || doSYNsh || doICsh || doICDsh
    positionInOuputOptsList = positionInOuputOptsList + 1;
    whereHshRS = positionInOuputOptsList;
    doHshRS = true;
end

% Computing information theoretic quantities ------------------------------
outputOptsList = allOutputOpts([doHR doHRS doHlR doHiR doHiRS doChiR doHshRS]);

H = cell(positionInOuputOptsList, 1);
[H{:}] = entropyPanzeri(R, opts, outputOptsList{:});

% Assigning output --------------------------------------------------------
varargout = cell(length(varargin),1);

% I = HR - HRS
if doI
    varargout(whereI) = {H{whereHR} - H{whereHRS}};
end

% Ish = HR - HiRS + HshRS - HRS
if doIsh
    varargout(whereIsh) = {H{whereHR} - H{whereHiRS} + H{whereHshRS} - H{whereHRS}};
end

% IX = HlR - HR
if doIX
    varargout(whereIX) = {H{whereHlR} - H{whereHR}};
end

% IXS = HiRS - HRS
if doIXS
    varargout(whereIXS) = {H{whereHiRS} - H{whereHRS}};
end

% IXSsh = HshRS - HRS
if doIXSsh
    varargout(whereIXSsh) = {H{whereHshRS} - H{whereHRS}};
end

% ILIN = HlR - HiRS
if doILIN
    varargout(whereILIN) = {H{whereHlR} - H{whereHiRS}};
end

% SYN = HR - HRS - HlR + HiRS
if doSYN
    varargout(whereSYN) = {H{whereHR} - H{whereHRS} - H{whereHlR} + H{whereHiRS}};
end

% SYNsh = HR + HshRS - HRS - HlR
if doSYNsh
    varargout(whereSYNsh) = {H{whereHR} + H{whereHshRS} - H{whereHRS} - H{whereHlR}};
end

% ISS = HiR - HlR
if doISS
    varargout(whereISS) = {H{whereHiR} - H{whereHlR}};
end

% IC = HR - HRS + HiRS - HiR
if doIC
    varargout(whereIC) = {H{whereHR} - H{whereHRS} + H{whereHiRS} - H{whereHiR}};
end

% ICsh  = HR + HshRS - HRS - HiR
if doICsh
    varargout(whereICsh) = {H{whereHR} + H{whereHshRS} - H{whereHRS} - H{whereHiR}};
end

% ICI= ChiR - HiR
if doICI
    varargout(whereICI) = {H{whereChiR} - H{whereHiR}};
end

% ICD = HR - HRS - ChiR + HiRS
if doICD
    varargout(whereICD) = {H{whereHR} - H{whereHRS} - H{whereChiR} + H{whereHiRS}};
end

% ICDsh = HR + HshRS - HRS - ChiR
if doICDsh
    varargout(whereICDsh) = {H{whereHR} + H{whereHshRS} - H{whereHRS} - H{whereChiR}};
end

% ILB1 = HR - HiRS
if doILB1
    varargout(whereILB1) = {H{whereHR} - H{whereHiRS}};
end

% ILB2 = ChiR - HiRS
if doILB2
    varargout(whereILB2) = {H{whereChiR} - H{whereHiRS}};
end