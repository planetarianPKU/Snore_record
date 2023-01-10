clc;clear
%一期基础讲解视频
%适用人群：不怎么会MATLAB但又要做信号处理的（好矛盾的两点）
%本视频功效：应付个课程作业
%大纲
%1. 读取数据和前处理
%2. 滤波
%3. 频谱分析、时频分析的代码演示
%
%加载音频文件得到波形数据%
%https://www.mathworks.com/help/matlab/ref/audioread.html
[snore_long,Fs] = ...
    audioread("C:\Users\Sun\Desktop\my_snore\sample2.mp3");
disp(['Time = ' num2str(length(snore_long)/Fs) ' s']);
%生成时间轴用于画图
tms = (0:numel(snore_long(:,1))-1)/Fs;
%画图，参数很多但很好看
figure()
plot(tms,snore_long(:,1),'color','black','LineWidth',1);
xlabel('Time (s)'); ylabel('Amplitude');
set(gca,'Linewidth',3,'fontsize',20,'fontname',...
    'Time News Roman');

%音频分析部分%
sound(snore_long(:,2),Fs);

%截取单次信号
snore_template1 = snore_long(7.6e5:9e5,2);
tms1 = (0:numel(snore_template1)-1)/Fs;
%两端归零，避免截断产生的跳变带来吉布斯效应污染信号频谱
w = tukeywin(numel(snore_template1),0.05);
plot(w)
%注意这里的写法，是一个点再接乘法符号 .* 表示点点相乘
snore_1 = w.*snore_template1;
%画图检查信号
figure()
plot(tms1,snore_1,'color','black','LineWidth',1);
xlabel('Time (s)'); ylabel('Amplitude');
set(gca,'Linewidth',3,'fontsize',20,'fontname',...
    'Time News Roman');
sound(snore_1,Fs);



%傅里叶变换
%https://www.mathworks.com/help/matlab/ref/fft.html
figure()
Y = fft(snore_1);
T = 1/Fs;
L = length(snore_1);
t = (0:L-1)*T;

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1,'color','black','LineWidth',1) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)");ylabel("|P1(f)|");
set(gca,'Linewidth',3,'fontsize',20,'fontname',...
    'Time News Roman');

%检查各频段
%低通滤波
%https://www.mathworks.com/help/signal/ref/lowpass.html
lp = lowpass(snore_1,1e3,Fs);
plot(tms1,lp,'color','black','LineWidth',1);
sound(lp,Fs);
%带通滤波
bp1 = bandpass(snore_1,[1 3]*1e3,Fs);
plot(tms1,bp1,'color','black','LineWidth',1);
sound(bp1,Fs);
%带通滤波
bp2 = bandpass(snore_1,[4 6]*1e3,Fs);
sound(bp2,Fs);

%短时傅里叶变换分析%我不是很会调窗的长度
%https://www.mathworks.com/help/signal/ref/spectrogram.html
win = bartlett(4096);%bartlett窗
%信号 窗函数 overlap点数,FFT窗的长度，采样率
[s, f, t, p] = spectrogram(snore_1, win, 2048, 4096, Fs);
waterplot(s,f,t);
xlim([0 0.5e3])


%小波变换分析
%https://www.mathworks.com/help/wavelet/ref/cwt.html
[cfs,frq] = cwt(snore_1,Fs);
tms2 = (0:numel(snore_1)-1)/Fs;

figure()
subplot(2,1,1)
plot(tms2,snore_1)
axis tight;
title("Signal and Scalogram");xlabel("Time (s)");ylabel("Amplitude")
subplot(2,1,2)
surface(tms2,frq,abs(cfs))
axis tight
shading flat
xlabel("Time (s)")
ylabel("Frequency (Hz)");
ylim([0 5e2]);

lp2 = lowpass(snore_1,300,Fs);
sound(lp2,Fs);
