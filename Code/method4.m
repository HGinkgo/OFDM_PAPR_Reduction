function txSymbols = method4(txDataTD)
%% 参数计算
     Signal_Power = abs(txDataTD);
     phase = angle(txDataTD);
     Sigma = 1;

     a = 7.7499;
     b = 5.0536;
     c = 0.48;
     d = 2;

     A = (2*c)/(Sigma) * exp(-c^2)*(exp((c*b-a)*Sigma)+1);
     k_1 = exp((b*exp(-c^2))/(-A)) * (exp(-a*Sigma)+exp(-c*b*Sigma));
     k_2 = exp(-a*Sigma);
     k_3 = exp(b/A);

%% 压缩信号
     L = length(Signal_Power);
     for i = 1:L
         if Signal_Power(i) <= c*Sigma
             Signal_Power(i) = Signal_Power(i);
         elseif Signal_Power(i) > c*Sigma
             Signal_Power(i) = (-1)/b * log(k_1*k_3^(exp(-Signal_Power(i)^2/Sigma^2))-k_2);
         end
     end

     txSymbols = Signal_Power.*exp(1i*phase);
end

