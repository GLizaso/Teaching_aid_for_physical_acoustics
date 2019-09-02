%%                          diffractionExampleB                           
%
% Diffraction of a plane wave defined by the free-form source option.
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

imageFileName = 'diffractionObstacle.bmp';

scale = 1e-3;             % Side of the minimal square on the grid [m]
duration = 2e-3;          % Simulation duration [s]
recordVideo = false;      % Record the simulation to a video file? 
c0 = 344;                 % Sound speed [m/s]
source.mode = 'additive'; % The default source mode is additive

% Setting a free-form source type (runs an equation defined by the user)
source.type = '0.2*sin(2*pi*3000*t)+0.2*sin(2*pi*30000*t)';

%% Simulation start

[sensorData, t, dt, equation, lx, ly] = ...
simulateImage256(imageFileName, scale, duration, recordVideo, c0, source);

%% Plot of the results

subplot(2,1,1)
plot(t, equation); grid on;
title('Sources'); xlabel('Time [s]'); ylabel('Pressure [Pa]')

subplot(2,1,2)
plot(t, sensorData); grid on
title('Sensors'); xlabel('Time [s]'); ylabel('Pressure [Pa]')

legend('1','2','Location','NorthWest')
