%Michael Bentivegna, Simon Yoon, Joya Debi
%ECE310 DSP Project 5: Power Spectral Density Estimation

clear;
clc;
close all;

load pj2data;

% The objective of this project was to utilize MATLAB 
% functions to compare different parametric and non- parametric
% techniques for calculating power density spectrum (PDS) 
% estimation. In order to produce the results of these methods, 
% we utilized autocorrelation, windowing, and other significant 
% functions to sort through finite length signals and DFT. The methods 
% considered were non-parametric direct(periodogram, periodogram 
% averaging) and non-parametric indirect(Blackman-Tukey).
% Additionally, we incorporated parametric all-pole modeling for
% PDS estimation.

%% Part A1

ySubset = y(1:32);

yCorrelation = xcorr(ySubset, ySubset, 'biased');
%yCorrelationUB = xcorr(ySubset, ySubset, 'unbiased');

ySubsetFlip = fliplr(ySubset);
yConv = conv(ySubset, ySubsetFlip);

figure(1);
hold on;
plot(yCorrelation);
plot(yConv);

legend("Using xcorr", "Using conv")
title("Autocorrelation of y1");
xlabel("Time units")
ylabel("Magnitude")

% The difference when replacing biased with unbiased in terms of
% calculating the cross correlation with xcorr is minimal, but still
% noticable. The unbiased plot fail to match the peaks of the biased 
% graph as it deviates from the middle because the unbiased estimate 
% is scaled differently. Because 'm' is  changing throughout the 
% correlation function, the difference between the biased and unbiased
% output varies.

% Biased scaling factor : 1/N
% Unbiased scaling factor : 1/(N-|m|)

%% Part A2

% The fourier transform of the autocorrelation function is the Power
% Spectral Density (PSD) of that function. Thus, for any input signal
% output must be both real and positive.

yCorrDFT = fft(yCorrelation, 64);

figure(2);
subplot(2,1,1);
plot(0:length(yCorrDFT)-1, abs(yCorrDFT));
title("DFT of Biased Autocorrelation Function");
xlabel("Frequency (Hz)")
ylabel("Magnitude");

subplot(2,1,2)
plot(0:length(yCorrDFT)-1, angle(yCorrDFT));
title("DFT of Biased Autocorrelation Function");
xlabel("Frequency (Hz)")
ylabel("Phase");


phi = zeros(1, 32);
for i = 1:32
    phi(1, i) = 1/32 * sum(ySubset(i:32).*ySubset(1:32-i+1));
end

% The 64 point DFT of c_y1y1[m] is similar to that of phi^d_y1y1. 


%% Part A3

%Part a)
phiDFT = fft(phi, 64);

figure(3);
subplot(3,1,1);
plot(0:length(phiDFT)-1, abs(phiDFT));
title("DFT of Deterministic Autocorrelation Function");
xlabel("Frequency (Hz)");
ylabel("Magnitude");

%Part b)
ySubsetDFT = fft(ySubset,64);

subplot(3,1,2);
plot(0:length(ySubsetDFT)-1, abs(ySubsetDFT).^2);
title("DFT for First 32 Values of Y");
xlabel("Frequency (Hz)");
ylabel("Magnitude Squared");

%Part c)
ySubset64 = y(1:64);
ySubset64DFT = fft(ySubset64,64);

subplot(3,1,3);
plot(0:length(ySubset64DFT)-1, abs(ySubset64DFT).^2);
title("DFT for First 64 Values of Y");
xlabel("Frequency (Hz)");
ylabel("Magnitude Squared");

% The graphs produce similar waveform shapes, but the 
% differences lie in the amplitudes. 

%% Part B1
length = 64;
freqResponse = downsample(Hejw2, 8);

figure(4);
hold on;
plot(0:length-1, freqResponse);
plot(0:length-1, abs(ySubsetDFT).^2/64);
hold off;

title("Power Spectral Density for y[n]");
xlabel("n");
ylabel("Magnitude Squared");
legend('Desired Frequency Response','Estimate of PDS');


error1  = (sum((freqResponse - abs(ySubsetDFT).^2/64).^2))/64;
disp("Error with 32 points: " + error1);

%% Part B2
length2 = 512;

figure(5);
ySub = y(1:64);
window = rectwin(64);
periodogram(ySub, window, 1024);

EstPDS = abs(fft(y,1024)).^2;
EstPDS = downsample(EstPDS, 2)/1024;

figure(6);
hold on;
plot(0:length2-1, Hejw2);
plot(0:length2-1, EstPDS);
hold off;

title("Power Spectral Density for y[n]");
xlabel( "n" );
ylabel( "Magnitude Squared" );
legend('Desired Frequency Response','Estimate of PDS');
xlim([0 length2-1])

error2  = sum((Hejw2 - EstPDS).^2 ) / 512;
disp( "Error with 512 points: " + error2);

%% Part B3
yNew = zeros(1, 64);

for i = 1:16
    y1 = (i-1)*32 + 1;
    yNewB = y(y1: y1 + 31);
    yNew = yNew + abs(fft(yNewB, 64)).^2;
end
 
yNew = yNew / 1024;
Hejw2_64 = downsample(Hejw2,8);

figure(7);
hold on;
plot(0:length-1, Hejw2_64);
plot(0:length-1, yNew);
hold off;

title("Power Spectral Density for y[n]");
xlabel( "n" );
ylabel( "Magnitude Squared" );
legend('Desired Frequency Response','Estimate of PDS');
xlim([0 64]);

error3  = sum((Hejw2_64 - yNew).^2 ) / 64;
disp("Error using periodogram averaging: " + error3);

% The estimtion error using the periodogram averging 
% is less than those of parts B.1 & B.2. The errors 
% using periodogram averaging is 3.1403 versus 7.5039 
% and 7.5488 for B.1(32 points) and B.2(512 points)
% respectively. 

%% Part B4
yBlackman = xcorr(y, y, 'unbiased');
yBlackman = yBlackman(497: 527);

figure(8);
hold on;
plot(0:length-1, freqResponse);
plot(0:length-1, abs(fft(yBlackman,64)));
hold off;

title("Power Spectral Density for y[n]");
xlabel("n");
ylabel("Magnitude Squared");
legend('Desired Frequency Response','Estimate of PDS');

error4 = sum((freqResponse - abs(fft(yBlackman,64))).^2)/64;
disp("Error using Indirect Blackman-Tukey: " + error4);

%% Part B5
yTukey = abs(fft(triang(31)'.* yBlackman,64));

figure(9);
hold on;
plot(0:length-1, freqResponse);
plot (yTukey);
hold off;

title("Power Spectral Density for y[n]");
xlabel("n");
ylabel("Magnitude Squared");
legend('Desired Frequency Response','Estimate of PDS');

error5 = sum((freqResponse-yTukey).^2)/64;
disp( "Error with new estimation: " + error5);

errors = [error1, error2, error3, error4, error5];
Errors = table(errors);

% The Indirect Blackman-Tukey method generated the most
% accurate estiamte as it  resulted in the smallest error. 
% When calculating for the autocorrelation, a window is
% applied to compute via fft(). The Blackman-Tukey method 
% utilizes the auocorrelation function which smoothens the 
% waveform rather than the periodogram avergaging method 
% which takes the average of different waveforms generated
% via different 'n' points. The variance between the relevant
% waveforms increases at the extremities and truncating cuts
% off those high variance regions to produce better resolution. 

