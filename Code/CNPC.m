function txSymbols = CNPC(txDataTD)
% CNPC 连续非线性分段压扩
% txDataTDCP: 输入的OFDM信号  

     %% 参数计算
     Signal_Power = abs(txDataTD);
     phase = angle(txDataTD);
     Sigma = sqrt(mean(Signal_Power.^2));

     A_c = 1.88;
     a_5 = -3.4393;
     A_i = 1.0319;
     Sigma_c = sqrt(0.0036);
     
     k_4 = A_c^3*A_i - 2*a_5*A_c^3 - 2*A_c^2*A_i^2 + 2*a_5*A_c^2*A_i + 2*A_c*A_i^3 + 2*a_5*A_c*A_i^2 - 2*a_5*A_i^3;
     k_3 = a_5*A_c^4 + 2*a_5*A_c^3*A_i - 2*A_c^2*A_i^3 - 6*a_5*A_c^2*A_i^2 - A_c*A_i^4 + 2*a_5*A_c*A_i^3 + a_5*A_i^4;
     k_2 = -2*a_5*A_c^3 + A_c^2*A_i^2 + 2*a_5*A_c^2*A_i + 2*A_c*A_i^3 + 2*a_5*A_c*A_i^2 - 2*a_5*A_i^3;
     a_4 = k_4 / (A_c*A_i*(A_c - A_i)^2);
     a_3 = k_3 / (A_c^2*A_i^2*(A_c - A_i)^2);
     a_2 = k_2 / (A_c^2*A_i^2*(A_c - A_i)^2);
     a_1 = -(-a_5*A_c^2 + A_c*A_i^2 + 2*a_5*A_c*A_i - a_5*A_i^2) / (A_c^2*A_i^2*(A_c - A_i)^2);

     %% 压缩信号
     L = length(Signal_Power);
     for i = 1:L
         if Signal_Power(i) < A_i
             Signal_Power(i) = Signal_Power(i);
         elseif Signal_Power(i) > A_c
             Signal_Power(i) = A_c;
         else
             Signal_Power(i) = a_1*Signal_Power(i)^4 + a_2*Signal_Power(i)^3 + a_3*Signal_Power(i)^2 + a_4*Signal_Power(i) + a_5;
         end
     end
     txSymbols = Signal_Power.*exp(1i*phase);
end