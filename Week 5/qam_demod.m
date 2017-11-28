function [demodulated]=qam_demod(input_sequence,M)
demodulated=qamdemod(input_sequence,M,'gray','OutputType','bit','UnitAveragePower',true);  
end