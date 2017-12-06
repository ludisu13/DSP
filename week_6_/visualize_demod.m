function visualize_demod(h_channel_freq,Rx,on_off_vector,N,Lt,Ld)
impulse_response=ifft(h_channel_freq,N);
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
for i=1:length(on_off_vector)
    if(on_off_vector(i)==0)
         h_channel_freq(i+1,:)=1e-8;
         h_channel_freq(N-i,:)=1e-8; % this is mirrored!!!!
    end
end
h_channel_freq=20*log10(abs(h_channel_freq));

refresh_rate=80e-3*(Lt+Ld);
subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
number_of_packets=size(h_channel_freq); %not sure if this is gonna work number of packets changes due to on off maybe try differently
number_of_packets=number_of_packets(2);
pause on;
for i=1:number_of_packets
subplot(2,2,1);
plot(impulse_response(:,i));
subplot(2,2,3);
plot(h_channel_freq(:,i));
subplot(2,2,4);
plot(h_channel_freq(:,i));
pause(refresh_rate);
end
end
