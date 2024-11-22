function txSymbols = u_law(txDataTD,u)
% txDataTDCP: 输入的OFDM信号  
% mu: μ-law算法的压缩参数，通常取值为2到5之间 

  Signal_Power = abs(txDataTD);            % 计算信号的幅度
  u_law_Signal_Power = (log(1+u*Signal_Power)/log(1+u));   
  txSymbols = u_law_Signal_Power.*exp(1i*angle(txDataTD)); 
end