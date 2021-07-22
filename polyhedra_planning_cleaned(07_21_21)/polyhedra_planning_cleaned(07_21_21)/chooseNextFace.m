function [outNewCentroid,outNewFace,outRemainingDistance,outOldCentroid,outOldFace] = chooseNextFace(inAdjacentFaces,inAdjacentCentroids,inGoalCoords,inObstaclesVec,inCurrentCentroid,inCurrentFace,inOldCentroid,inSideLength,inAngle,inColor_str,inPrintAdjacent,inPgons)

%This function chooses which face to roll to next. It chooses the face
%closest to the next way-point after penalizing any faces that would roll
%into an obstacle or backtrack to a previous face.

%--------------------------------------------------------------------------
%calculate an initial distance for each centroid to the target, will change
dist_centroids = [];
for i = 1:size(inAdjacentCentroids,1)
    dist_centroids(i) = norm(inAdjacentCentroids(i,:) - inGoalCoords);
end

%--------------------------------------------------------------------------

%Don't consider any polygons as a potential step if they contain an
%obstacle; make their distance so large that we cannot choose it

ind_contains_obstacles = []; % initialize indicies of polygons that contain obstacles in them (not valid movements)
for i = 1:size(inAdjacentCentroids,1) %check if obstacles reside inside polygons
    [TFin, TFon] = isinterior(inPgons(i),inObstaclesVec(:,1), inObstaclesVec(:,2)); %Tfin or TFon elements are 1 when the corresponding query points are in or on a boundary of polyin. will be 5 element vecotr
    for j = 1:length(TFin)
        if TFin(j) == 1 || TFon(j) == 1 % if either contain ones there's an obstacle in that polygon
            %disp('one of the possible moves has detected an obstacle!')
            ind_contains_obstacles = [ind_contains_obstacles, i];  % get indecies of adjaecent centroids which contain obstacles
        end
    end
end
dist_centroids(ind_contains_obstacles) = dist_centroids(ind_contains_obstacles)*10000; %for faces with obstacles, multiply by a large number so it will not chose to move there.
% note: won't replace anything if there were no obstacles, due to intiialization with [] above

%--------------------------------------------------------------------------

% Find the index for the previous centroid, and give it a large value to discourage going back and forth (getting stuck behind obstacles).
% Though, this won't help with getting stuck in cycles. (a different but equivalent method is found in findAngle() )
ind_backpedaling = [];
for i = 1:size(inAdjacentCentroids,1)
    if inOldCentroid == inAdjacentCentroids(i,:)
        ind_backpedaling = [ind_backpedaling, i];
    end
end
dist_centroids(ind_backpedaling) = dist_centroids(ind_backpedaling)*5000; %give the previous face a large value so we don't go back there, but make it smaller than the obstacle penalty so we can still back out.

%--------------------------------------------------------------------------

% find minimum distance between centroid and end point and use those indicies to get x y coord of the best centroid
[outRemainingDistance, out_index_of_best_choice] = min(dist_centroids);

%--------------------------------------------------------------------------

%output the new updated faces for the next iteration and plot
outNewCentroid = inAdjacentCentroids(out_index_of_best_choice,:); %save new centroid for next iteration
outOldCentroid = inCurrentCentroid; % save current centroid for next iteration
outNewFace = inAdjacentFaces(inCurrentFace, out_index_of_best_choice); %save the new face for next iteration
outOldFace = inCurrentFace; %save the current face for next iteration
plot([outOldCentroid(1) outNewCentroid(1)], [outOldCentroid(2) outNewCentroid(2)], 'lineWidth', 3); %draw a line from the previous centroid to this best centroid

end

