clc; clear all; close all;
%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%
% Field Dimensions
x_max = 100;
y_max = 100;
% Sink Coordinates
sink.x = 0.5 * x_max;
sink.y = 0.5 * y_max;
% Number of Nodes
NUM_NODES =100;
% Number of Clusters
k = 5;
% Initial Energy of Each Node
Eo=0.5;
% Packet Length
packet_length = 500;
% Radio Transmission and Reception Coefficients
ETX=50*0.0000001;
ERX=50*0.0000001;
Eelec=50*0.000000001;
% Free Space and Multi-Path Model Coefficients
Efs= 10*0.0000000001;
Emp= 0.013*0.0000000001;
% Number of Rounds
rounds = 100;
% Threshold Distance
threshold = 900;
%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%
% Threshold Distance
do = Efs/Emp;
%%%Energy spent for transmitting an advertisement message;
%%Eadv=5*0.0000001;
%%%%Adversitement message packet length
packet_adv=0.5;
% Creating a random sensor network
figure(1);
for i = 1:1:NUM_NODES
    S(i, 1) = rand(1, 1) * x_max;
    S(i, 2) = rand(1, 1) * y_max;
    plot(S(i, 1), S(i, 2), 'red o');
    hold on;
end
% disp(S);
% plot(sink.x, sink.y, 'black o');
% hold on;
[idx, C] = kmeans(S, k);
% disp(idx);
% disp(C);
plot(C(:,1), C(:,2), 'k*', 'MarkerSize', 15);
hold on;
% nodes = zeros;
for i = 1:1:NUM_NODES
    nodes(i).x = S(i, 1);
    nodes(i).y = S(i, 2);
    nodes(i).battery = Eo;
    nodes(i).cluster = (idx(i) - 1);
    nodes(i).sink_x = C(idx(i), 1);
    nodes(i).sink_y = C(idx(i), 2);
    nodes(i).state = 1;%%%1 if node is alive and 0 if node is dead
    nodes(i).distance = (nodes(i).x - nodes(i).sink_x)^2 + (nodes(i).y - nodes(i).sink_y)^2;
    nodes(i).route = zeros;
    %nodes(i).advertisement=zeros;
end

G = graph();
for i = 1:1:NUM_NODES
    if(findnode(G,i)==0)
    G=addnode(G,i);
    end
    for j = i:1:NUM_NODES
        if (nodes(i).cluster == nodes(j).cluster&&(i~=j))
            if((nodes(i).distance<=threshold)&&(findnode(G,NUM_NODES+nodes(i).cluster+1)~=0)&&(findedge(G,i,NUM_NODES + nodes(i).cluster + 1)==0))
                G = addedge(G, i, NUM_NODES + nodes(i).cluster + 1, nodes(i).distance);
            elseif(findnode(G,NUM_NODES+nodes(i).cluster+1)==0)
                G = addedge(G, i, NUM_NODES + nodes(i).cluster + 1, nodes(i).distance);
            end

            node_dist = ((nodes(i).x - nodes(j).x)^2 + (nodes(i).y - nodes(j).y)^2);
            if node_dist < threshold
                G = addedge(G, i, j, node_dist);
            end
        end
    end
end

for i = 1:1:NUM_NODES
    nodes(i).route = shortestpath(G, i, NUM_NODES + nodes(i).cluster + 1);
end

% distances = zeros;
% for i = 0:1:k-1
%     for j = 1:1:NUM_NODES
%         if nodes(j).cluster == i && nodes(i).distance < do
%         end
%     end
% end
wake_clust = 1;
plot_idx = 1;   
round_stat = zeros;
dead_stats = zeros;
num_temp = NUM_NODES;
dead_nodes = 0;
nodes_without_link=0;
non_link_nodes = 0;

for j=0:1:k-1
    v = dfsearch(G,NUM_NODES+j+1);
    for i=1:1:NUM_NODES       
        if(nodes(i).cluster==(j))
        check_for_dead_node = ismember(i,v);
        if(check_for_dead_node==0)
        nodes_without_link = nodes_without_link+1;
        non_link_nodes(numel(non_link_nodes)+1) = i;
        end
        end
    end
end

non_link_nodes(1) = [];
%operating_nodes = NUM_NODES;
% round=0;


while dead_nodes < NUM_NODES
    dead_nodes = 0;
    operating_nodes=100;
    for j = 1:1:num_temp
        if (nodes(j).state == 1) & (nodes(j).cluster == wake_clust)
            if nodes(j).battery>0
                nodes(j).battery = nodes(j).battery - packet_adv*Eelec;    
            end 
            for m = 1:1:length(nodes(j).route)-1
                if (nodes(j).route(m+1) <= NUM_NODES)  
                    if (nodes(nodes(j).route(m)).state == 1 && nodes(nodes(j).route(m+1)).state == 1)
                    dist_node = ((nodes(nodes(j).route(m)).x - nodes(nodes(j).route(m+1)).x)^2 + (nodes(nodes(j).route(m)).y - nodes(nodes(j).route(m+1)).y)^2);
                    if (dist_node > do)
                        nodes(nodes(j).route(m)).battery = nodes(nodes(j).route(m)).battery - ((ETX)*(packet_length) + Emp*packet_length*(dist_node^2)); 
                    end
        
                    if (dist_node <= do)
                        nodes(nodes(j).route(m)).battery = nodes(nodes(j).route(m)).battery - ((ETX)*(packet_length) + Efs*packet_length*(dist_node)); 
                    end
        
                    if (nodes(j).route(m+1) <= NUM_NODES)   
                        nodes(nodes(j).route(m+1)).battery = nodes(nodes(j).route(m+1)).battery - (ERX)*(packet_length);
                    end
                    
                    end
                
                
                    if nodes(nodes(j).route(m)).battery <= 0.1*Eo
                        nodes(nodes(j).route(m)).state = 0;
                        %dead_nodes=dead_nodes+1;
                        %operating_nodes = operating_nodes - 1;
                        plot(nodes(nodes(j).route(m)).x, nodes(nodes(j).route(m)).y, 'black x');
                        hold on;
                    end
                
                    if nodes(nodes(j).route(m+1)).battery <= 0.1*Eo
                        nodes(nodes(j).route(m+1)).state = 0;
                        %dead_nodes=dead_nodes+1;
                        %operating_nodes = operating_nodes - 1;
                        plot(nodes(nodes(j).route(m+1)).x, nodes(nodes(j).route(m+1)).y, 'black x');
                        hold on;
                    end
%             disp("Dead nodes after basic energy parsing");
%             disp(dead_nodes);
                else
                    if (nodes(nodes(j).route(m)).distance > do)
                        nodes(nodes(j).route(m)).battery = nodes(nodes(j).route(m)).battery - ((ETX)*(packet_length) + Emp*packet_length*(nodes(nodes(j).route(m)).distance^2)); 
                    end
        
                    if (nodes(nodes(j).route(m)).distance <= do)
                        nodes(nodes(j).route(m)).battery = nodes(nodes(j).route(m)).battery - ((ETX)*(packet_length) + Efs*packet_length*(nodes(nodes(j).route(m)).distance)); 
                    end
                    
                    if nodes(nodes(j).route(m)).battery <= 0.1*Eo
                        nodes(nodes(j).route(m)).state = 0;
                        %dead_nodes=dead_nodes+1;
                        %operating_nodes = operating_nodes - 1;
                        plot(nodes(nodes(j).route(m)).x, nodes(nodes(j).route(m)).y, 'black x');
                        hold on;
                    end
                end
%                  disp(dead_nodes);
%                  disp("hello world 123 mic test");
%                 round=round+1;
%                 disp(round);
%                 disp("This is the round bleh bleh ");
            end
        end
    end
    
    for p_0 = 1:1:NUM_NODES
        if (nodes(p_0).state == 0) & (findedge(G, p_0, nodes(p_0).cluster + NUM_NODES + 1) ~= 0)
            G = rmedge(G, p_0, nodes(p_0).cluster + NUM_NODES + 1);
        end
        
        for p_1 = p_0:1:NUM_NODES
            if (findedge(G, p_0, p_1) ~= 0) & (nodes(p_1).state == 0) || nodes(p_0).state == 0
                G = rmedge(G, p_0, p_1);
            end
        end
    end
    
    for p = 1:1:NUM_NODES
        nodes(p).route = shortestpath(G, p, nodes(p).cluster + NUM_NODES + 1);
        if nodes(p).state == 0
            dead_nodes = dead_nodes + 1;
            operating_nodes = operating_nodes - 1;
        end
        if((isempty(nodes(p).route)==1)&&nodes(p).state==1)
            nodes_without_link=nodes_without_link+1;
            nodes(p).state=0;
        end
    end
%     pause(0.5);
    wake_clust = mod(wake_clust + 1, k);
    
     if (mod(i, k) == 0)
         round_stat(plot_idx) = plot_idx;
         dead_stats(plot_idx) = dead_nodes;
         op_stats(plot_idx) = operating_nodes;
         plot_idx = plot_idx + 1;
     end
    % if (dead_nodes == NUM_NODES)
    %     break;
    % end
    dead_nodes = nodes_without_link+dead_nodes;
    disp("Number of dead nodes");
    disp(dead_nodes);
    disp(operating_nodes);
    %disp(dead_nodes);
    nodes_without_link = 0;
%     round=round+1;
%     op(round)=operating_nodes;
    %disp(round);
    %disp(dead_nodes);
    %op(rounds)=operating_nodes;
end

figure(2);
plot(round_stat,op_stats,'-r','Linewidth',2);
%axis([0  20000    0  NUM_NODES])
title("Operating Nodes V/s Rounds");
xlabel("Rounds");
ylabel("Operating Nodes");
hold on;