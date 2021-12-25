%Michael Bentivegna, Simon Yoon, Joya Debi
%ECE310 DSP : Sample Rate Converter

clear;
clc;
close all;

%This program processes a specified input file sampled at 11025 Hz and
%changes the sampling rate to 24000 Hz.  Since the ratio of new sampling
%rate to old sampling rate was quite complex, a multistage approach was 
%chosen to minimize computational complexity.  This was completed by iteratively
%passing the data through simpler converters.  The upsampling function uses
%a polyphase filtering approach to help properly interpolate the data.  The
%downsampling function simply scales the DSP Toolbox downsample() function and
%does not need to be refiltered since min(pi/L, pi/M) ensures that the
%filtering process prior to upsampling properly prevents the sound from aliasing. The
%verify function in the data shows that the program meets all
%specifications as the project outlines.

%% Main

%Process input file
[x,fs] = audioread('Wagner.wav');

%Make sure the resampling satisfies given parameters on test case
y = srconvert([1 zeros(1,3000)]);
verify(y); 

%Convert actual sound input
z = srconvert(transpose(x));

%Play orginal sound followed by the newly sampled version
sound(x, fs);
pause(10);
sound(z, 24000);


%% Functions

%Mission control
function [x] = srconvert(x)
    %Upsampling and filter loop
    SamplingVectorUp = [2, 2, 2, 2, 2, 2, 5]; % prime factorization of 320
    SamplingVectorDown = [7, 7, 3]; % prime factorization of 147
    
    %Compoundingly upsample for each prime factorization of 320
    for i = 1:length(SamplingVectorUp)
        [x] = upSampleFunc(x, SamplingVectorUp(i)); 
    end
    
    %Compoundingly downsample for each prime factorization of 147
    for j = 1:length(SamplingVectorDown)
        [x] = downSampleFunc(x, SamplingVectorDown(j));
    end
end

%Upsample the input using polyphase filtering with interpolation
function [outputU] = upSampleFunc(inputU, L) 
    
    %Repeats the input in multiple rows
    x = bsxfun(@times,ones(L,1), inputU);
    
    %Creates proper filter and uses poly1 to decompose it 
    filter = designfilt('lowpassfir', 'PassbandFrequency', 1/L, 'StopbandFrequency', 1.2/L, 'PassbandRipple', 0.02, 'StopbandAttenuation', 90, 'DesignMethod', 'equiripple');
    E = poly1(filter.Coefficients, L);
    
    %Declare size using known properties of discrete convolution
    filtered = zeros(L,length(E) + length(x) - 1);
    
    %Use convolution to filter the input at each polyphase level
    for n = 1:L
        filtered(n,:) = conv(E(n,:), x(n,:));
    end
    
    %Declare upsampled matrix
    upS = zeros(L,L*(length(filtered)));
    
    %Upsample the filtered input and properly interpolate the data
    for n = 1:L
        upS(n,:) = upsample(filtered(n,:), L);
        upS(n,:) = circshift(upS(n,:),n-1);
    end  
    outputU = sum(upS);    
    
end

%Simple downsampling function
%No need to filter again since L > M (guarantees no aliasing from M when filtering the upsample)
function [outputD] = downSampleFunc(inputD, M)

    outputD = M*downsample(inputD, M);

end
