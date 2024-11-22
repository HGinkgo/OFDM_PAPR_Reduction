function [txSymbols,Sigma] = TL(txDataTD)
% TL 基于正切线性化的非线性压扩算法
% txDataTDCP: 输入的OFDM信号  
% A的可行范围约为[1.415，2.085]
    %% 参数计算
     Signal_Power = abs(txDataTD);
     phase = angle(txDataTD);
     Sigma = 1;
    
%      syms a t
%      eq1 = a*exp(-t^2)*(A^2-2*A^2*t^2+4*A*t^3-2*t^4-t^2-1)+a == 1;
%      eq2 = a*Sigma^2*exp(-t^2)*(3*A^4-6*A^4*t^2+8*A^3*t^3-2*t^6-3*t^4-6*t^2-6)/6+a*Sigma^2 == 1;
%      solutions = solve([eq1, eq2], [a, t]);
%      disp(solutions);
%      a = double(solutions.a);  
%      t = double(solutions.t);
    
     A = 2;
     a = 0.985;
     t = 0.975;
     k = ((2*a)/Sigma^2)*exp(-t^2)*(1-2*t^2);
     b = ((4*a*t^3)/Sigma)*exp(-t^2);
     D = b^2-k*(2*a*(1-exp(-t^2))-k*t^2*Sigma^2-2*b*t*Sigma);
     %% 压缩信号
     L = length(Signal_Power);
     for i = 1:L
         if Signal_Power(i) < Sigma*sqrt(-log(1-a+a*exp(-t^2)))
             Signal_Power(i) = Sigma*sqrt(log(a/(a-1+exp(-Signal_Power(i)^2/Sigma^2))));
         else
             Signal_Power(i) = (-b+sqrt(2*k*(1-exp(-Signal_Power(i)^2/Sigma^2))+D))/k;
         end
     end
     txSymbols = Signal_Power.*exp(1i*phase);
end

 