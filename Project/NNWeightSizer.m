% NNWEIGHTSIZER Script implementing log-space neural network + Gaussian
% process to predict MTOW from other parameters using historical data

data = rmmissing(readtable("UAV-Params.xlsx"));
param_names = data.Properties.VariableNames;

mtow_index = find(contains(param_names, 'MTOW', 'IgnoreCase', true));
empty_index = find(contains(param_names, 'Empty', 'IgnoreCase', true));

is_numeric = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
params = find(is_numeric);
params(params == mtow_index) = [];
params(params == empty_index) = [];
param_names = param_names(params);

X = table2array(data(:, params));
Y_mtow = table2array(data(:, mtow_index));
Y_empty = table2array(data(:, empty_index));

Y_mtow_log = log(Y_mtow);
Y_empty_log = log(Y_empty);

[xn, xps] = mapminmax(X');
xn = xn';

n_runs = 1000;
mtow_nn_values = zeros(n_runs, 1);
mu_mtow_values = zeros(n_runs, 1);
sigma_mtow_values = zeros(n_runs, 1);
mu_empty_values = zeros(n_runs, 1);
sigma_empty_values = zeros(n_runs, 1);


%% Train/test split
% RNG is reseeded every run and the initial weights reset. There's
% definitely more efficient ways to do this but I cba for now

for i = 1:n_runs
    rng(randi(1e5))
    cv = cvpartition(size(xn,1), 'HoldOut', 0.2);

    x_train = xn(training(cv), :);
    x_test  = xn(test(cv), :);
    
    y_mtow_train = Y_mtow_log(training(cv), :);
    y_mtow_test  = Y_mtow(test(cv), :);
    
    y_empty_train = Y_empty_log(training(cv), :);
    y_empty_test  = Y_empty(test(cv), :);
    
    layers = [
            featureInputLayer(size(x_train,2))
        
            fullyConnectedLayer(12, 'WeightL2Factor', 1e-3)
            reluLayer
        
            fullyConnectedLayer(6, 'WeightL2Factor', 1e-3)
            reluLayer
        
            fullyConnectedLayer(1)
        ];
        
        options = trainingOptions('adam', ...
            'MaxEpochs', 400, ...
            'InitialLearnRate', 5e-4, ...
            'MiniBatchSize', 8, ...
            'Shuffle', 'every-epoch', ...
            'Verbose', false);

    net_mtow = trainnet(x_train, y_mtow_train, layers, "mse", options);
    
    %% NN prediction
    
    y_pred_log_nn = predict(net_mtow, x_test);
    y_pred_nn = exp(y_pred_log_nn);
    
    RMSE_nn = sqrt(mean((y_pred_nn - y_mtow_test).^2));
    
    %% Gaussian component
    
    gp_mtow = fitrgp(x_train, y_mtow_train, ...
        'KernelFunction','ardsquaredexponential', ...
        'Standardize',true);
    
    gp_empty = fitrgp(x_train, y_empty_train, ...
        'KernelFunction','ardsquaredexponential', ...
        'Standardize',true);
    
    mtow_mean  = exp(predict(gp_mtow, x_test));
    RMSE_gp = sqrt(mean((mtow_mean - y_mtow_test).^2));
    
    empty_mean  = exp(predict(gp_empty, x_test));
    RMSE_empty = sqrt(mean((empty_mean - y_empty_test).^2));
    
    %% Gaussian predictions
    
    sunfish_params = [2, 382, 12, 17.2, 1.6, 20];
    sunfish_norm = mapminmax('apply', sunfish_params', xps)';
    
    % NN MTOW
    mtow_nn = exp(predict(net_mtow, sunfish_norm));
    
    % GPR MTOW
    [mu_mtow, sigma_mtow] = predict(gp_mtow, sunfish_norm);
    [mu_empty, sigma_empty] = predict(gp_empty, sunfish_norm);
    
    fprintf("Run %d; NN MTOW | GP MTOW | GP Empty RMSE: %.4f | %.4f | %.4f\n", i, RMSE_nn, RMSE_gp, RMSE_empty);

    mtow_nn_values(i) = mtow_nn;
    mu_mtow_values(i) = mu_mtow;
    sigma_mtow_values(i) = sigma_mtow;
    mu_empty_values(i) = mu_empty;
    sigma_empty_values(i) = sigma_empty;
end

% Average results
mtow_nn = mean(mtow_nn_values);
mtow_gp = mean(exp(mu_mtow_values));
mtow_gp_low = exp(mean(mu_mtow_values) - 2*mean(sigma_mtow_values));
mtow_gp_high = exp(mean(mu_mtow_values) + 2*mean(sigma_mtow_values));

empty_gp = mean(exp(mu_empty_values));
empty_gp_low = exp(mean(mu_empty_values) - 2*mean(sigma_empty_values));
empty_gp_high = exp(mean(mu_empty_values) + 2*mean(sigma_empty_values));

fprintf("\nMTOW (NN): %.2f\n", mtow_nn)
fprintf("MTOW (NN) stdev: %.2f\n", std(mtow_nn_values))

fprintf("\nMTOW (GP): %.2f\n", mtow_gp)
fprintf("MTOW (GP) stdev: %.2f\n", std(exp(mu_mtow_values)))
fprintf("95%% CI: [%.2f, %.2f]\n", mtow_gp_low, mtow_gp_high)

fprintf('\nEmpty weight (GP): %.2f\n', empty_gp)
fprintf("Empty weight (GP) stdev: %.2f\n", std(exp(mu_empty_values)))
fprintf('95%% CI: [%.2f, %.2f]\n', empty_gp_low, empty_gp_high)