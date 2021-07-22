function [outAngle,outCentroidsXY,outPgons] = findAngle(inAdjacentFaces, inCentroidNewFace,...
    inCentroidOldFace,inSideLength, inCenterFaceNumber, inOldCenterFaceNumber,inColor_str,inPrintAdjacent)

% >>> This function gets the angle of rotation needed to correctly orient
% the new downface relative to the global coordinate system and the last
% downface. This function begins by finding the correction angle needed to
% align the global coordinate system with the face coordinate system. It
% then determines how much the face coordinate system should be rotated by
% determining which was the last face.


%--------------------------------------------------------------------------

% figure out the polygon of the downward face and then each adjacent face,
% and use it to determine centroid-to-centroid length, assuming equal edge 
% lengths, and store the number of sides for each face

numSides(1) = length(inAdjacentFaces(inCenterFaceNumber,:)) - isnan(inAdjacentFaces(inCenterFaceNumber,end));
if numSides(1) == 3
    centroidToEdge(1) = (tan(deg2rad(30)) * inSideLength/2);
    theta = 120;
elseif numSides(1) == 4
    centroidToEdge(1) = inSideLength/2;
    theta = 90;
elseif numSides(1) == 5
    centroidToEdge(1) = (inSideLength)/(2*tan(pi/5));
    theta = 72;
end

for i=1:size(inAdjacentFaces,2)
    if isnan(inAdjacentFaces(inCenterFaceNumber,i))
    else
        numSides(i+1) = length(inAdjacentFaces(inAdjacentFaces(inCenterFaceNumber,i),:)) - isnan(inAdjacentFaces(inAdjacentFaces(inCenterFaceNumber,i),end));
        if numSides(i+1) == 3
            centroidToEdge(i+1) = (tan(deg2rad(30)) * inSideLength/2);
        elseif numSides(i+1) == 4
            centroidToEdge(i+1) = inSideLength/2;
        elseif numSides(i+1) == 5
            centroidToEdge(i+1) = (inSideLength)/(2*tan(pi/5));
        end
    end
end

centroidToCentroidLength = centroidToEdge(1)+centroidToEdge(2:end);

%--------------------------------------------------------------------------

% Remember which faces were which in previous rolls 
index_old_face = find(inAdjacentFaces(inCenterFaceNumber,:)==inOldCenterFaceNumber); %which face index is the old one?
index_new_face = find(inAdjacentFaces(inOldCenterFaceNumber,:)==inCenterFaceNumber);
%outNewCenterFaceNumber = adjacentFaces(inCenterFaceNumber,inChosenAngleIndex);

%--------------------------------------------------------------------------

%now, rotate the new footprint such that the old downface is aligned with where it
%is positioned in the new downface
if inCentroidNewFace==inCentroidOldFace
    %if the face is the same as last time, don't change anything. This only
    %applies to the start condition.
    outAngle = 0;
else
    %If the face is different from last time, align the coordinate system of
    %the new face. Use an optimization that varies the angle of rotation to minimize
    %the difference between where the old centroid location and the calculated
    %location of the old centroid within the new frame of reference.
    
    %disp('Sizes: ') % debugging 
    %disp(theta)
    %disp(index_old_face);
    %disp(centroidToCentroidLength(index_old_face));
    
    costFunction = @(angle)(norm([inCentroidOldFace(1)-(inCentroidNewFace(1) + centroidToCentroidLength(index_old_face)*cos(deg2rad(angle+theta*(index_old_face-1)))) ...
        inCentroidOldFace(2)-(inCentroidNewFace(2) + centroidToCentroidLength(index_old_face)*sin(deg2rad(angle+theta*(index_old_face-1))))]));
    [outAngle] = fminsearch(costFunction,index_new_face*theta);
    outAngle = round(outAngle(1));
end

%--------------------------------------------------------------------------

%finally, find the xy position of each centroid.
outCentroidsXY = zeros(size(centroidToCentroidLength,2),2);
for face=1:length(centroidToCentroidLength)
    outCentroidsXY(face,1) = (inCentroidNewFace(1) + centroidToCentroidLength(face)*cos(deg2rad(outAngle+theta*(face-1))));
    outCentroidsXY(face,2) = (inCentroidNewFace(2) + centroidToCentroidLength(face)*sin(deg2rad(outAngle+theta*(face-1))));
end

%--------------------------------------------------------------------------

%plot the footprint of the current face and adjacent sides, output sides for future detection of whether an obstacle is contained in a potential polygon
outPgons = plotFootprint(inCentroidNewFace,outCentroidsXY,inSideLength,numSides,outAngle, inColor_str,inCenterFaceNumber,inPrintAdjacent,theta,inAdjacentFaces(inCenterFaceNumber,:));

end