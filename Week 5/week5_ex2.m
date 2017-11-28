clear all;
% Setting some of the parameters required for the script
N=4096;
qam_order=64;
L=512;
fs=16000;

random_length=(N/2)-1;

bits_symbol=log2(qam_order);
bits=bits_symbol*random_length;
random_bit_vector=randi([0,1],[bits,1]);
trainblock=qam_mod(random_bit_vector,qam_order);
on_off_vector=ones((N/2)-1,1);

%run the OFDM function in the trainblock mode
[ofdmStream_trainBlock,P,dummy_elements]=ofdm(trainblock,N,L,on_off_vector,'y');

% Play the sound and record it back
[simin,nbsecs,fs]=initparams(ofdmStream_trainBlock,fs,L);
sim('recplay')
sig_rec=simout.signals.values;

% All of the below needs to go into a new function called alignIO
%find the convolution of the signal recorded by the microphone and the
%pulse created inside the initparams function

% Make sure the definition of the pulse given below corresponds exactly to
% the description inside initparams.m
pulse_duration=0.5; 
samples_pulse=(pulse_duration*fs);
pulse=ones(samples_pulse,1);
pulse(1)=0;
pulse(end)=0;
out_aligned=alignIO(sig_rec,pulse);
trainMode='y';
% Make out_aligned the same length as original OFDM stream else BER will
% flag an error
out_aligned=out_aligned(1:length(ofdmStream_trainBlock));
[rxOfdmStream,h_freq_estimated]=ofdm_demod(out_aligned,N,L,P,dummy_elements,length(trainblock),ones(N,1),on_off_vector,trainMode,trainblock);
rxBitStream = qam_demod(rxOfdmStream,qam_order);
berTransmission = ber(random_bit_vector,rxBitStream);
plot(20*log10(abs(h_freq_estimated)),'o'); hold on;
fprintf('\nThe number of samples passed to Simulink model for playing: %d',length(simin(:,1)));
fprintf('\nNumber of samples received back from recplay module is %d',length(sig_rec));
% lets see how the channel response was from the channel model estimated
% previously
load('h_channel','h');
h_channel=h;
h_channel_freq=fft(h_channel,N);
h_channel_freq_dB=20*log10(abs(h_channel_freq));
figure;
plot(h_channel_freq_dB,'g');
hold on;
plot(20*log10(abs(h_freq_estimated)),'r');
legend('Channel response from IR2','Channel response using trainblock');








