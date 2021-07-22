function [outNewFace,outOldFace, outNewCentroid, outOldCentroid, outAngle, outRemainingDistance] = ...
    calculate_closest_centroid_and_expand(inAdjacentFaces, inSideLength, inCurrentFace,...
    inOldFace, inCurrentCentroid, inOldCentroid, inObstaclesVec, inGoalCoords, inColor_str, inPrintAdjacent)

% >>> Calculate distance between each possible centroid and the end point;
% choose to go in direction which minimizes euclidian distance.

% >>> This code takes a new centroid value, unfolds all the possible moves
% into the "footprint" of faces that would be down when the polyhedra
% rolls. Then the code rotates those moves to match the global coordinate 
% frame. The distance from each possible face to the end point is 
% calculated. Then, this code checks each possible face to see if obstacles 
% are present inside its boundaries. If they are, that face is heavily
% penalized. The previous face is also penalized, but less so. 
% The shortest distance is chosen as the next "best" move. It is plotted

% >>> Inputs: 
% inAdjacentFaces = the matrix-form definition of the physical solid
% inSideLength = the length of side of a regular pentagon, arbitrary units
% inCurrentFace = the current downward face number
% inOldFace = the previous downward face number
% inCurrentCentroid = the XY coordinates for the centroid on the current downface
% inOldCentroid = the XY coordinates for the centroid on the previous downface
% inObstaclesVec = matrix consisting of column vectors of obstacles in [x, y] format
% inGoalCoords = user-specified goal coordinates in [x, y] format
% inColor_str = color that will be plotted for this iteration
% inPrintAdjacent = true/false value that turns on or off the plotting of face numbers adjacent to the downward face, typically for debugging

% >>> Outputs: 
% outNewFace = new chosen down face number for next move
% outOldFace = previous down face number
% outNewCentroid = new chosen centroid [x, y] coodinates
% outOldCentroid = old centroid [x, y] coordinates 
% outAngle = angle of rotation between centroids of outOldFace to outNewFace
% outRemainingDistance = euclidian distance to goal 

pause(0.01);

%--------------------------------------------------------------------------
%For the new face, find its adjacent centroids in XY, and plot the
%polygons.
[outAngle,adjacentCentroidXY,pgons] = findAngle(inAdjacentFaces,inCurrentCentroid,inOldCentroid,inSideLength, inCurrentFace, inOldFace,inColor_str,inPrintAdjacent);

%--------------------------------------------------------------------------

%Choose which face to roll onto
%COST FUNCTION for each of the polygons in the footprint calculates
%distance from their centroid to the goal i.e. checkpoint 
[outNewCentroid,outNewFace,outRemainingDistance,outOldCentroid,outOldFace]...
    = chooseNextFace(inAdjacentFaces,adjacentCentroidXY,inGoalCoords,inObstaclesVec,inCurrentCentroid,inCurrentFace,inOldCentroid,inSideLength,outAngle,inColor_str,inPrintAdjacent,pgons);
end

