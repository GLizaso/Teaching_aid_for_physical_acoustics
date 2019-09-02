function [sensorData, t, dt, equation, lx, ly] = ...
simulateImage256(imageFileName, scale, duration, recordVideo, c0, source)

%%                           simulateImage256   
%
% [sensorData, t, dt, equation, lx, ly] = ...
% simulateImage256(imageFileName, scale, duration, recordVideo, c0, source)
%
% this function runs time-domain simulations of acoustic wave propagation
% based on the information contained in any 256-colour bitmap image file.                                     
%
% Designed to work with the k-Wave toolbox, available for free at: 
% http://www.k-wave.org/
%
%--------------------------------------------------------------------------
% Input arguments
%--------------------------------------------------------------------------
% - Name of the 256-colour BMP image file to be used.
%   imageFilaName = 'name.bmp' 
%
% - Desired side measurement of the minimum square of the grid, in metres.
%   scale = 1e-3;
%
% - Desired duration of the simulation, in seconds.
%   duration = 2e-3;
%
% - Option to record the simulation to a video file, true or false.
%   recordVideo = true;
%
% - Desired sound speed value, in metres per second.
%   c0 = 344;
%
% - Source struct. Explained in the following section.
%
%--------------------------------------------------------------------------
% Source properties
%--------------------------------------------------------------------------
% The source argument is a structure arrays that admit 4 different formats. 
% These can be set by assigning certain values to the source struct.
% 
% 1) Impulse:
%    source.type = 'impulse';
%    source.amplitude = 8;        (desired amplitude)
%    source.mode = 'additive';
%
% 2) Sine wave: 
%    source.type = 'nCycles';     (desired number of cicles)
%    source.f0 = 1000; [Hz]       (desired frequency)
%    source.mode = 'additive';
%
% 3) White noise:
%     source.type = 'whiteNoise'; 
%     source.amplitude = 2; 
%     source.mode = 'additive';
%     source.duration = 2e-3; [s] (desired noise duration)
%
% 4) Free form (any mathematical expression accepted by MATLAB):
%     source.type = '4*sin(2*pi*1000*t+pi/4)' (example)
%     source.mode = 'additive'
%
%--------------------------------------------------------------------------
% Creation of sources, sensors and refletive surfaces
%--------------------------------------------------------------------------
% RED pixels are treated as SOURCES.
% GREEN pixels are treated as SENSORS.
% BLACK pixels are treated as perfectly reflective SURFACES. 
%
% Colour values are as follows:
% red = 79; 
% green = 113; 
% black = 0;
%
% These are the standard colour codes used by MS Paint, the most commonly
% available image editing software.
%
% The rest of the colours are ignored by the simulation, and can be used to 
% add notes and other useful information to the simulation's animation,
% without it affecting the results.
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

%% Image loading and format checking

image = imread(imageFileName);
format = imfinfo(imageFileName);

if format.BitDepth ~= 8 
    disp('Unsupported image file. 256-colour BMP files must be used');
end 

if not(strcmp(format.Format,'bmp')) 
    disp('Unsupported image file. 256-colour BMP files must be used');
end 

%% Grid settings

CFL = 0.3; 
dx = scale; dy = scale;
Nx = length(image(:,1));  Ny = length(image(1,:)); 
lx = Nx*dx; ly = Ny*dy;
kgrid = kWaveGrid(Nx, dx, Ny, dy);

%% Medium properties

medium.density = 1.24;    % Air density is the default. Can be modified.
medium.sound_speed = c0;  % c0 is a user-defined input argument

%% Time array creation

kgrid.t_array = makeTime(kgrid, medium.sound_speed, CFL , duration);
dt = kgrid.dt;            % Two of the function's  
t = kgrid.t_array;        % output arguments

%% Source properties

red = 79; % Red pixels in the image must have this value to work as sources

source.p_mask = (image == red);
source.p_mode = source.mode;   % User defined input arguments

% Verify the user-defined source type
switch source.type
    case 'impulse'
        equation = source.amplitude*impulseSource(dt, duration); 
    case 'nCycles'
        equation = source.amplitude * nCyclesSource(...
            source.f0, source.n, dt, duration);
    case 'whiteNoise'
        equation = source.amplitude * whiteNoiseSource(...
            source.duration, dt, duration);
    case 'nComponents'                                       
        equation = source.amplitude * nComponentsSource(... 
            source.f0, source.n, dt, duration);              
    otherwise
        eval(['equation =' source.type ';']);
end

% Assign the equation to the sources 
equation = equation(1:length(t)); 
source.p = equation;

% Clear unneeded fields from the source struct
[source.f0, source.amplitude, source.n] = deal(1);
source = rmfield(source, {'amplitude'; 'mode' ; 'type'; 'f0'; 'n'});


%% Perfectly reflective surfaces

black = 0; % Black pixels must have this value to work as surfaces

source.u_mask = (image == black);
source.u_mask(1,1) = 1;
source.ux = 0*kgrid.t_array;
source.uy = 0*kgrid.t_array;
source.u_mode = 'dirichlet';

%% Sensors 

green = 113; % Green pixels must have this value to work as sensors

sensor.mask = (image == green);

%% Simulation implementation

fullMask = image < 255; % This argument shows the image while simulating

inputArgs = {...
'DisplayMask',fullMask, 'RecordMovie',recordVideo, 'LogScale',false};

% Run simulation
sensorData = kspaceFirstOrder2D( ...
kgrid, medium, source, sensor, inputArgs{:});

end

