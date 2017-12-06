clear all;
% Setting some of the parameters required for the script
N=1024;
qam_order=4;
L=300;
fs=16000;
trainMode='y';
random_length=(N/2)-1;
BW_usage=70;
bits_symbol=log2(qam_order);
bits=bits_symbol*random_length;
random_bit_vector=randi([0,1],[bits,1]);
trainblock=qam_mod(random_bit_vector,qam_order);
on_off_vector=ones((N/2)-1,1);
dummy_frames=24;
%run the OFDM function in the trainblock mode
[ofdmStream_trainBlock,P,dummy_elements]=ofdm(trainblock,N,L,on_off_vector,trainMode,dummy_frames);

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
t=0:1/fs:(0.5-(1/fs));
pulse=0.8*sin(2*pi*4e3*t);
pulse=pulse.';
out_aligned=alignIO(sig_rec,pulse);

% Make out_aligned the same length as original OFDM stream else BER will
% flag an error
out_aligned=out_aligned(1:length(ofdmStream_trainBlock));
%out_aligned=fftfilt(wgn(1,512,10), ofdmStream_trainBlock);
[rxOfdmStream,h_freq_estimated]=ofdm_demod(out_aligned,N,L,P,dummy_elements,length(trainblock),ones(N,1),on_off_vector,trainMode,dummy_frames,trainblock);
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
on_off_vector=on_off_generation(h_channel_freq,BW_usage,N);
 

Lt=5;
Ld=3;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% QAM modulation
[qam_stream,bitStream_with_zeros]=qam_mod(bitStream,qam_order);
random_length=(N/2)-1;

bits_symbol=log2(qam_order);
bits=bits_symbol*random_length;
random_bit_vector=randi([0,1],[bits,1]);
trainblock=qam_mod(random_bit_vector,qam_order);
trainMode='n';
%run the OFDM function in the trainblock mode
[ofdmStream,P,dummy_elements]=ofdm(qam_stream,N,L,on_off_vector,trainMode,dummy_frames,trainblock,Lt,Ld);

% Play the sound and record it back
[simin,nbsecs,fs]=initparams(ofdmStream,fs,L);
sim('recplay')
sig_rec=simout.signals.values;

% All of the below needs to go into a new function called alignIO
%find the convolution of the signal recorded by the microphone and the
%pulse created inside the initparams function

% Make sure the definition of the pulse given below corresponds exactly to
% the description inside initparams.m
pulse_duration=0.5; 
t=0:1/fs:(0.5-(1/fs));
pulse=0.1*sin(2*pi*4e3*t);
pulse=pulse.';
out_aligned=alignIO(sig_rec,pulse);

% Make out_aligned the same length as original OFDM stream else BER will
% flag an error
out_aligned=out_aligned(1:length(ofdmStream));
%out_aligned=fftfilt(wgn(1,512,10), ofdmStream_trainBlock);
[rxOfdmStream,h_freq_estimated]=ofdm_demod(out_aligned,N,L,P,dummy_elements,length(trainblock),ones(N,1),on_off_vector,trainMode,dummy_frames,trainblock,Lt,Ld);
rxBitStream = qam_demod(rxOfdmStream,qam_order);
berTransmission = ber(bitStream,rxBitStream);
% plot(20*log10(abs(h_freq_estimated)),'o'); hold on;
% fprintf('\nThe number of samples passed to Simulink model for playing: %d',length(simin(:,1)));
% fprintf('\nNumber of samples received back from recplay module is %d',length(sig_rec));
% % lets see how the channel response was from the channel model estimated
% % previously
% load('h_channel','h');
% h_channel=h;
% h_channel_freq=fft(h_channel,N);
% h_channel_freq_dB=20*log10(abs(h_channel_freq));
% figure;
% plot(h_channel_freq_dB,'g');
% hold on;
% plot(20*log10(abs(h_freq_estimated)),'r');
% legend('Channel response from IR2','Channel response using trainblock');
% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure('name','Sent and received image ')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
fprintf('-------------------------------------------------------------\n');


visualize_demod(h_freq_estimated,rxBitStream,on_off_vector,N,Lt,Ld);

