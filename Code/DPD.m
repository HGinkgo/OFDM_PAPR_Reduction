function txSymbols = DPD(txDataTDCP,HPA_type,Y_N,IBO_alpha)
%  数字预失真方法
    Signal_Power = abs(txDataTDCP);
    phase = angle(txDataTDCP);

    % %% 逆函数方法
    % p = 2;
    % Asat = 1;
    % L = length(Signal_Power);
    % for i = 1:L
    %     if Signal_Power(i) < Asat
    %         Signal_Power(i) = Signal_Power(i)/((1-(Signal_Power(i)/Asat)^(2*p))^(1/(2*p)));
    %     else
    %         Signal_Power(i) = 2;
    %     end
    % end
    % txSymbols = Signal_Power.*exp(1i*phase);

    %% 基于信号的预失真方法
    u1 = txDataTDCP;

    iterations = 4; % 迭代次数，
    u = cell(1, iterations + 1); 
    y = cell(1, iterations); 
    u{1} = u1; 

    for i = 1:iterations
        y{i} = HPA(u{i}, HPA_type, Y_N, IBO_alpha);
        u{i+1} = u{i} + txDataTDCP - y{i}/0.8;
    end
    u_final = u{iterations + 1};

    txSymbols = u_final;
end

