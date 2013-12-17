function TI = irnull(T1, TR)
% Return the inversion recovery time to null a given T1 at a given TR
% - assumes 180-90-TE IR-GE sequence
%
% ARGS:
% T1 = T1 relaxation time of tissue in ms
% TR = TR repetition time of pulse sequence in ms
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 08/02/2013 JMT From Haacke Eqn 8.57 p134

TI = T1 .* log(2 ./ (1 + exp(-TR./T1)));
