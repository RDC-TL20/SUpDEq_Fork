%% SUpDEq - Spatial Upsampling by Directional Equalization
%
% function figureHandle = supdeq_plotIR( ir1, ir2, logIR, fs, FFToversize, titleText)
%
% This function plots magnitude, phase, and group delay 
% of one or two impulse responses
%
% Output:
% Figure with 4 subplots
%
% Input:
% ir1           - Impulse Response 1 - For example HRIR left
% ir2           - Impulse Response 2 - For example HRIR right
% logIR         - True/False - plot ir logarithmic or linear
%                 Default: false
% fs            - Sampling rate
%                 Default: 48000
% FFToversize   - Factor to increase FFT resolution.
%                 2^nextpow2(length(ir)) * FFToversize
% titleText     - Optional figure title text
%
% Dependencies: -
%
% (C) 2018 by JMA, Johannes M. Arend
%             TH K�ln - University of Applied Sciences
%             Institute of Communications Engineering
%             Department of Acoustics and Audio Signal Processing

%%
function figureHandle = supdeq_plotIR( ir1, ir2, logIR, fs, FFToversize, titleText)

plotir2 = true;
if nargin < 2
    plotir2 = false;
    ir2 = [];
end

if isempty(ir2)
    plotir2 = false;
end

if nargin < 3 || isempty(logIR)
    logIR = false;
end

if nargin < 4 || isempty(fs)
    fs = 48000;
end

if nargin < 5 || isempty(FFToversize)
    FFToversize = 1;
end

if nargin < 6 || isempty(titleText)
    titleText = "";
else
    titleText = string(titleText);
end

%Check size of ir
if size(ir1,2) > size(ir1,1)
    ir1 = ir1';
end

if plotir2
    if size(ir2,2) > size(ir2,1)
        ir2 = ir2';
    end
end

%% Get spec, phase, group delay

NFFT = length(ir1);
if plotir2
    if length(ir2) > NFFT
        NFFT = length(ir2);
    end
end

NFFT    = (2^nextpow2(NFFT));
if FFToversize > 1
    NFFT = NFFT*FFToversize;
end

fVec    = linspace(0,fs/2,NFFT/2+1);
fVec2   = linspace(0,fs/2,NFFT/2);
tVecir1 = linspace(0, length(ir1)/fs, length(ir1));
if plotir2
    tVecir2 = linspace(0, length(ir2)/fs, length(ir2));
end

specir1 = fft(ir1,NFFT);
specir1 = specir1(1:end/2+1,:);
phiir1  = unwrap(angle(specir1));
grir1   = -diff(phiir1) / (2*pi) * NFFT/fs;

if plotir2
    specir2 = fft(ir2,NFFT);
    specir2 = specir2(1:end/2+1,:);
    phiir2  = unwrap(angle(specir2));
    grir2   = -diff(phiir2) / (2*pi) * NFFT/fs;
end

%% Plot

figureHandle = figure;
set(figureHandle,'Color','w');
if strlength(titleText) > 0
    set(figureHandle, 'Name', char(replace(titleText, newline, ' | ')));
end
linewidth = 1.1;
legendLabels = {'IR1', 'IR2'};

subplot(2,2,1)
if logIR
    ir1Handle = plot(tVecir1,20*log10(abs(ir1)),'k','Linewidth',linewidth);
else
    ir1Handle = plot(tVecir1,ir1,'k','Linewidth',linewidth);
end
if plotir2
    hold on;
    if logIR
        ir2Handle = plot(tVecir2,20*log10(abs(ir2)),'r','Linewidth',linewidth);
    else
        ir2Handle = plot(tVecir2,ir2,'r','Linewidth',linewidth);
    end
    hold off;
    legend([ir1Handle, ir2Handle], legendLabels, 'Location', 'NorthEast');
end
xlabel('Time in s');
if logIR
    ylabel('Magnitude in dB');
    title('Log Impulse Response');
else
    ylabel('Amplitude');
    title('Impulse Response');
end
grid on;

subplot(2,2,2)
spec1Handle = semilogx(fVec,20*log10(abs(specir1)),'k','Linewidth',linewidth);
if plotir2
    hold on;
    spec2Handle = semilogx(fVec,20*log10(abs(specir2)),'r','Linewidth',linewidth);
    hold off;
    legend([spec1Handle, spec2Handle], legendLabels, 'Location', 'best');
end
xlim([20, fs/2]);
title('Magnitude Spectrum');
xlabel('Frequency in Hz');
ylabel('Magnitude in dB');
grid on;

subplot(2,2,3)
phase1Handle = semilogx(fVec,phiir1,'k','Linewidth',linewidth);
if plotir2
    hold on;
    phase2Handle = semilogx(fVec,phiir2,'r','Linewidth',linewidth);
    hold off;
    legend([phase1Handle, phase2Handle], legendLabels, 'Location', 'best');
end
xlim([20, fs/2]);
xlabel('Frequency in Hz');
ylabel('Phase in degrees');
title('Phase');
grid on;

subplot(2,2,4)
groupDelay1Handle = semilogx(fVec2,grir1*1000,'k','Linewidth',linewidth);
if plotir2
    hold on;
    groupDelay2Handle = semilogx(fVec2,grir2*1000,'r','Linewidth',linewidth);
    hold off;
    legend([groupDelay1Handle, groupDelay2Handle], legendLabels, 'Location', 'best');
end
xlim([20, fs/2]);
title('Group Delay');
xlabel('Frequency in Hz');
ylabel('Group Delay in ms');
grid on;

if strlength(titleText) > 0
    sgtitle(titleText, 'Interpreter', 'none');
end

end

