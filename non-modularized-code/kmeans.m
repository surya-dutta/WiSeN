clc; clear; close;

%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%

% Field Dimensions
x_max = 100;
y_max = 100;

% Sink Coordinates
sink.x = 0.5 * x_max;
sink.y = 0.5 * y_max;

% Number of Nodes
NUM_NODES = 100;

% Number of Clusters
k = 3;

%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%


% Creating a random sensor network
figure(1);

for i = 1:1:NUM_NODES

    % Distribute nodes randomly over field.
    S(i, 1) = rand(1, 1) * x_max;
    S(i, 2) = rand(1, 1) * y_max;
    
    plot(S(i, 1), S(i, 2), 'red o');
    hold on;
end

disp(S);

plot(sink.x, sink.y, 'black x');
hold on;

% Apply k-means clustering to divide the network into clusters.
[idx, C] = kmeans(S, k);
disp(idx);
disp(C);

% Plot out the centroids of each cluster.
plot(C(:,1), C(:,2), 'black x', 'MarkerSize', 15);
hold on;
