% GA vs DE porovnanie - viac behov
clc; clear; close all;

numgen = 500;       % number of generations
lpop = 50;          % population size
D = 10;             % number of dimensions
M = 500;            % max search space
runs = 5;           % number of repetitions

Space = [ones(1,D)*(-M); ones(1,D)*M];
Delta = Space(2,:)/100;

% Parametre DE
F = 0.6;
CR = 0.7;

% Predalokovanie
allGA = zeros(runs, numgen);
allDE = zeros(runs, numgen);
bestGA = zeros(1, runs);
bestDE = zeros(1, runs);
avgGA = zeros(1, numgen);
avgDE = zeros(1, numgen);

figure(1); clf; hold on; grid on;
title('GA vs DE - priemer a najlepsie behy');
xlabel('Generacia'); ylabel('Fitness');

% --- GA behy ---
for r = 1:runs
    Pop = genrpop(lpop, Space);
    evolution_GA = zeros(1,numgen);

    for gen = 1:numgen
        Fit = testfn3(Pop);
        evolution_GA(gen) = min(Fit);
        Best = selbest(Pop,Fit,[1,1]);
        Old = selrand(Pop,Fit,10);
        Work1 = selsus(Pop,Fit,18);
        Work2 = selsus(Pop,Fit,20);
        Work1 = crossov(Work1,1,0);
        Work2 = mutx(Work2,0.15,Space);
        Work2 = muta(Work2,0.15,Delta,Space);
        Pop = [Best;Old;Work1;Work2];
    end

    allGA(r,:) = evolution_GA;
    bestGA(r) = min(evolution_GA);
    avgGA = avgGA + evolution_GA;

    % vykreslenie kazdeho behu GA cierne
    plot(evolution_GA, 'k', 'LineWidth', 0.5);
end

avgGA = avgGA / runs;
[~, idxBestGA] = min(bestGA);

% --- DE behy ---
for r = 1:runs
    Pop = genrpop(lpop, Space);
    Fit = testfn3(Pop);
    evolution_DE = zeros(1,numgen);

    for gen = 1:numgen
        for i = 1:lpop
            idx = randperm(lpop,3);
            while any(idx == i)
                idx = randperm(lpop,3);
            end

            x1 = Pop(idx(1),:);
            x2 = Pop(idx(2),:);
            x3 = Pop(idx(3),:);

            V = x1 + F*(x2 - x3);

            U = Pop(i,:);
            jrand = randi(D);
            for j = 1:D
                if rand <= CR || j == jrand
                    U(j) = V(j);
                end
            end

            U = max(U, Space(1,:));
            U = min(U, Space(2,:));

            fU = testfn3(U);
            if fU <= Fit(i)
                Pop(i,:) = U;
                Fit(i) = fU;
            end
        end
        evolution_DE(gen) = min(Fit);
    end

    allDE(r,:) = evolution_DE;
    bestDE(r) = min(evolution_DE);
    avgDE = avgDE + evolution_DE;

    % vykreslenie kazdeho behu DE cervene
    plot(evolution_DE, 'r', 'LineWidth', 0.5);
end

avgDE = avgDE / runs;
[~, idxBestDE] = min(bestDE);

% --- vykreslenie priemerov a najlepsich behov ---
hGAavg = plot(avgGA, 'Color', [0 1 1], 'LineWidth', 3);        % cyan
hGAmin = plot(allGA(idxBestGA,:), 'Color', [0 1 0], 'LineWidth', 2);  % green
hDEavg = plot(avgDE, 'Color', [0.5 0 0.5], 'LineWidth', 3);    % purple
hDEmin = plot(allDE(idxBestDE,:), 'Color', [0 0 0.5], 'LineWidth', 2); % dark blue

legend([hGAavg hGAmin hDEavg hDEmin], ...
    {'Priemer GA','Najlepsi GA','Priemer DE','Najlepsi DE'}, ...
    'Location','northeastoutside');

fprintf('\nGA: mean of best = %.6g, global best = %.6g\n', mean(bestGA), min(bestGA));
fprintf('DE: mean of best = %.6g, global best = %.6g\n', mean(bestDE), min(bestDE));
