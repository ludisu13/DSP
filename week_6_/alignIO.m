function [out_aligned]=alignIO(out,pulse)
fs=16000;
[r,lag]=xcorr(out,pulse);
[~,index]=max(abs(r));
lagdiff=lag(index);
disp(lagdiff);
% once we know the lag, we can just throw away the first lagdiff number of
% samples
out_clipped=out(lagdiff:end);
pulse_duration=0.5; % Make sure this is the same in the modified initparams.m
samples_pulse=(pulse_duration*fs);
% Total number of samples to be thrown awa
out_aligned=out_clipped(samples_pulse+512-40:end);
end

