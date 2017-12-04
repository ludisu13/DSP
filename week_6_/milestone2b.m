% Exercise session 4: DMT-OFDM transmission scheme
clear all;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
M=64;
L=512;
N=4096;
fs=16000;
[qamStream,bitStream_with_zeros]=qam_mod(bitStream,M);

% -----------------------Channel Response--------------------------------

%----------loads the channel response from the file--------------------
load('h_channel','h');
h_channel=h;

%----------create BANDPASS custom channel response-----------------------------
% h_channel=fir1(L,[start_frequency_normalised,stop_frequency_normalised],'bandpass');
% h_channel=h_channel.';
%------------------------------------------------------------------------------

%---------or use no channel at all------------------------------------
% h_channel=1;

%-------Find the N-point FFT of the channel response--------------------
h_channel_freq=fft(h_channel,N); %finds the FIR response of the channel
% assume that we will only be using a part of the channel to send the data
% the units of start and stop frequencies are in Hz
start_frequency=100;
stop_frequency=7500;
%-----------------------------------------------------------------------

%---------on-off bit loading vector creation----------------------------
frequency_step=fs/N;
on_off_vector=zeros((N/2)-1,1);
for i=1:(N/2)-1
    if ((i*frequency_step >= (start_frequency)) && (i*frequency_step <= (stop_frequency)))
        on_off_vector(i)=1;
    end
end
%-----------------------------------------------------------------------

f_axis=(0:1:(N/2)-1)*(fs/N);
figure('name','On-off BIT loading');
subplot(2,1,1);
plot(f_axis,20*log10(abs(h_channel_freq(1:N/2))));
ylabel('dB');
xlabel('Frequency(Hz)');
title('Channel Magnitude Response');
subplot(2,1,2)
stem(f_axis,[0;on_off_vector]);
ylabel('Selection of channel')
xlabel('Frequency(Hz');
title('Selection of channel to use [1->used; 0->off]');

fprintf('\n-----WITH Channel Equalization, WITH on-off bit loading, NO SNR------------\n');
% OFDM modulation
[ofdmStream,P,dummy_elements]=ofdm(qamStream,N,L,on_off_vector);
% Adding AWGN to the ofdmStream
ofdmStream_with_noise=awgn(ofdmStream,Inf,'measured'); %the measured parameter ensures that the SNR is applied to the signal after measuring the signal power
ofdmStream_with_noise_and_channel=conv(ofdmStream_with_noise,h_channel);
ofdmStream_with_noise_and_channel=ofdmStream_with_noise_and_channel(1:length(ofdmStream)); %
% OFDM demodulation
rxOfdmStream=ofdm_demod(ofdmStream_with_noise_and_channel,N,L,P,dummy_elements,length(qamStream),h_channel_freq,on_off_vector);
% QAM demodulation
rxBitStream = qam_demod(rxOfdmStream,M);
% Compute BER
berTransmission = ber(bitStream_with_zeros,rxBitStream);
% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure('name','Sent and received image WITH channel equalization, WITH ON-OFF bit loading, NO SNR')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
fprintf('-------------------------------------------------------------\n');



%---------This part of the code demonstrates what happens with ON-OFF BIT loading and some SNR------------------------------------------
%using the same ofdm stream [no change in ON-OFF vector as the channel
%response is the same
fprintf('\n-----WITH Channel Equalization, WITH on-off bit loading, With 20dB of SNR------------\n');
% Adding AWGN to the ofdmStream
ofdmStream_with_noise=awgn(ofdmStream,20,'measured'); %the measured parameter ensures that the SNR is applied to the signal after measuring the signal power
% convoluting the OFDM stream with the channel
ofdmStream_with_noise_and_channel=conv(ofdmStream_with_noise,h_channel);
ofdmStream_with_noise_and_channel=ofdmStream_with_noise_and_channel(1:length(ofdmStream)); % to make sure the new OFDM stream is the sam length as the original OFDM stream
% demodulation of the OFDM stream
rxOfdmStream=ofdm_demod(ofdmStream_with_noise_and_channel,N,L,P,dummy_elements,length(qamStream),h_channel_freq,on_off_vector);
% QAM demodulation of the QAM symbols from the OFDM demodulator
rxBitStream = qam_demod(rxOfdmStream,M);
% Check the BER of the received signal
berTransmission = ber(bitStream_with_zeros,rxBitStream);
% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure('name','Sent and received image WITH channel equalization, WITH ON-OFF bit loading, WITH 20dB SNR')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
fprintf('-------------------------------------------------------------\n');


%---------This part of the code demonstrates what happens NO ON-OFF BIT loading and some SNR------------------------------------------
fprintf('\n-----WITH Channel Equalization, NO on-off bit loading, With 20dB of SNR------------\n');
on_off_vector=ones((N/2)-1,1); %this enables all the frequencies
% OFDM modulation [Need to regenerate this as OB-OFF vector has changed]
[ofdmStream,P,dummy_elements]=ofdm(qamStream,N,L,on_off_vector);
% Adding AWGN to the ofdmStream
ofdmStream_with_noise=awgn(ofdmStream,20,'measured'); %the measured parameter ensures that the SNR is applied to the signal after measuring the signal power
% convoluting the OFDM stream with the channel
ofdmStream_with_noise_and_channel=conv(ofdmStream_with_noise,h_channel);
ofdmStream_with_noise_and_channel=ofdmStream_with_noise_and_channel(1:length(ofdmStream)); % to make sure the new OFDM stream is the sam length as the original OFDM stream
% demodulation of the OFDM stream
rxOfdmStream=ofdm_demod(ofdmStream_with_noise_and_channel,N,L,P,dummy_elements,length(qamStream),h_channel_freq,on_off_vector);
% QAM demodulation of the QAM symbols from the OFDM demodulator
rxBitStream = qam_demod(rxOfdmStream,M);
% Check the BER of the received signal
berTransmission = ber(bitStream_with_zeros,rxBitStream);
% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure('name','Sent and received image WITH channel equalization, NO ON-OFF bit loading, WITH 20dB SNR')
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
fprintf('-------------------------------------------------------------\n');








