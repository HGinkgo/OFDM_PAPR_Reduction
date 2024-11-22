# OFDM_PAPR_Reduction
该代码用于实现OFDM系统的仿真，以及一些降低PAPR的Companding方法
以下是函数说明及来源

## 主要函数说明
- OFDM_PAPR：主程序，运行可得到PAPR曲线和BER曲线。
- detector_OFDM：用于检测OFDM的误码率性能。
- HPA：功率放大器仿真，提供了SSPA和TWTA两种放大器。
- PAPR：用于计算OFDM测试信号的PAPR。
- Clipping：用Clipping方法压缩OFDM时域信号。
- u_law：用u律方法压缩OFDM时域信号。
- TL：用TL方法压缩OFDM时域信号，参考：https://ieeexplore.ieee.org/document/9205986
- CNPC：用CNPC方法压缩OFDM时域信号，参考：https://ieeexplore.ieee.org/document/9205986
- Method4：用Method4方法压缩OFDM时域信号（作者没给命名，笑死），参考：https://ieeexplore.ieee.org/document/10310182
- DPD：数字预失真方法提高误码率性能。
- Signal_compensation：用于在接收机恢复因压缩而失去的信号。
## 小工具
- PDF：用于观察信号的功率谱密度分布情况。
- Companding_Comparsion：用于观察压缩前后的时域信号。
