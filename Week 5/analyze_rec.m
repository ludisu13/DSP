%analyze_rec.m
dft=1024;
fs=16000;

%define the time array
t=0:1/fs:2-(1/fs); %the sinewave needs to be for 2s
sinewave=sin(2*pi*440*t);
sinewave=sinewave'; 
sig=sinewave;

%pass on the signal to the function initparams for index for adding times
%of silence at the beginning and the end
[simin,nbsecs,fs]=initparams(sig,fs);
sim('recplay')
sig_rec=simout.signals.values;
%plot the spectrogram of the played and recorded sinewaves
figure;
subplot(2,1,1);
[s_original,w,t_spec]=spectrogram(simin(:,1),dft,dft/2,dft,fs);
spectrogram(simin(:,1),dft,dft/2,dft,fs,'yaxis');
subplot(2,1,2);
spectrogram(sig_rec,dft,dft/2,dft,fs,'yaxis');
[s,w,t_spec]=spectrogram(sig_rec,dft,dft/2,dft,fs,'yaxis');

%determine the number of columns in t_spec as it will be required for the
%determination of PSD
[rows,columns]=size(s);
%MATLAB returns the Fourier transform scaled by the number of points used
%in the DFT analysis
s=s/dft;
s_original=s_original/dft;
a=(abs(s));
clims=[min(a(:)) max(a(:))   ];
%imagesc(20*log10(abs(s)),clims);

%PSD for the original signal
psd_original=zeros(rows,1);
for i=1:length(psd_original)
    psd_original(i)=sumsqr(abs(s_original(i,:)));
end
psd_original=2*(psd_original/columns); %converting it into a single sideband power

%PSD for the recorded signal

psd=zeros(rows,1);
for i=1:length(psd)
    psd(i)=sumsqr(abs(s(i,:)));
end
psd=2*(psd/columns);

%plot the PSD of the original and the recorded signals
figure;
subplot(2,1,2);
semilogx(10*log10(psd),'r');
subplot(2,1,1);
semilogx(10*log10(psd_original),'g'); %converting it into a single sideband power
