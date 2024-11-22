function PDF(txDataTDCP)
% 此函数用于绘制信号幅值的概率密度分布图
    Signal_Power = abs(txDataTDCP);
    [f,xi] = ksdensity(Signal_Power);   
    data_min = min(Signal_Power);  
    data_max = max(Signal_Power); 
    xi_clipped = xi(xi >= data_min & xi <= data_max);  
    f_clipped = f(xi >= data_min & xi <= data_max);  

    % 绘制PDF  
    figure;  
    plot(xi_clipped, f_clipped,'LineWidth',2);  
    title('概率密度函数');  
    xlabel('幅度值');  
    ylabel('概率密度');  
    xlim([data_min data_max]); % 限制x轴范围  
    grid on
    hold on
end