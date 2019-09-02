%%                         combFilterExample                    
% 
% Reflection of an impulse on a nearby wall to generate a comb filter at 
% the sensor location.
%
% Propagation of one cycle of a sinusoidal plane wave inside an infinite 
% tube with an open end.
%
% The simulated image must be a 256-colour bitmap (BMP file extension).
% Efficient values for the computational grid side include 
% 128, 256, and 512.
%
%--------------------------------------------------------------------------
% Reference paper
%--------------------------------------------------------------------------
% "MATLAB-based simulation software as teaching aid for physical acoustics"
% Jorge Petrosino, Lucas Landini, Georgina Lizaso, Ian Kuri, Ianina Canalis
% 23rd International Congress on Acoustics, 2019.
% 
% Sample simulations and complementary functions available at:
% https://github.com/GLizaso/Teaching_aid_for_physical_acoustics

%% Simulation inputs

imageFileName = 'combFilter.bmp';

scale = 1e-2;              % Side of the minimal square on the grid [m]
duration = 0.7e-2;         % Simulation duration [s]
recordVideo = false;       % Record the simulation to a video file? 
c0 = 344;                  % Sound speed [m/s]
source.type = 'impulse';   % Generates an impulse at the source location
source.amplitude = 10;     % Amplitude [Pa]
source.mode = 'dirichlet'; % The default source mode is additive

%% Simulation start

[sensorData, t, dt, equation, lx, ly] = ...
simulateImage256(imageFileName, scale, duration, recordVideo, c0, source);

%% Plot of the results

subplot(2,1,1)
plot(t, equation); grid on;
title('Sources'); xlabel('Time [s]'); ylabel('Pressure [Pa]')

subplot(2,1,2)
plot(t, sensorData);
title('Sensors'); xlabel('Time [s]'); ylabel('Pressure [Pa]')

legend('1','2','Location','NorthWest')

%% Spectrum analysis

H1 = fft(sensorData(1,:));
H2 = fft(sensorData(2,:));
f=(0:length(t)-1)/length(t)/dt; 

figure
plot(f,20*log10(abs(H1)), f,20*log10(abs(H2)))
axis([0 15000 -inf inf]) 
grid on
