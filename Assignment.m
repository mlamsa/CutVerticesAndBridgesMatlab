% Groupwork assignment: Algorithm for finding bridges and cut vertices
% Miska Merikukka & Miia Lämsä
% Tampere University Discrete mathamatics, 2019 Spring
%
% 
%                              ___....___
%    ^^                __..-:'':__:..:__:'':-..__
%                  _.-:__:.-:'':  :  :  :'':-.:__:-._
%                .':.-:  :  :  :  :  :  :  :  :  :._:'.
%             _ :.':  :  :  :  :  :  :  :  :  :  :  :'.: _
%            [ ]:  :  :  :  :  :  :  :  :  :  :  :  :  :[ ]
%            [ ]:  :  :  :  :  :  :  :  :  :  :  :  :  :[ ]
%   :::::::::[ ]:__:__:__:__:__:__:__:__:__:__:__:__:__:[ ]:::::::::::
%   !!!!!!!!![ ]!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!![ ]!!!!!!!!!!!
%   ^^^^^^^^^[ ]^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[ ]^^^^^^^^^^^
%            [ ]                                        [ ]
%            [ ]                                        [ ]
%      jgs   [ ]                                        [ ]
%    ~~^_~^~/   \~^-~^~ _~^-~_^~-^~_^~~-^~_~^~-~_~-^~_^/   \~^ ~~_ ^
%


% Here's some graph functions that might interrest us.
% At least we can use them to check and visualize our work

% Graphs are created as follows: (Grapg in question is the graph in the
% assignment; G1
% Even thou start and target are specified they are not relevant in our
% task

s = [1, 1, 2, 3, 3, 4, 4, 5, 5, 6];         % Start vertices
t = [2, 6, 6, 4, 7, 5, 7, 7, 8, 7];         % Target vertices
n = [1:8];

G = graph(s, t);                            % Graph object 

% Also weights can be assigned but this is not relevant in our case. The
% weights in this list are arbitrary
% Uncomment to see the magic :)

% Use the following to visualize the weights and names:
% Names can be set as follows: (G = graph(s, t, w, n);)
% n = {'A','B','C','D','E','F','G', 'H'};
% w = randi([1 10],1,length(s));
% G = graph(s, t, w, n);
% plot(G,'EdgeLabel',G.Edges.Weight)

% Create DF forest (T) and back edges (B)
[T, G, B] = dfForest(G, 7);

% The following executes assignment 1:
chains = makeChains(G, B, T);

% The following executes assignment 2:
[bridges, cutV] = bridgesCutV(G, chains)


function [T, G, B] = dfForest(G, next)

    G.Nodes.visitOrder(8,1) = 0;    % Visit order 1...n - 0 for not visited

    B = digraph();
    T = digraph();                  % Empty DF tree in the beginning
    jnum = 1;                       % Start counting orders
    
    nodeCount = height(G.Nodes);    % Number of nodes inthe graph

    for i = 1:nodeCount        
        
        if G.Nodes.visitOrder(next) == 0  
            % Visit here
            [B, G, T, jnum, next] = dfRun(jnum, next, G, T, B);
        end 
    end

%     Finished product plotted
    
%     figure(1)
%         subplot(1,2,1)
%             plot(B);
%             title('Back edges in B');
%         subplot(1,2,2)
%             plot(G);
%             title('Original graph G');
%         set(gca,'XTick',[], 'YTick', []);

end

function [B, G, T, jnum, next] = dfRun(jnum, next, G, T, B)
    
    % Get the order number from the for loop in dfForest method - 1 the
    % first time for node next (7)
    G.Nodes.visitOrder(next) = jnum; 
    
    % Next vertex will get the next order number (one higher)
    jnum = jnum + 1;     
   
    % Neighboring vertices - where to go next.
    ne = neighbors(G, next);
    
    % Run through list of neighbors
    for v = 1:length(ne)
        
        neighborCandi = ne(v);
        
        % If the neighbor has not been visited go to
        if G.Nodes.visitOrder(neighborCandi) == 0

            T = addedge(T, next, neighborCandi);
            
            % Uncomment to see plotting of DF tree during formation
            % plot(T);
            
            [B, G, T, jnum, next] = dfRun(jnum, neighborCandi, G, T, B);
            
            % Setting "current" vertex "back"
            next = predecessors(T, next);
            
        else
            if findedge(T, neighborCandi, next)
%                 disp('skip');
            else
                
                % Here the direction detectino mechanism. If the neighbor
                % has larger visit order number it should be added.
                
                if G.Nodes.visitOrder(neighborCandi) > G.Nodes.visitOrder(next) 
                    B = addedge(B, next, neighborCandi);
                end
                % Uncomment to see the graph being built (debugging
                % purpose)
%                 plot(B);
            end
                  
        end
  
    end
    
end

function chains = makeChains(G, B, T)

    chainNo = 0;
    
    chains = {};
    L = [];
    
    
    % Format visited vertices
    G.Nodes.visitedForChains(8,1) = 0;
    
    % Read table to vector
    chainCand = B.Edges(:,1);
    chainCand = chainCand{:,1};
    
    for i = 1:length(chainCand)
        
        % Mark the initial vertices from back edges as visited
        G.Nodes.visitedForChains(chainCand(i,1)) = 1;
        G.Nodes.visitedForChains(chainCand(i,2)) = 1;
        
        % Add the vertices to chain
        L = [L chainCand(i,:)];
        
        % Check next one in the hierarchy
        next = predecessors(T, chainCand(i,2));
        
        % While not visited - visit
        while G.Nodes.visitedForChains(next) == 0
            L = [L next];
            next = predecessors(T, next);
            
        end
        
        % Add the last one
        L = [L next];
        
        % Output to list of chains
        chains{i} = L;
        
        % Format for next round
        L = [];
    end
end

function [bridges, cutV] = bridgesCutV(G, chains)
      
    loops = [];
    bridges = [];
    cutV = [];
    
    % Create loops (edges)
    for i = 1:length(chains)
        for j = 1:length(chains{i})-1             
           loops = [ loops; chains{i}(j) (chains{i}(j+1)) ];          
        end    
    end
    
    % Read table to vector
    GEdges = G.Edges(:,1);
    GEdges = GEdges{:,1};
    
%     plot(G) % debug
    
    % Remove chain edges from the original graph
    for i = 1:length(loops)
        G = rmedge(G, loops(i,1), loops(i,2));
    end
    
    % Format bridges
    bridges = G.Edges(:,1);
    bridges = bridges{:,1};
   
    % Format cut vertices
    for i = 1:size(bridges,1)
        for j = 1:size(bridges,2)
          cutV = [cutV bridges(i,j)];
        end
    end

end