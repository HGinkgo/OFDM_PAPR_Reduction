function [Sout] = HPA(Tx,HPA_type,Y_N,IBO)
% Sout为输出信号
% signal为输入信号
% backoff为所要求的输入回退

    signal=Tx;
    if HPA_type == 0
        signal_output = signal;
    elseif HPA_type == 1 % 常用SSPA
        Aamp = abs(signal);
        p = 2;
        AM1 = Aamp./((1+(Aamp/1).^(2*p)).^(1/(2*p)));
        TX_Symbols_OFDM_HPA = AM1.*exp(1i*(angle(signal)));
        signal_output = TX_Symbols_OFDM_HPA;
    elseif HPA_type == 2 % 常用TWTA
        backoff = IBO;
        v = 1;
        beta_a = 0.25;
        alpha_ph = pi/3;
        beta_ph = 1;
        Aamp = sqrt(backoff)*abs(signal);
        AM1 = v*Aamp./(1+beta_a*(Aamp).^2);
        P = sum(abs(AM1).^2)/sum(abs(Aamp).^2);
        fa = alpha_ph* Aamp.^2./(1+beta_ph*(Aamp.^2));
        signal_output = AM1.*exp(1i*(angle(signal)+fa))./sqrt(P);
    end
    if Y_N == 1
        Sout = signal_output;
    elseif Y_N == 0
        Sout = Tx;
    end
end