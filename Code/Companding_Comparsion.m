function Companding_Comparsion(txDataTDCP1,txDataTDCP2)
% 此函数用来对比压扩前后的幅值
    Power_txDataTDCP1 = abs(txDataTDCP1);
    Power_txDataTDCP2 = abs(txDataTDCP2);
    plot(Power_txDataTDCP1,'LineWidth',2);
    hold on
    plot(Power_txDataTDCP2,'LineWidth',2);
    legend('压扩前的信号','压扩后的信号');
    title('压扩算法在时域上的处理效果');
    xlabel('输入信号：x[n]');
    ylabel('幅度值');
end