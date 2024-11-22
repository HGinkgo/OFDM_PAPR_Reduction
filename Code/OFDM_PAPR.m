% MIMO-OFDM
% 此代码可以画出Companding_OFDM的误码率曲线

%% 初始化
clc
clear 
warning off

symbolOrder = 2;                              % 调制阶数
N = 16;                                       % 信噪比范围
EbN0 = 1:1:N;                                 % 信噪比
numRun = 1000;
PAPR_OFDM = zeros(1,N*numRun*640);
SDR_OFDM = zeros(1,N*numRun);
%% 天线配置
nTx = 1;                                      % 发射天线数
nRx = 1;                                      % 接收天线数
%% OFDM参数
overFac = 4;                                  % 时域过采样因子
CarrierSize = 128;
FFTsize = CarrierSize*overFac;                % FFT大小
numSubcarriers = FFTsize/overFac;             % 子载波数
CPsize = FFTsize/4;
%% 参数
HPA_type = 1;                                 % 放大器类型 1：SSPA 2：TWTA
IBO = 0;
IBO_alpha = 10.^(-IBO/10);
SC = 0;                                       % 0：OFDM 1：DFT-s-OFDM 
SE = 4;                                       % 0：OFDM 1：u_law 2：TL 3：CNPC 4:method4
SF = 0;                                       % 0：OFDM 1：clipping
SNRdBs = EbN0-10*log10(overFac)+10*log10(symbolOrder);
BER = zeros(1,length(SNRdBs));                % 初始化 BER

%% 仿真
for iSNR = 1:length(SNRdBs)
    SNRdB = SNRdBs(iSNR);
    EbN0_i = EbN0(iSNR);
    fprintf('EbN0 = %d dB ',EbN0_i);
    numErrBits = 0;
    for iNumRun = 1:numRun
        %% 将比特流分配到每根发送天线上
        lenBits = numSubcarriers*nTx*symbolOrder;
        inputBits = randi([0 1],1,lenBits);             % 生成测试比特信号
        modSymbols = qammod(inputBits(:), 2^symbolOrder, 'InputType', 'bit', 'UnitAveragePower', true);
        txSymbols = reshape(modSymbols,nTx,[]);         % 初始传输信号

        %% DFT
        if SC == 1
            txSymbols = fft(txSymbols)./sqrt(length(txSymbols));
        end
        %% IFFT 转为时域信号
        txDataFD = zeros(nTx,FFTsize);
        txDataFD(:,1:numSubcarriers/2) = txSymbols(:,1:numSubcarriers/2);
        txDataFD(:,end-numSubcarriers/2+1:end) = txSymbols(:,end-numSubcarriers/2+1:end);  %过采样
        txDataTD = ifft(txDataFD,[],2).*sqrt(FFTsize).*sqrt(overFac); 

        %% 加循环前缀
%         PWR_txDataTD = sum(abs(txDataTD).^2)/FFTsize;  % 计算 OFDM 的功率
        txDataTDCP = [txDataTD(:,FFTsize-CPsize+1:FFTsize) txDataTD];
        txDataTDCP = Power_normalization(txDataTDCP);

        %% 压扩算法
        if SE == 1
            u = 8;
            txDataTDCP = u_law(txDataTDCP,u);
        elseif SE == 2
            [txDataTDCP,Sigma] = TL(txDataTDCP);
        elseif SE == 3
            txDataTDCP = CNPC(txDataTDCP);
        elseif SE == 4
            txDataTDCP = method4(txDataTDCP);
        end

        %% 削峰算法
        if SF == 1
            index = 1.4;
            [txDataTDCP,difference] = clipping(txDataTDCP,index);
        end

        %% 计算 PAPR
        PAPR_new = PAPR(txDataTDCP);
        PAPR_OFDM((iSNR-1)*numRun*overFac*1.25*CarrierSize+(iNumRun-1)*overFac*1.25*CarrierSize+1:(iSNR-1)*numRun*overFac*1.25*CarrierSize+(iNumRun-1)*overFac*1.25*CarrierSize+overFac*1.25*CarrierSize) = PAPR_new;
       
        %% IBO功率回退
        txDataTDCP = sqrt(IBO_alpha)*txDataTDCP;                              % IBO功率回退
        PWR_TXIBO = sum(abs(txDataTDCP).^2)/(FFTsize+CPsize);                 % IBO后的信号功率，即HPA的输入信号

        %% 数字预失真
        txDataTDCP_DPD = DPD(txDataTDCP,HPA_type,1,IBO_alpha); 

        %% 过放大器
        txDataTDCP_HPA = HPA(txDataTDCP_DPD,HPA_type,1,IBO_alpha);            % 经过HPA

        %% 计算 SDR
        SDR_alpha = real(mean(conj(txDataTDCP).*txDataTDCP_HPA))/PWR_TXIBO;   % 计算失真系数
        Distortion_HPA = txDataTDCP_HPA-txDataTDCP*SDR_alpha;                 % 计算过HPA的非线性失真噪声
        PWR_distortion_HPA = sum(abs(Distortion_HPA).^2)/(FFTsize+CPsize);    % 计算非线性失真噪声的功率
        SDR = SDR_alpha^2*PWR_TXIBO/PWR_distortion_HPA;                       % 计算SDR
        SDR_dB = 10*log10(SDR);
        SDR_OFDM((iSNR-1)*numRun+iNumRun) = SDR_dB; 

        txDataTDCP = txDataTDCP_HPA;
        %% 过AWGN信道
        outputData = txDataTDCP;                     % AWGN 信道
        H = ones(nRx,nTx,FFTsize);                   % AWGN 信道估计
        rxDataNoise = zeros(size(outputData));
        for k = 1:nRx
            rxDataNoise(k,:) = awgn(outputData(k,:),SNRdB).';
            %rxDataNoise(k,:) = outputData(k,:);
        end

        %% 去CP
        rxDataNoise1 = rxDataNoise(:,CPsize+1:end);  % 去除 CP   
        
        %% 均衡
        rxDataNoise2 = fft(rxDataNoise1,FFTsize,2)./(sqrt(FFTsize)*sqrt(overFac));
%         scatterplot(rxDataNoise2);
        H = reshape(squeeze(H),nTx,[]);
        rxDataEq1 = rxDataNoise2./H;                 % ZF 均衡
         
        % if SE ~= 0
        % for i = 1:3
        % %% 收端补偿
        % rxDataEq1 = Signal_compensation(rxDataEq1,rxDataNoise1,H,nTx,symbolOrder,FFTsize,overFac,SNRdB,SC,SE);
        % end
        % end
     
        %% 检测
        rxDataEq1 = rxDataEq1/sqrt(IBO_alpha);
        rxDataEq = rxDataEq1;
        estBits = detector_OFDM(rxDataEq,H,nTx,symbolOrder,FFTsize,overFac,SNRdB,SC);
        %% 统计BER
        numErrBits = numErrBits+biterr(inputBits,estBits);
    end
    BER(iSNR) = numErrBits/(numRun*lenBits);
    fprintf('\n');
%     if (BER(1,iSNR)==0)
%         break
%     end
end

%% 输出SDR结果
SDR = mean(SDR_OFDM);
fprintf('SDR = %.4f dB',SDR);

%% 作图
% 绘制原始OFDM的CCDF
PAPR_OFDM = PAPR_OFDM(PAPR_OFDM > 0); 
[cdf1, PAPR_OFDM_CCDF] = ecdf(PAPR_OFDM);

figure(1)
semilogy(PAPR_OFDM_CCDF,1 - cdf1,'-','LineWidth',2);
% xlim([0 max(PAPR_OFDM_CCDF)]);
legend('OFDM','DFT-S-OFDM','TL(A=2)','CNPC(Ac=1.88)','Zhang(c=0.48)')
title('QPSK调制下各算法处理后的PAPR曲线')
xlabel('PAPR'); 
ylabel('CCDF'); 
grid on
hold on

figure(2)
semilogy(EbN0,BER,'LineWidth',2);
xlim([1 N]); 
legend('OFDM','DFT-S-OFDM','Companding','TL(A=2)','CNPC(Ac=1.88)','Zhang(c=0.48)')
title('QPSK调制下各算法处理后的BER曲线');
xlabel('EbN0(dB)');
ylabel('BER');
grid on
hold on