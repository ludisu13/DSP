function [on_off_vector] = on_off_generation(h_channel_freq,BW_usage,N)
h_channel_freq=h_channel_freq(2:N/2);
[values indices]=sort(abs(h_channel_freq));
start_index=floor(((100-BW_usage)/100)*(N/2-1));
indices=indices(start_index:end);
indices=sort(indices);
on_off_vector=zeros(N/2-1,1);
index_counter=1;
for i=1:(N/2-1)
    if(i==indices(index_counter))
        on_off_vector(i)=1;
        index_counter=index_counter+1;
        if(index_counter>length(indices))
            break;
        end
    else
        on_off_vector(i)=0;
    end
    
end
end