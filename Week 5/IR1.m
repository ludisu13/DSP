clear all;
%sampling rate fs= 16000
fs=16000;
time=2;
%sound the pop at 1s
%t=0:1/fs:2-(1/fs);
sound_wave=zeros(2*fs,1);
sound_wave(1)=1;
%sound_wave=sin(2*pi*440*t);
%sound_wave=sound_wave';

[simin,nbsecs,fs]=initparams(sound_wave,fs);
sim('recplay')
sig_rec=simout.signals.values;
%find the index of the maximum and minimul element
max_cordinate=find(sig_rec==max(sig_rec));
min_cordinate=find(sig_rec==min(sig_rec));
%set the number of samples we would need for impulse response
ir_samples=512;
sig_rec=sig_rec(min(min_cordinate,max_cordinate)-60:min(min_cordinate,max_cordinate)+ir_samples-61);
impulse_input=simin(fs:fs+ir_samples-1,1);
figure('name','Channel response using impulse');
subplot(2,1,1);
plot(sig_rec);
xlabel('Samples(n)');
ylabel('h[n]');
sig_rec_fft=fft(sig_rec,ir_samples);
f_axis=(0:(ir_samples/2))*fs;
f_axis=f_axis/ir_samples;
sig_rec_fft_abs=abs(sig_rec_fft)/ir_samples;
sig_rec_fft_sb=sig_rec_fft_abs(1:((ir_samples/2))+1);
sig_rec_fft_sb(2:end-1)=2*sig_rec_fft_sb(2:end-1);
subplot(2,1,2);
plot(f_axis,20*log10(sig_rec_fft_sb));
xlabel('Frequency(in Hz)');
ylabel('Magnitude(dB)');


