% Groupwork assignment: Algorithmfor finding briges and cut vertices
% Miska Merikukka & Miia Lämsä

% Here's some graph functions that might interrest us.
% At least we can use them to check and visualize our work

% Graphs are created as follows: (Grapg in question is the graph in the
% assignment; G1
% Even thou start and target are specified they are not relevant in our
% task

s = [1, 1, 2, 3, 3, 4, 4, 5, 5, 6];         % Start vertices
t = [2, 6, 6, 4, 7, 5, 7, 7, 8, 7];         % Target vertices
n = [1:8];


G = graph(s, t);                         % Graph object 
% plot(G);                               % Simple plot


% Also weights can be assigned but this is not relevant in our case. The
% weights in this list are arbitrary
% Uncomment to see the magic :)

% Use the following to visualize the weights and names:
% Names can be set as follows: (G = graph(s, t, w, n);)
% n = {'A','B','C','D','E','F','G', 'H'};
% w = randi([1 10],1,length(s));
% G = graph(s, t, w, n);
% plot(G,'EdgeLabel',G.Edges.Weight)

% To create a directed graph use Digraph()



% Set of attributes

% for i = 1:8
% 
%     
% end

G.Nodes.visitOrder(8,1) = 0;    % Visit order 1...n - 0 for not visited


% Let's go though the original graph G to for the DF tree

% Neighbors of a vertex:
% ne = neighbors(G, 7) % In initial graph vertex 7 return correctly 3, 5, 6 --> OK!


% Build a DF tree

% startNode = 7; % Start node for DF search
% DFT = dfsearch(G,startNode, 'allevents')



[T, G, B] = dfForest(G, 7)



function [T, G, B] = dfForest(G, next)

    B = graph();
    T = digraph();                     % Empty DF tree in the beginning
    jnum = 1;                   % Start counting orders
    
    nodeCount = height(G.Nodes) % Number of nodes inthe graph

    for i = [1:nodeCount]       % 
        
        if G.Nodes.visitOrder(next) == 0  
            % Visit here
            [B, G, T, jnum, next] = dfRun(jnum, next, G, T, B);
        end 
    end

end




function [B, G, T, jnum, next] = dfRun(jnum, next, G, T, B)
    
    % Get the order number from the for loop in dfForest method - 1 the
    % first time for node next (7)
    G.Nodes.visitOrder(next) = jnum 
    
%     T = [T next]
    
    % Next vertex will get the next order number (one higher)
    jnum = jnum + 1     
    
    
    % Neighboring vertices - where to go next.
    ne = neighbors(G, next)
    
    % Run through list of neighbors
    for v = 1:length(ne)
        
        neighborCandi = ne(v);
        
        % If the neighbor has not been visited go to
        if G.Nodes.visitOrder(neighborCandi) == 0
            T = addedge(T, next, neighborCandi)
            
            % Uncomment to see plotting of DF tree during formation
            % plot(T);
            
            [B, G, T, jnum, next] = dfRun(jnum, neighborCandi, G, T, B)
             
            % Setting "current" vertex "back"
            next = predecessors(T, next)
                     
        end
  
    end
    
end


