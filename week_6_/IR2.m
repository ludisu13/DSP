clear all;

seconds_noise=2; %this is the number of seconds of noise using which the system is being characterised
fs=16000;
%sampling rate fs= 16000
noise_signal=wgn(seconds_noise*fs,1,-13); 
[simin,nbsecs,fs]=initparams(noise_signal,fs);
sim('recplay')
sig_rec=simout.signals.values;
%the following piece of code tries to find the start of the signal
max_cordinate=find(sig_rec>=0.1*max(abs(sig_rec)));
start_of_noise=max_cordinate(1)-60; %adding of margin to prevent the response from becoming anti causal;
end_of_noise=start_of_noise+31000-1;  %taking 31000 of the noise samples to estimate the response
sig_rec_clipped=(sig_rec(start_of_noise:end_of_noise));  
%%%%%estimating h_matrix
input_k=noise_signal(1:length(sig_rec_clipped)); 
out_k=sig_rec_clipped;
L=length(out_k);
ir_samples=512; %from the previous exercise we estimated that the impulse response is ~300 long. But taking 512 samples for margin
zeros_L=zeros(1,ir_samples); 
xinp_toeplitz=toeplitz(input_k',zeros_L);  %the input is the row vector input. The conjugate operator changes it from row vector to column vector. 
%xinp_toeplitz*h=out_k;
h=xinp_toeplitz\out_k;
output_test=xinp_toeplitz*h;
fprintf('The sum square error is: %d\n',sumsqr(output_test-out_k));
figure('name','Channel characterization using white gaussian noise');
title('Channel response estimation using white noise');
subplot(2,1,1)
plot(h); %plot the impulse response in time domain
xlabel('Samples');
ylabel('h[n]');
subplot(2,1,2)
h_fft=fft(h,ir_samples);
f_axis=(0:(ir_samples/2))*fs;
f_axis=f_axis/ir_samples;
h_fft_abs=abs(h_fft)/ir_samples;
h_fft_sb=h_fft_abs(1:((ir_samples/2))+1);
h_fft_sb(2:end-1)=2*h_fft_sb(2:end-1);
subplot(2,1,2);
plot(f_axis,20*log10(h_fft_sb));
