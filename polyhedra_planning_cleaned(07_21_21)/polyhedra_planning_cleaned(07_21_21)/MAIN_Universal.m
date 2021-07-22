% >>> This code presents a planner for rolling of polyhedra.
% Designate the start point, target, and define obstacles on a grid. In
% in "Setup Variables." Then just execute the script.
% Here, we have two mazes as .mat files the user can chose to load in. Just
% uncomment one of the blocks in the setup variables section 4 below. 

% >>> Required functions are: 
% break_into_waypoints.m
% calculate_closest_centroid_and_expand.m
% findAngle.m
% chooseNextFace.m
% distance.m
% insert_open.m
% node_index.m
% plotFootprint.m
% min_fn.m

% >>> Cleaned up, better commented script made from
% MAIN_Universal script in universal_w_obstacles folder.
%  --Robert Baines, July 20, 2021 

% From "Robert Baines, Joran Booth, and Rebecca Kramer-Bottiglio, Soft
% rolling membrane-driven tensegrity robots. RAL. 2020" 
% https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9162439

%--------------------------------------------------------------------------

%% Setup Variables, many of which are user-defined
close all; clear;

% 1. What polyhedra are we dealing with?
polyhedra = 'rhomba'; % USER: 'cube', 'dodecahedron', or 'rhomba'.

% 2. Main loop user variables:
sLen = 2.5;           % USER: input the side length of a polyhedron 
tol = 7;              % USER: how close we want to get to our goal position in same units as sideLength. Influences convergence time/circling around goal.
printAdjNums = false; % USER: choose 'true' if you want to print numbers for adjacent sides.
pathSeg = 20;         % USER: how many waypoints do you want to break A* path into? 

% 3. Place robot, obstacles, goal on the grid
MAX_X=100;            % USER: max x coordinate of map 
MAX_Y=100;            % USER: max y coordinate of map 

MAP=2*(ones(MAX_X,MAX_Y)); %This matrix stores the coordinates of the map and the Objects in each coordinate


% 4. USER: Initialize the MAP with input values

% Maze 1: OBSTACLES 20% larger than real life, for collision buffer 
%--------
% Obstacle=-1, Target = 0,Robot=1, open space=2
maze = load('maze1.mat'); 
MAP = maze.MAP; 
xStart=5;            
yStart=5; 
xTarget=5;           
yTarget=90;
MAP(xStart,yStart)=1; % fill in occupancy grid with user-input above
MAP(xTarget,yTarget)=0;
%--------


% % Maze 2: 
% %--------
% maze = load('maze2.mat');
% MAP = maze.MAP; 
% xStart=80;            
% yStart=20; 
% xTarget=15;           
% yTarget=40;
% MAP(xStart,yStart)=1; % fill in occupancy grid with user-input above
% MAP(xTarget,yTarget)=0;
% %--------


%--------------------------------------------------------------------------

%% Prepare visualization 

figure(); 
grid on;
hold on;
set(gca,'FontSize',20);   
ylim([-MAX_Y-20 MAX_Y+20]);
xlim([-MAX_X-20 MAX_X+20]);
axis([1 MAX_X+1 1 MAX_Y+1])

plot(xTarget+.5,yTarget+.5,'gd', 'MarkerFaceColor', 'g');
text(xTarget+1,yTarget+.5,'Target');
plot(xStart+.5,yStart+.5,'bo');
[a,b] = find(MAP== -1); 
plot(a,b,'k*'); 

%--------------------------------------------------------------------------


%% LISTS USED FOR A* ALGORITHM
%OPEN LIST STRUCTURE
%--------------------------------------------------------------------------
%IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
%--------------------------------------------------------------------------
OPEN=[];
%CLOSED LIST STRUCTURE
%--------------
%X val | Y val |
%--------------
% CLOSED=zeros(MAX_VAL,2);
CLOSED=[];

%Put all obstacles on the Closed list
k=1;%Dummy counter
for i=1:MAX_X
    for j=1:MAX_Y
        if(MAP(i,j) == -1)
            CLOSED(k,1)=i;
            CLOSED(k,2)=j;
            k=k+1;
        end
    end
end
CLOSED_COUNT=size(CLOSED,1);
%set the starting node as the first node
xNode=xStart; 
yNode=yStart;  
OPEN_COUNT=1;
path_cost=0;
goal_distance=distance(xNode,yNode,xTarget,yTarget);
OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,path_cost,goal_distance,goal_distance);
OPEN(OPEN_COUNT,1)=0;
CLOSED_COUNT=CLOSED_COUNT+1;
CLOSED(CLOSED_COUNT,1)=xNode;
CLOSED(CLOSED_COUNT,2)=yNode;
NoPath=1;

%% A* ALGORITHM

while((xNode ~= xTarget || yNode ~= yTarget) && NoPath == 1)
    exp_array=expand_array(xNode,yNode,path_cost,xTarget,yTarget,CLOSED,MAX_X,MAX_Y);
    exp_count=size(exp_array,1);
    %UPDATE LIST OPEN WITH THE SUCCESSOR NODES
    %OPEN LIST FORMAT
    %--------------------------------------------------------------------------
    %IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
    %--------------------------------------------------------------------------
    %EXPANDED ARRAY FORMAT
    %--------------------------------
    %|X val |Y val ||h(n) |g(n)|f(n)|
    %--------------------------------
    for i=1:exp_count
        flag=0;
        for j=1:OPEN_COUNT
            if(exp_array(i,1) == OPEN(j,2) && exp_array(i,2) == OPEN(j,3) )
                OPEN(j,8)=min(OPEN(j,8),exp_array(i,5)); %#ok<*SAGROW>
                if OPEN(j,8)== exp_array(i,5)
                    %UPDATE PARENTS,gn,hn
                    OPEN(j,4)=xNode;
                    OPEN(j,5)=yNode;
                    OPEN(j,6)=exp_array(i,3);
                    OPEN(j,7)=exp_array(i,4);
                end %End of minimum fn check
                flag=1;
            end %End of node check
            %         if flag == 1
            %             break;
        end 
        if flag == 0
            OPEN_COUNT = OPEN_COUNT+1;
            OPEN(OPEN_COUNT,:)=insert_open(exp_array(i,1),exp_array(i,2),xNode,yNode,exp_array(i,3),exp_array(i,4),exp_array(i,5));
        end %End of insert new element into the OPEN list
    end 

    %Find out the node with the smallest fn
    index_min_node = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);
    if (index_min_node ~= -1)
        %Set xNode and yNode to the node with minimum fn
        xNode=OPEN(index_min_node,2);
        yNode=OPEN(index_min_node,3);
        path_cost=OPEN(index_min_node,6);%Update the cost of reaching the parent node
        %Move the Node to list CLOSED
        CLOSED_COUNT=CLOSED_COUNT+1;
        CLOSED(CLOSED_COUNT,1)=xNode;
        CLOSED(CLOSED_COUNT,2)=yNode;
        OPEN(index_min_node,1)=0;
    else
        %No path exists to the Target!!
        NoPath=0;%Exits the loop!
    end 
end 

%Once algorithm has run The optimal path is generated by starting of at the
%last node(if it is the target node) and then identifying its parent node
%until it reaches the start node. This is the optimal path

i=size(CLOSED,1);
Optimal_path=[];
xval=CLOSED(i,1);
yval=CLOSED(i,2);
i=1;
Optimal_path(i,1)=xval;
Optimal_path(i,2)=yval;
i=i+1;

if ( (xval == xTarget) && (yval == yTarget))
    inode=0;
    %Traverse OPEN and determine the parent nodes
    parent_x=OPEN(node_index(OPEN,xval,yval),4);%node_index returns the index of the node
    parent_y=OPEN(node_index(OPEN,xval,yval),5);
    
    while( parent_x ~= xStart || parent_y ~= yStart)
        Optimal_path(i,1) = parent_x;
        Optimal_path(i,2) = parent_y;
        %Get the grandparents:
        inode=node_index(OPEN,parent_x,parent_y);
        parent_x=OPEN(inode,4);
        parent_y=OPEN(inode,5);
        i=i+1;
    end
    j=size(Optimal_path,1);
    
    %Plot the Optimal A* generated Path!
     plot(Optimal_path(:,1)+.5,Optimal_path(:,2)+.5, '--r', 'lineWidth', 3);
else
    pause(0.1);
    h=msgbox('Sorry, No path exists to the Target!','warn');
    uiwait(h,5);
end
%Optimal_path
%--------------------------------------------------------------------------

%% Main Loop: lay out polyhedra footprints and draw lines betweeen centroids until you're close to the end goal.

angle_array = 0; %This is the storage for angles we have traveled in previous turns. It is for post-hoc analysis to hopefully find a closed-form solution to which rotation angle to use for each face
face_array = 1; % keep track of faces the polyhedra traverses over the course of the algorithm. It will always start on 1.
[obstacles_x, obstacles_y] = find(MAP == -1); % returns row and column indicies of obstacles as vectors
obstacles = [obstacles_x, obstacles_y];
target = [xTarget, yTarget];
colorCycle = {[1 0 0]; [1 1 0]; [0 1 0]; [0 1 1]; [0 0 1]; [1 0 1]}; %rgb values of the colors that the plot will cycle through
opacityCycle = {0.05; 0.05; 0.05; 0.3};    % for clearing up plot: every 4th footprint as darker
adjacentFaces = loadAdjacentFacesMatrix(polyhedra); %load the matrix definition for the chosen shape
angle = 0 ; %initialize the angle of rotation to 0 for the first previous out angle

% break A* generated path into waypoints:
[path_waypoints] = break_into_waypoints(Optimal_path, pathSeg);
path_waypoints = [path_waypoints; target];

%Continue expanding until we are close enough to the target:
count = 1; % iteration counter for while loop
cnt_waypts = 1; %counter for path waypoints
%dist_waypoint_to_goal = norm(target - [path_waypoints(1,1), path_waypoints(1,2)]);
dist_curr_to_waypoint = norm([xStart, yStart] - [path_waypoints(1,1), path_waypoints(1,2)]); % distance between current centroid and next waypoint

for k = 1:length(path_waypoints(:,1))
    if k==1 % Set up variables for the first step only
        newFace = face_array(1);
        oldFace = face_array(1);
        newCentroid = [xStart, yStart];
        oldCentroid = [xStart, yStart];
    end
    %update the target to the next waypoint once we reached the last one
    target = path_waypoints(k,:);
    dist_to_goal = norm(target - newCentroid); % note: can also use inf as initializer. 
    
    while  tol < dist_to_goal % stop when we are close by

        stepColor = [colorCycle{mod(count-1,size(colorCycle,1))+1}];  %switch the plotting color/opacity for this iteration
        stepOpacity = [opacityCycle{mod(count-1,size(opacityCycle,1))+1}];
        
        %calculate the next face and expand it
        [newFace,oldFace,newCentroid,oldCentroid,angle, dist_to_goal] = calculate_closest_centroid_and_expand(...
            adjacentFaces,sLen,newFace,oldFace,newCentroid,oldCentroid,obstacles,target,stepColor,printAdjNums);
        
        %save the position history
        face_array = [face_array, newFace];
        angle_array = [angle_array, angle];
        count = count +1; %update the color
    end
end

disp('Goal approximately reached!');
disp('faces traversed: ');
disp(face_array);
%--------------------------------------------------------------------------
