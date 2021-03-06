%ofdm_demod.m
%this script demodulates OFDM serial data
function [recovered_qam_stream,h_channel_freq]=ofdm_demod(ofdm_frames_modulated_serial,N,L,P,dummy_elements,data_size,h_channel_freq,on_off_vector,trainMode,trainrep,trainblock,Lt,Ld)

%N : Number of sub-carriers
%L : The length of the FIR model of the channel
%P : Number of frames of the modulated signal received
%dummy_elements:  is the number of zeros appended at the end of the original QAM
%                 stream to be able to fit the data into a frame
%data_size: Actual number of QAM symbols transmitted. Note that this does
%           not include the number of dummy elements



%first the serial data needs to be converted into parallel frames
rx_frames=zeros(N+L,P);
rx_frames_without_prefix=zeros(N,P);

for i=1:P
    rx_frames(:,i)=ofdm_frames_modulated_serial(((i-1)*(N+L))+1:i*(N+L));
end

if L>0
    %throw away the first L elements of every fam
    for i=1:P
        rx_frames_without_prefix(:,i)=rx_frames(end-N+1:end,i);
    end
end
rx_frames=rx_frames_without_prefix;


% Demodulating the received OFDM frames
ofdm_frames_demodulated=fft(rx_frames);%(fft_matrix*rx_frames);
recovered_qam_stream=zeros(data_size+dummy_elements,1);

% Estimating the channel response using least squares fitting approach
K=(N/2)-1;

%square_sum=
if (trainMode=='y')
    h_estimated=zeros((N/2)-1,1);
    disp('Demodulator in train mode');
    for j=2:K+1
        ofdm_frame_same_frequency=ofdm_frames_demodulated(j,:);
        %I know the expected symbol because the same symbol is transmited in
        %the same fame. It is present in the vector trainblock.
        h_estimated(j-1)=trainblock(j-1)*ones(trainrep,1)\ofdm_frame_same_frequency.';
        %h_estimated(j-1)=trainblock(j-1)*sum(ofdm_frame_same_frequency)/
    end
    h_channel_freq=ones(N,1);
    h_channel_freq(1)=1e-8; %assign some value to the DC component of the channel response.
    h_channel_freq((N/2)+1)=1e-8; %asign some value to the Nyquist component of the channel response
    h_channel_freq(2:N/2)=h_estimated;
    h_channel_freq(N/2+2:N)=flipud(conj(h_estimated));
    
for j=1:P
    ofdm_frames_demodulated(:,j)=ofdm_frames_demodulated(:,j)./(h_channel_freq); %this removes the channel noise
    data_frame=ofdm_frames_demodulated(2:N/2,j);
    %from the data frame, throw away the first L elements and take the next
    %L elements
    actual_data=data_frame;
    recovered_qam_stream((j-1)*K+1:j*K)=actual_data;
end
%throw away the last dummy_elements as the original qam stream was obtained
else
i=1;
size_demod=size(ofdm_frames_demodulated);
h_estimated_b=zeros((N/2)-1,1);
h_channel_freq=[];





while i<=size_demod(2);
    for j= 2:K+1
        ofdm_frame_same_frequency=ofdm_frames_demodulated(j,[i:Lt+i-1]);
        h_estimated_b(j-1)=trainblock(j-1)*ones(Lt,1)\ofdm_frame_same_frequency.';       
    end
    h_estimated_packet=[1e-8;h_estimated_b;1e-8;flipud(conj(h_estimated_b))];
    h_channel_freq=[h_channel_freq h_estimated_packet];
    i=i+Lt+Ld;
end
channel_estimation_index=1;
data_recovered=[];

for j=1:P
    ofdm_frames_demodulated(:,j)=ofdm_frames_demodulated(:,j)./(h_channel_freq(:,channel_estimation_index));
    if(rem(j,Lt+Ld)==0)
       channel_estimation_index=channel_estimation_index+1; 
       data_recovered=[data_recovered ofdm_frames_demodulated(2:N/2,j-Ld+1:j)];
    end
end

size_qam_vector=size(data_recovered);
recovered_qam_stream=reshape(data_recovered,size_qam_vector(1)*size_qam_vector(2),1);

end


recovered_qam_stream=recovered_qam_stream(1:end-dummy_elements);


%and now the dirty work of removing all the zeros from the frame
data_index=1;
frequency_index=1;
recovered_qam_stream_buffer=[];
k=0;
while (data_index<=length(recovered_qam_stream))
    if (on_off_vector(frequency_index)==1)
        %not a great way to do it, but I am too left wing to care
        recovered_qam_stream_buffer=[recovered_qam_stream_buffer;recovered_qam_stream(data_index)];
    else
        %disp('I am here')
    end
    data_index=data_index+1;
    frequency_index=frequency_index+1;
    if (frequency_index==N/2)
        frequency_index=1;
    end
end

recovered_qam_stream=recovered_qam_stream_buffer;
end


    
    
    
