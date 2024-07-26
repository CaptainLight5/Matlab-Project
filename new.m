clc;
clear;
close all;

% This Define benchmark functions
sphere = @(x) sum(x.^2);
rosenbrock = @(x) sum(100*(x(2:end) - (x(1:end-1).^2)).^2 + (x(1:end-1) - 1).^2);
rastrigin = @(x) sum(x.^2 - 10*cos(2*pi*x) + 10);

% This Define optimization parameters
numRuns = 15;
dimensions = [2, 10]; % Dimensions to test

% This Initializes results storage
results = struct();

% This is the Functions to test
funcs = {sphere, rosenbrock, rastrigin};
funcNames = {'Sphere', 'Rosenbrock', 'Rastrigin'};

% The Optimization algorithms
algos = {'ga', 'pso', 'sa'};
algoNames = {'GA', 'PSO', 'SA'};

% This creates a directory for results if it doesn't exist
folderName = 'OptimizationResults';
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% Run optimization
for d = dimensions
    for i = 1:length(funcs)
        func = funcs{i};
        fName = funcNames{i};
        
        for j = 1:length(algos)
            algo = algos{j};
            aName = algoNames{j};
            
            bestResults = zeros(1, numRuns);
            for run = 1:numRuns
                switch algo
                    case 'ga'
                        options = optimoptions('ga', 'Display', 'off');
                        [~, fval] = ga(func, d, [], [], [], [], -5*ones(1, d), 5*ones(1, d), [], options);
                    case 'pso'
                        options = optimoptions('particleswarm', 'Display', 'off');
                        [~, fval] = particleswarm(func, d, -5*ones(1, d), 5*ones(1, d), options);
                    case 'sa'
                        options = optimoptions('simulannealbnd', 'Display', 'off');
                        [~, fval] = simulannealbnd(func, rand(1, d)*10 - 5, -5*ones(1, d), 5*ones(1, d), options);
                end
                bestResults(run) = fval;
            end
            
            % This stores results in a structured format
            results.(fName).(aName).(['D', num2str(d)]) = struct(...
                'Best', min(bestResults), ...
                'Worst', max(bestResults), ...
                'Mean', mean(bestResults), ...
                'StdDev', std(bestResults) ...
            );
            
            % Save results to file
            filename = fullfile(folderName, sprintf('%s_%s_D%d_results.mat', fName, aName, d));
            save(filename, 'bestResults');
        end
    end
end

% This Display results
disp(results);

% Example to plot and save convergence for one scenario
d = 2; % Example dimension
for i = 1:length(funcs)
    func = funcs{i};
    fName = funcNames{i};
    
    figure;
    set(gcf, 'Name', [fName ' Convergence']);
    for j = 1:length(algos)
        algo = algos{j};
        aName = algoNames{j};
        
        bestResults = zeros(1, numRuns);
        for run = 1:numRuns
            switch algo
                case 'ga'
                    [~, fval] = ga(func, d, [], [], [], [], -5*ones(1, d), 5*ones(1, d));
                case 'pso'
                    [~, fval] = particleswarm(func, d, -5*ones(1, d), 5*ones(1, d));
                case 'sa'
                    [~, fval] = simulannealbnd(func, rand(1, d)*10 - 5, -5*ones(1, d), 5*ones(1, d));
            end
            bestResults(run) = fval;
        end
        
        subplot(3, 1, j);
        plot(1:numRuns, bestResults, 'o-');
        title([aName ' on ' fName]);
        xlabel('Run');
        ylabel('Best Result');
        
        % Save plot
        plotFileName = fullfile(folderName, sprintf('%s_%s_D%d_plot.png', fName, aName, d));
        saveas(gcf, plotFileName);
    end
end
