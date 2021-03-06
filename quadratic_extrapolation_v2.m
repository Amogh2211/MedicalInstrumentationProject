function [HR, HRS, HlR, HlRS, HiR, HiRS, ChiR, HshR, HshRS] = quadratic_extrapolation_v2(R, pars)
%Quadratic extrapolation bias correction.

Nt         = pars.Nt;
methodFunc = pars.methodFunc;

% Shuffling response across trials:
Rsh = shuffle_R_across_trials(R, Nt);

% All available trials:
totNt  = sum(Nt);
[HR1, HRS1, HlR1, HlRS1, HiR1, HiRS1, ChiR1,HshR1, HshRS1] =  methodFunc(Rsh, pars);

% Two partitions:

% Since Nt2 would be the same for both partitions we compute it for the
% first partition and use it to partition the second:
[R2, Nt2, totNt2] = partition_R(Rsh, Nt, 2, 1);
pars.Nt = Nt2;
[HR21, HRS21, HlR21, HlRS21, HiR21, HiRS21, ChiR21, HshR21, HshRS21] = methodFunc(R2, pars);

R2 = partition_R(Rsh, Nt, 2, 2, Nt2);
[HR22, HRS22, HlR22, HlRS22, HiR22, HiRS22, ChiR22, HshR22, HshRS22] = methodFunc(R2, pars);

% Four partitions:
[R4, Nt4, totNt4] = partition_R(Rsh, Nt, 4, 1);
pars.Nt = Nt4;
[HR41, HRS41, HlR41, HlRS41, HiR41, HiRS41, ChiR41, HshR41, HshRS41] = methodFunc(R4, pars);

R4 = partition_R(Rsh, Nt, 4, 2, Nt4);
[HR42, HRS42, HlR42, HlRS42, HiR42, HiRS42, ChiR42, HshR42, HshRS42] = methodFunc(R4, pars);

R4 = partition_R(Rsh, Nt, 4, 3, Nt4);
[HR43, HRS43, HlR43, HlRS43, HiR43, HiRS43, ChiR43, HshR43, HshRS43] = methodFunc(R4, pars);

R4 = partition_R(Rsh, Nt, 4, 4, Nt4);
[HR44, HRS44, HlR44, HlRS44, HiR44, HiRS44, ChiR44, HshR44, HshRS44] = methodFunc(R4, pars);


% ASSIGNING OUTPUTS =======================================================
% H(R)
if pars.doHR
    HR2 = (HR21 + HR22) / 2;
    HR4 = (HR41 + HR42 + HR43 + HR44) / 4;

    HR = lagrange_vec([1/totNt4 1/totNt2 1/totNt], [HR4 HR2 HR1]);
else
    HR = 0;
end;


% H(R|S)
if pars.doHRS
    HRS2 = (HRS21 + HRS22) / 2;
    HRS4 = (HRS41 + HRS42 + HRS43 + HRS44) / 4;

    HRS = lagrange_vec([1./Nt4 1./Nt2 1./Nt], [HRS4 HRS2 HRS1]);
else
    HRS = 0;
end;


% H(Rc)
if pars.doHlR
    HlR2 = (HlR21 + HlR22) / 2;
    HlR4 = (HlR41 + HlR42 + HlR43 + HlR44) / 4;

    HlR = lagrange_vec([1/totNt4 1/totNt2 1/totNt], [HlR4 HlR2 HlR1]);
else
    HlR = 0;
end;


% H(Rc|S)
if pars.doHlRS
    HlRS2 = (HlRS21 + HlRS22) / 2;
    HlRS4 = (HlRS41 + HlRS42 + HlRS43 + HlRS44) / 4;

    HlRS = lagrange_vec([1./Nt4 1./Nt2 1./Nt], [HlRS4 HlRS2 HlRS1]);
else
    HlRS = 0;
end;


% H_ind(R)
if pars.doHiR
    HiR2 = (HiR21 + HiR22) / 2;
    HiR4 = (HiR41 + HiR42 + HiR43 + HiR44) / 4;

    HiR = lagrange_vec([1/totNt4 1/totNt2 1/totNt], [HiR4 HiR2 HiR1]);
else
    HiR = 0;
end;


% H_ind(R|S)
if pars.doHiRS
    HiRS2 = (HiRS21 + HiRS22) / 2;
    HiRS4 = (HiRS41 + HiRS42 + HiRS43 + HiRS44) / 4;

    HiRS = lagrange_vec([1./Nt4 1./Nt2 1./Nt], [HiRS4 HiRS2 HiRS1]);
else
    HiRS = 0;
end;


% Chi(R)
if pars.doChiR
    ChiR2 = (ChiR21 + ChiR22) / 2;
    ChiR4 = (ChiR41 + ChiR42 + ChiR43 + ChiR44) / 4;

    ChiR = lagrange_vec([1/totNt4 1/totNt2 1/totNt], [ChiR4 ChiR2 ChiR1]);
else
    ChiR = 0;
end;


% H_sh(R)
if pars.doHshR
    HshR2 = (HshR21 + HshR22) / 2;
    HshR4 = (HshR41 + HshR42 + HshR43 + HshR44) / 4;

    HshR = lagrange_vec([1/totNt4 1/totNt2 1/totNt], [HshR4 HshR2 HshR1]);
else
    HshR = 0;
end;


% H_sh(R|S)
if pars.doHshRS
    HshRS2 = (HshRS21 + HshRS22) / 2;
    HshRS4 = (HshRS41 + HshRS42 + HshRS43 + HshRS44) / 4;

    HshRS = lagrange_vec([1./Nt4 1./Nt2 1./Nt], [HshRS4 HshRS2 HshRS1]);
else
    HshRS = 0;
end;



function PX = lagrange_vec(X, Y)
% LAGRANGE_VEC vectorized version of LAGRANGE3.

PX = X(:,2) .* X(:,3) ./ ((X(:,1) - X(:,2)).*(X(:,1) - X(:,3))).*Y(:,1) + ...
     X(:,1) .* X(:,3) ./ ((X(:,2) - X(:,1)).*(X(:,2) - X(:,3))).*Y(:,2) + ...
     X(:,1) .* X(:,2) ./ ((X(:,3) - X(:,1)).*(X(:,3) - X(:,2))).*Y(:,3);