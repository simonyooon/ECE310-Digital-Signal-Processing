%Michael Bentivegna, Simon Yoon, Joya Debi
%ECE310 DSP : Enhancing Speech by Removing Noise

clear;
clc;
close all;

% This project uses 6 different lowpass filters to remove a high
% frequency hissing noise from an given audio file.  Each filter is properly
% implemented in MATLAB using the given specifications.  The order of 
% the filter and number of multiplication operations needed is 
% calculated before graphing. The filtered sound is then played to test 
% its efficacy.
%% Setup

% Load in data and listen to test sound
load ('projIB.mat');
sound(noisy,fs);  

% Create each filter using proper specifications
Butterworth = designfilt('lowpassiir','PassbandFrequency',2500, 'StopbandFrequency',4000,'PassbandRipple',3,'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','butter'); 
ChebyshevI = designfilt('lowpassiir','PassbandFrequency',2500,'StopbandFrequency',4000,'PassbandRipple',3,'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','cheby1');     
ChebyshevII = designfilt('lowpassiir','PassbandFrequency',2500, 'StopbandFrequency',4000,'PassbandRipple',3, 'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','cheby2');
Elliptic = designfilt('lowpassiir','PassbandFrequency',2500,'StopbandFrequency',4000,'PassbandRipple',3, 'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','ellip');     
ParksMcClellan = designfilt('lowpassfir','PassbandFrequency',2500,'StopbandFrequency',4000,'PassbandRipple',3,'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','equiripple');        
Kaiser = designfilt('lowpassfir','PassbandFrequency',2500,'StopbandFrequency',4000,'PassbandRipple',3,'StopbandAttenuation',55,'SampleRate',fs,'DesignMethod','kaiserwin');

%% Butterworth Filter
orderAndMultFinder(Butterworth, "Butterworth")
graphing(Butterworth, fs, noisy, "Butterworth");

%% ChebyshevI Filter
orderAndMultFinder(ChebyshevI, "Chebyshev Type I")
graphing(ChebyshevI, fs, noisy, "Chebyshev Type I")

%% ChebyshevII Filter
orderAndMultFinder(ChebyshevII, "Chebyshev Type II")
graphing(ChebyshevII, fs, noisy, "Chebyshev Type II")

%% Elliptic Filter
orderAndMultFinder(Elliptic, "Elliptic")
graphing(Elliptic, fs, noisy, "Elliptic")

%% Parks-McClellan Filter
orderAndMultFinder(ParksMcClellan, "Parks-McClellan")
graphing(ParksMcClellan, fs, noisy, "Parks-McClellan")

%% Kaiser Filter
orderAndMultFinder(Kaiser, "Kaiser")
graphing(Kaiser, fs, noisy, "Kaiser")

%% Qualitative Analysis of Sounds

% All of the filters were able to make the sentence "That noise problem
% grows more annoying each day" audible.  However, the Butterworth and
% Chebyshev Type I were able to do it with less background noise than the
% others.  This implies that the other filters did not properly filter
% out all of the necessary high frequency signals.

%% Functions

%Find the order of the filter and the number of multiplication operations
function orderAndMultFinder(filter, name)
    order = filtord(filter);
    fprintf("The order of the %s filter is %d\n", name, order);
    
    [b,a] = tf(filter);
    multOps = length(a) + length(b);
    fprintf("The number of mulitplying operations for the %s filter is %d\n", name, multOps);
end

%Creates necessary graphs and plays filtered sounds
function graphing(filters, fs, noisy, name)
    [H,f] = freqz(filters, fs);
    H_log = 20*log10(abs(H));
    
    figure(1);
    subplot(3,1,1);
    plot(f, H_log);
    title ('Magnitude Response of the ' + name + ' Filter');
    xlabel('Frequency');
    ylabel('Magnitude(dB)');
    
    subplot(3,1,2);
    plot(f,abs(H));
    xlim([0.3, 0.5]);
    title ('Passband Ripple of the ' + name + ' Filter');
    xlabel('Frequency');  
    ylabel('Magnitude (Linear Scale)');
    
    subplot(3,1,3);
    [gd,w] = grpdelay(filters, fs);
    plot(w,gd);
    title ('Group Delay in the ' + name + ' Filter');
    xlabel ('Frequency');
    ylabel ('Sample Delay');
    
    figure(2);
    [hz, hp, ~] = zplane(filters); 
    zplane(hz,hp);
    title('Pole-Zero plot for the ' + name + ' Filter');
    
    figure(3);
    [h,t] = impz(filters, 100); 
    stem(t,h);
    title('Impulse Response for the ' + name + ' Filter');
    xlabel('Samples');
    ylabel('Magnitude');
    
    filtered = filter(filters, noisy);
    soundsc(filtered, fs)
end
