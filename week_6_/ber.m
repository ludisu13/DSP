function [ber,n_error]=ber(tx,rx)
ber=0;
length=size(tx);
bits=length(1);
thresh=1e-7;
for i=1:bits
    %making sure to account for the numerical inaccuracies of MATLAB's
    %arithmetic operations. Any difference in values beyond a 'thresh' is
    %flagged as a bit error
    if (tx(i) ~= rx(i))
        ber = ber + 1;
    end
end
n_error=ber;
if ber>0
    fprintf('ERROR!!! Error in bits detected!\n');
    ber = ber/bits*100;
    fprintf('BER = %f\n',ber);

else
    fprintf('No bit errors detected!\n');
end
%figure;
%stem(abs(rx)-abs(tx));
end