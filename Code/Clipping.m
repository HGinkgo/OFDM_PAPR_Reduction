function [txSymbols,difference] = clipping(txDataTDCP,index)
% txDataTDCP: 输入的OFDM信号  

    Signal_Power = abs(txDataTDCP);    
    phase = angle(txDataTDCP);
    L = length(Signal_Power);
    Signal_Power_new = zeros(1,L);
    
    for i = 1:L
        if Signal_Power(i) < index
            Signal_Power_new(i) = Signal_Power(i);
        else
            Signal_Power_new(i) = index;
        end
    end
    
    txSymbols = Signal_Power_new.*exp(1i*phase);
    difference = Signal_Power - Signal_Power_new;
    difference = difference.*exp(1i*phase);
end