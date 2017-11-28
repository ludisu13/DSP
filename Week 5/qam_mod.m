function [modulated,input_sequence]=qam_mod(input_sequence,M)
length=size(input_sequence);
length=length(1);
if(rem(length,log2(M))==0)
    number_of_symbols=length/log2(M);
else
    number_of_symbols=floor(length/log2(M))+1;
end 
zeros_required=log2(M)*number_of_symbols-length;
input_sequence=[input_sequence;zeros(zeros_required,1)];
modulated=qammod(input_sequence,M,'gray','InputType','bit','UnitAveragePower',true);  
end