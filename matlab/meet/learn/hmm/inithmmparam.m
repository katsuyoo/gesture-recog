function [prior, transmat, term, mu, Sigma, mixmat] = inithmmparam(...
    data, nS, nM, covType, stage, rep)
%% INITHMMPARAM initializes HMM parameters
%
% ARGS
% data  - cell arrays of observation sequence. data{i}(:, j) is the jth 
%         observation in ith sequence.
% nS    - number of hidden states S.
% M     - number of mixtures.
% stage - gesture stage: 1 = pre-stroke, 2 = actual gesture nucleus, 3 =
%         post-stroke.
%
% RETURNS
% mu    - d x nS x nM matrix where d is the dimention of the observation.
% Sigma - d x d x nS x nM

% Uniform initialization.
% prior = ones(nS, 1) / nS;
% transmat = ones(nS) / nS;
% term = ones(nS, 1) / nS;
mixmat = ones(nS, nM) / nM;

% kmeans initialization
mu = mixgauss_init(nS * nM,  cell2mat(data), covType);
d = size(mu, 1);
mu = reshape(mu, [d nS nM]);
%Sigma = reshape(Sigma, [d d nS nM]);
Sigma = repmat(eye(d, d), 1, 1, nS, nM);

switch stage
  case 1
    [prior, transmat, term] = makepretrans(nS);
    Sigma = Sigma(:, :, :, 1); % Tied covariance across mixtures
  case 2
    [prior, transmat, term] = makeembedtrans(nS, rep);
  case 3
    [prior, transmat, term] = makeposttrans(nS);
    Sigma = Sigma(:, :, :, 1);
end

end