clear all;
N=4096;
random_length=(N/2)-1;
qam_order=64;
bits_symbol=log2(qam_order);
bits=bits_symbol*random_length;
random_bit_vector=randi([0,1],[bits,1]);
trainblock=qam_mod(random_bit_vector,64);
%load the channel response
load('h_channel','h');
h_channel=h;
h_fft=20*log10(abs(fft(h)));
L=length(h_channel);
% turning off on-off bit loading
on_off_vector=ones((N/2)-1,1);
% [ofdmStream,P,dummy_elements]=ofdm(qamStream,N,L,on_off_vector);
[ofdmStream_trainBlock,P,dummy_elements]=ofdm(trainblock,N,L,on_off_vector,'y');
Rx=conv(ofdmStream_trainBlock,h_channel);
Rx=Rx(1:length(ofdmStream_trainBlock));
trainMode='y';
h_channel_freq=fft(h_channel,N);
h_channel_org_freq=20*log10(abs(h_channel_freq));
% rxOfdmStream=ofdm_demod(ofdmStream_with_noise_and_channel,N,L,P,dummy_elements,length(qamStream),h_channel_freq,on_off_vector);
[rxOfdmStream,h_freq_estimated]=ofdm_demod(Rx,N,L,P,dummy_elements,length(trainblock),ones(N,1),on_off_vector,trainMode,trainblock);
rxBitStream = qam_demod(rxOfdmStream,qam_order);
berTransmission = ber(random_bit_vector,rxBitStream);
figure;
plot(20*log10(abs(h_freq_estimated)),'o'); hold on;
plot(h_channel_org_freq,'g');
legend('Channel response from trainblock','Channel response from IR2');
h_impulse_estimated=abs(ifft(h_freq_estimated,512,'symmetric'));
figure;
plot(h_impulse_estimated,'r'); hold on; plot(h_channel,'g');
figure;
subplot(2,1,1);
stem(real(h_freq_estimated-h_channel_freq));
subplot(2,1,2);
stem(imag(h_freq_estimated-h_channel_freq));















