function [simin,nbsecs,fs]=initparams(toplay,fs,L)
%toplay contains the vector to be played
%fs is the samping rate
silence_beginning=2; %
silence_end=3;
pulse_duration=0.5; %how to decide on the pulse duration???
samples_pulse=(pulse_duration*fs);
pulse=ones(samples_pulse,1);
pulse(1)=0;
pulse(end)=0;
silence_trailing_pulse=zeros(L-1,1); %the reason why L-1 samples are chosen to have a value zero (and not L samples which is the 
% length of the channel's FIR response) is because the pulse's last sample is also a zero! 
nbsecs=silence_beginning+silence_end+(length(toplay)/fs)+pulse_duration+((L-1)/fs);
%scale the value of toplay to be within +/-1
if max(abs(toplay))>1
    toplay=toplay/max(abs(toplay));
end
simin=[zeros(silence_beginning*fs,1);pulse;silence_trailing_pulse;toplay;zeros(silence_end*fs,1)];
simin=[simin,simin];
end