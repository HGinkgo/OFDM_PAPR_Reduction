function PAPR_1= PAPR(txDataTDCP)
% 计算输入的PAPR，输出PAPR
    Signal_Power = abs(txDataTDCP);
    peak_power = (Signal_Power).^2;
    average_power = mean(Signal_Power.^2);
    PAPR_1 = 10 * log10(peak_power ./ average_power);
end

